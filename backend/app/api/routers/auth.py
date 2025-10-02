from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status, Header
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
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

# 登录接口，接收表单数据，返回access token
@router.post("/token")
def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
) -> dict:
    # 查询数据库，查找邮箱为form_data.username的用户
    statement = select(User).where(User.email == form_data.username)
    user = db.exec(statement).first()
    # 如果用户不存在或密码校验失败，抛出401异常
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")

    # 创建JWT token，包含用户id、邮箱和是否为管理员的信息
    token = create_access_token(
        data={"sub": str(user.id), "email": user.email, "is_admin": user.is_admin},
        secret_key=settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
        expires_minutes=settings.jwt_expires_minutes,
    )
    # 返回token和token类型
    return {"access_token": token, "token_type": "bearer"}

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
