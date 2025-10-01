from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from passlib.context import CryptContext

from app.api.routers.auth import get_current_admin, get_current_user
from app.db.session import get_db
from app.models.user import (
    User,
    UserRead,
    UserCreate,
    UserUpdate,
    UserProfile,
    UserProfileRead,
    UserProfileUpdate,
)
from app.models.system import SystemDefault


router = APIRouter(prefix="/admin", tags=["admin"])

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


@router.get("/users")
def list_users(_: UserRead = Depends(get_current_admin), db: Session = Depends(get_db)) -> list[UserRead]:
    """需要管理员权限的用户列表接口"""
    users = db.exec(select(User)).all()
    return [UserRead.model_validate(user) for user in users]


@router.post("/users/add")
def add_user(
    user_data: UserCreate,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> UserRead:
    """添加新用户（需要管理员权限）"""
    # 检查邮箱是否已存在
    existing_user = db.exec(select(User).where(User.email == user_data.email)).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="邮箱地址已存在")

    # 加密密码
    hashed_password = pwd_context.hash(user_data.password)

    # 创建新用户
    db_user = User(
        email=user_data.email,
        full_name=user_data.full_name,
        hashed_password=hashed_password,
        is_active=True,
        is_admin=False
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return UserRead.model_validate(db_user)


@router.put("/users/{user_id}")
def update_user(
    user_id: int,
    user_data: UserUpdate,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> UserRead:
    """更新用户信息（需要管理员权限）"""
    # 查找用户
    user = db.exec(select(User).where(User.id == user_id)).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    # 如果更新邮箱，检查邮箱是否已被其他用户使用
    if user_data.email and user_data.email != user.email:
        existing_user = db.exec(select(User).where(User.email == user_data.email)).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="邮箱地址已被其他用户使用")

    # 更新用户信息
    update_data = user_data.model_dump(exclude_unset=True)

    # 如果更新密码，需要加密
    if "password" in update_data:
        update_data["hashed_password"] = pwd_context.hash(update_data.pop("password"))

    # 更新字段
    for field, value in update_data.items():
        setattr(user, field, value)

    db.add(user)
    db.commit()
    db.refresh(user)

    return UserRead.model_validate(user)


@router.get("/users-public")
def list_users_public(db: Session = Depends(get_db)) -> list[User]:
    """不需要权限验证的用户列表接口（仅用于演示）"""
    return db.exec(select(User)).all()


@router.get("/profiles/public/{user_id}", response_model=UserProfileRead)
def get_public_profile(user_id: int, db: Session = Depends(get_db)) -> UserProfileRead:
    """获取公开的用户资料（不需要登录）"""
    profile = db.exec(select(UserProfile).where(UserProfile.user_id == user_id)).first()
    if not profile:
        # 如果用户资料不存在，创建一个默认的
        user = db.get(User, user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        profile = UserProfile(
            user_id=user_id,
            email=user.email,
            nickname=user.full_name or "用户"
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)

    # 如果头像为空，从系统默认设置获取
    if not profile.avatar:
        default_avatar_query = select(SystemDefault).where(
            SystemDefault.category == "user",
            SystemDefault.key_name == "default_avatar"
        )
        default_avatar_record = db.exec(default_avatar_query).first()
        if default_avatar_record:
            profile.avatar = default_avatar_record.key_value
        else:
            # 如果系统默认头像也没有，使用占位符
            profile.avatar = (
                "https://via.placeholder.com/150x150/87ceeb/ffffff?text=Avatar"
            )

    return profile


# ========== 个人资料（当前登录用户） ==========
@router.get("/profiles/me", response_model=UserProfileRead)
def get_my_profile(
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = db.exec(select(UserProfile).where(UserProfile.user_id == current_user.id)).first()
    if not profile:
        profile = UserProfile(user_id=current_user.id, email=current_user.email, nickname=current_user.full_name)
        db.add(profile)
        db.commit()
        db.refresh(profile)
    return profile


@router.put("/profiles/me", response_model=UserProfileRead)
def update_my_profile(
    payload: UserProfileUpdate,
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = db.exec(select(UserProfile).where(UserProfile.user_id == current_user.id)).first()
    if not profile:
        profile = UserProfile(user_id=current_user.id)
        db.add(profile)
        db.commit()
        db.refresh(profile)

    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(profile, key, value)
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile
