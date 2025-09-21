from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.user import User


router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/users")
def list_users(_: User = Depends(get_current_admin), db: Session = Depends(get_db)) -> list[User]:
    return db.exec(select(User)).all()




