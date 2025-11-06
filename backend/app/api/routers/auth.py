from typing import Optional
import io
import random
import string
import time

from fastapi import APIRouter, Depends, HTTPException, status, Header, Request
from fastapi.responses import StreamingResponse
from fastapi.security import OAuth2PasswordBearer
from fastapi import Form
from sqlmodel import Session, select

from app.core.config import settings
from app.core.security import (
    create_access_token,
    decode_token,
    verify_password,
)
from app.db.session import get_db
from app.models.user import User, UserRead, UserProfile
from app.models.system import SystemDefault

# 创建一个FastAPI路由器，前缀为/auth，标签为auth
router = APIRouter(prefix="/auth", tags=["auth"])

# 定义OAuth2密码认证方式，token获取地址为/api/auth/token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

# 简单的基于内存的按 IP 登录失败计数与验证码存储（单实例适用）
FAILED_LOGIN_BY_IP: dict[str, dict[str, float]] = {}
# 结构：{
#   ip: {
#     "fail_count": int,
#     "captcha_required_until": timestamp,
#     "last_fail_at": timestamp
#   }
# }

CAPTCHA_STORE: dict[str, dict[str, float]] = {}
# 结构：{
#   ip: {
#     "code": str,
#     "expires_at": timestamp
#   }
# }

FAIL_THRESHOLD = 5
FAIL_WINDOW_SECONDS = 15 * 60  # 15 分钟窗口
CAPTCHA_REQUIRE_SECONDS = 15 * 60  # 需要验证码的持续时间
CAPTCHA_TTL_SECONDS = 3 * 60  # 验证码有效期


# 登录接口，接收表单数据，返回access token
@router.post("/token")
async def login_access_token(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    grant_type: Optional[str] = Form(None),
    db: Session = Depends(get_db)
) -> dict:
    client_ip = request.client.host if request.client else "unknown"

    # 仅从请求头读取验证码
    captcha_code: Optional[str] = request.headers.get("X-Captcha-Code")

    # FastAPI 通过 Form() 已解析 username 和 password

    # 读取并更新该 IP 的失败记录
    now = time.time()
    ip_state = FAILED_LOGIN_BY_IP.get(client_ip, {"fail_count": 0, "captcha_required_until": 0.0, "last_fail_at": 0.0})
    # 若超过窗口，重置计数
    if ip_state["last_fail_at"] and (now - ip_state["last_fail_at"]) > FAIL_WINDOW_SECONDS:
        ip_state = {"fail_count": 0, "captcha_required_until": 0.0, "last_fail_at": 0.0}

    # 如果处于需要验证码的时间段，则强制校验验证码
    captcha_required = ip_state.get("captcha_required_until", 0) > now
    if captcha_required:
        expected = CAPTCHA_STORE.get(client_ip, {})
        # 检查是否提供了验证码
        if not captcha_code or not captcha_code.strip():
            # 未提供验证码
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="CAPTCHA_REQUIRED"
            )
        # 检查验证码是否正确
        code_ok = (
            bool(expected)
            and expected.get("expires_at", 0) >= now
            and captcha_code.strip() == expected.get("code")
        )
        if not code_ok:
            # 验证码验证失败，刷新验证码
            code = _generate_captcha_code(4)
            CAPTCHA_STORE[client_ip] = {
                "code": code,
                "expires_at": now + CAPTCHA_TTL_SECONDS
            }
            # 返回验证码错误
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="CAPTCHA_INCORRECT"
            )

    # 查询数据库，查找邮箱为 username 的用户
    statement = select(User).where(User.email == username)
    user = db.exec(statement).first()
    # 如果用户不存在或密码校验失败，抛出401异常
    if not user or not verify_password(password, user.hashed_password):
        # 记录失败
        ip_state["fail_count"] = int(ip_state.get("fail_count", 0)) + 1
        ip_state["last_fail_at"] = now
        # 达到阈值，要求验证码
        if ip_state["fail_count"] >= FAIL_THRESHOLD:
            ip_state["captcha_required_until"] = now + CAPTCHA_REQUIRE_SECONDS
            captcha_required = True

        # 如果已经需要验证码，每次登录失败时都刷新验证码
        if captcha_required:
            code = _generate_captcha_code(4)
            CAPTCHA_STORE[client_ip] = {
                "code": code,
                "expires_at": now + CAPTCHA_TTL_SECONDS
            }

        FAILED_LOGIN_BY_IP[client_ip] = ip_state
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )

    # 创建JWT token，包含用户id、邮箱和是否为管理员的信息
    token = create_access_token(
        data={"sub": str(user.id), "email": user.email, "is_admin": user.is_admin},
        secret_key=settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
        expires_minutes=settings.jwt_expires_minutes,
    )
    # 登录成功后，清理该 IP 的失败计数与验证码
    FAILED_LOGIN_BY_IP.pop(client_ip, None)
    CAPTCHA_STORE.pop(client_ip, None)
    # 返回token和token类型
    return {"access_token": token, "token_type": "bearer"}


def _generate_captcha_code(length: int = 4) -> str:
    return "".join(random.choices(string.digits, k=length))


