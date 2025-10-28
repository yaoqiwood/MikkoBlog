from datetime import datetime
from typing import Optional, List, TYPE_CHECKING, Generic, TypeVar

from sqlmodel import Field, SQLModel, Relationship

if TYPE_CHECKING:
    from app.models.comment import Comment
# 因 UserProfile 未被使用，移除该导入
    from app.models.postStats import PostStats

T = TypeVar('T')


class PostBase(SQLModel):
    title: str
    content: str
    summary: Optional[str] = None
    cover_image_url: Optional[str] = None
    is_published: bool = False
    is_deleted: bool = False
    is_visible: bool = True
    user_id: int = Field(foreign_key="user_profiles.user_id")


class Post(PostBase, table=True):
    __tablename__ = "post"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系
    comments: List["Comment"] = Relationship(back_populates="post")
    # author: Optional["UserProfile"] = Relationship(back_populates="posts")
    # 暂时注释掉以避免循环导入
    stats: Optional["PostStats"] = Relationship(back_populates="post")


class PostCreate(PostBase):
    # 覆盖 user_id，使创建时不再强制要求前端传递
    user_id: Optional[int] = None


class PostRead(PostBase):
    id: int
    created_at: datetime
    updated_at: datetime
    # 用户信息字段
    user_nickname: Optional[str] = None
    user_avatar: Optional[str] = None
    # 统计数据字段
    view_count: Optional[int] = 0
    like_count: Optional[int] = 0
    share_count: Optional[int] = 0
    comment_count: Optional[int] = 0


class PostUpdate(SQLModel):
    title: Optional[str] = None
    content: Optional[str] = None
    summary: Optional[str] = None
    cover_image_url: Optional[str] = None
    is_published: Optional[bool] = None
    is_deleted: Optional[bool] = None
    is_visible: Optional[bool] = None


class PostListResponse(SQLModel, Generic[T]):
    items: List[T]
    total: int
    page: int
    limit: int
    has_more: bool
