from datetime import datetime
from typing import Optional, TYPE_CHECKING

from sqlmodel import Field, SQLModel, Relationship

if TYPE_CHECKING:
    from app.models.post import Post


class PostLikeTrackingBase(SQLModel):
    post_id: int = Field(description="文章ID")
    user_ip: str = Field(max_length=45, description="用户IP地址")
    created_at: datetime = Field(default_factory=datetime.utcnow, description="点赞时间")


class PostLikeTracking(PostLikeTrackingBase, table=True):
    __tablename__ = "post_like_tracking"

    id: Optional[int] = Field(default=None, primary_key=True, description="主键ID")


class PostLikeTrackingRead(PostLikeTrackingBase):
    id: int
    created_at: datetime