def _render_captcha_image(code: str) -> bytes:
    # 延迟导入 Pillow，避免未安装时报错影响其它模块加载
    from PIL import Image, ImageDraw, ImageFont, ImageFilter

    width, height = 120, 40
    image = Image.new("RGB", (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(image)

    # 背景噪点
    for _ in range(200):
        x = random.randint(0, width - 1)
        y = random.randint(0, height - 1)
        draw.point((x, y), fill=(random.randint(150, 255), random.randint(150, 255), random.randint(150, 255)))

    # 干扰线
    for _ in range(6):
        start = (random.randint(0, width // 2), random.randint(0, height))
        end = (random.randint(width // 2, width), random.randint(0, height))
        draw.line([start, end], fill=(random.randint(0, 150), random.randint(0, 150), random.randint(0, 150)), width=1)

    # 字体
    try:
        font = ImageFont.truetype("arial.ttf", 26)
    except Exception:
        font = ImageFont.load_default()

    # 绘制每个字符，加入轻微随机偏移与旋转可以进一步加大难度（此处控制简单）
    char_w = width // (len(code) + 1)
    for i, ch in enumerate(code):
        x = 10 + i * char_w + random.randint(-2, 2)
        y = random.randint(4, 10)
        draw.text((x, y), ch, font=font, fill=(random.randint(0, 100), random.randint(0, 100), random.randint(0, 100)))

    # 模糊处理，增加 OCR 难度
    image = image.filter(ImageFilter.GaussianBlur(radius=0.5))

    buf = io.BytesIO()
    image.save(buf, format="PNG")
    return buf.getvalue()


@router.get("/captcha")
def get_captcha(request: Request):
    client_ip = request.client.host if request.client else "unknown"
    code = _generate_captcha_code(4)
    CAPTCHA_STORE[client_ip] = {"code": code, "expires_at": time.time() + CAPTCHA_TTL_SECONDS}
    img_bytes = _render_captcha_image(code)
    return StreamingResponse(io.BytesIO(img_bytes), media_type="image/png")

# 获取当前用户，依赖于oauth2_scheme和数据库会话
def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> UserRead:
    # 解码token，获取payload
    payload = decode_token(token, secret_key=settings.jwt_secret, algorithm=settings.jwt_algorithm)
    if payload is None:
        # token无效，抛出401异常
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    # 从payload中获取用户id
    user_id: Optional[int] = int(payload.get("sub")) if payload.get("sub") else None
    if user_id is None:
        # token中没有用户id，抛出401异常
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    # 根据用户id从数据库获取用户
    user = db.get(User, user_id)

    if not user:
        # 用户不存在，抛出401异常
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    # 使用 UserRead 模型，自动排除 hashed_password 字段
    return UserRead.model_validate(user)

# 获取当前管理员用户，依赖于get_current_user
def get_current_admin(user: UserRead = Depends(get_current_user)) -> UserRead:
    # 如果用户不是管理员，抛出403异常
    if not user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin only")
    return user


def get_current_user_optional(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> Optional[UserRead]:
    """获取当前用户（可选），如果没有token或token无效则返回None"""
    if not authorization or not authorization.startswith("Bearer "):
        return None

    token = authorization.split(" ")[1]

    try:
        # 解码token，获取payload
        payload = decode_token(token, secret_key=settings.jwt_secret, algorithm=settings.jwt_algorithm)
        if payload is None:
            return None

        # 从payload中获取用户id
        user_id: Optional[int] = int(payload.get("sub")) if payload.get("sub") else None
        if user_id is None:
            return None

        # 根据用户id从数据库获取用户
        user = db.get(User, user_id)
        if not user:
            return None

        # 使用 UserRead 模型，自动排除 hashed_password 字段
        return UserRead.model_validate(user)
    except Exception:
        # 任何异常都返回None，不抛出错误
        return None


# 获取当前用户信息的接口
@router.get("/me")
def get_me(current_user: UserRead = Depends(get_current_user)) -> UserRead:
    """获取当前用户信息"""
    return current_user


# 获取用户头像的接口
@router.get("/avatar")
def get_user_avatar(
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> dict:
    """获取用户头像（智能获取：个人信息表优先，否则使用系统默认头像）"""
    # 首先尝试从用户个人信息表获取头像
    user_profile_query = select(UserProfile).where(
        UserProfile.user_id == current_user.id
    )
    user_profile = db.exec(user_profile_query).first()
    user_avatar = (
        user_profile.avatar if user_profile and user_profile.avatar else None
    )

    # 查询系统默认头像
    default_avatar_query = select(SystemDefault).where(
        SystemDefault.category == "user",
        SystemDefault.key_name == "default_avatar"
    )
    default_avatar_record = db.exec(default_avatar_query).first()
    default_avatar_url = (
        default_avatar_record.key_value
        if default_avatar_record
        else "https://via.placeholder.com/150x150/87ceeb/ffffff?text=Avatar"
    )

    # 如果用户有自定义头像，使用自定义头像；否则使用默认头像
    final_avatar = user_avatar if user_avatar else default_avatar_url

    return {
        "avatar_url": final_avatar,
        "is_default": user_avatar is None,
        "source": "user_profile" if user_avatar else "system_default"
    }
