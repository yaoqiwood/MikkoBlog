from datetime import datetime
from typing import Optional, List, TYPE_CHECKING

from sqlmodel import Field, SQLModel, Relationship

if TYPE_CHECKING:
    from app.models.post import Post
    from app.models.moments import Moments


class UserBase(SQLModel):
    email: str
    full_name: Optional[str] = None
    is_active: bool = True
    is_admin: bool = False


class User(UserBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系 - 暂时注释掉以避免循环导入
    # uploaded_music: List["LocalMusic"] = Relationship(back_populates="upload_user")


class UserCreate(SQLModel):
    email: str
    full_name: Optional[str] = None
    password: str


class UserRead(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime


class UserUpdate(SQLModel):
    email: Optional[str] = None
    full_name: Optional[str] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None
    is_admin: Optional[bool] = None


# 用户个人资料（与 user_profiles 表对应）
class UserProfileBase(SQLModel):
    nickname: Optional[str] = None
    email: Optional[str] = None
    bio: Optional[str] = None
    avatar: Optional[str] = None
    blog_title: Optional[str] = None
    blog_subtitle: Optional[str] = None
    motto: Optional[str] = None
    github_url: Optional[str] = None
    twitter_url: Optional[str] = None
    weibo_url: Optional[str] = None
    website_url: Optional[str] = None


class UserProfile(UserProfileBase, table=True):
    __tablename__ = "user_profiles"
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(index=True, nullable=False)
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系 - 暂时注释掉以避免循环导入
    # posts: List["Post"] = Relationship(back_populates="author")
    # moments: List["Moments"] = Relationship(back_populates="author")


class UserProfileRead(UserProfileBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime


class UserProfileUpdate(UserProfileBase):
    pass
