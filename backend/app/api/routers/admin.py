from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.user import User, UserRead


router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/users")
def list_users(_: UserRead = Depends(get_current_admin), db: Session = Depends(get_db)) -> list[UserRead]:
    """需要管理员权限的用户列表接口"""
    users = db.exec(select(User)).all()
    return [UserRead.model_validate(user) for user in users]


@router.get("/users-public")
def list_users_public(db: Session = Depends(get_db)) -> list[User]:
    """不需要权限验证的用户列表接口（仅用于演示）"""
    return db.exec(select(User)).all()
