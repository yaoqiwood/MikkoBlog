from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from passlib.context import CryptContext

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.user import User, UserRead, UserCreate, UserUpdate


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
