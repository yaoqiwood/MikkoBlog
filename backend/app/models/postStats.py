from datetime import datetime
from typing import Optional, TYPE_CHECKING

from sqlmodel import Field, SQLModel, Relationship

if TYPE_CHECKING:
    from app.models.post import Post


class PostStatsBase(SQLModel):
    post_id: int = Field(foreign_key="post.id")
    view_count: int = Field(default=0, description="观看次数")
    like_count: int = Field(default=0, description="点赞次数")
    share_count: int = Field(default=0, description="分享次数")
    comment_count: int = Field(default=0, description="评论次数")


class PostStats(PostStatsBase, table=True):
    __tablename__ = "post_stats"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系
    post: Optional["Post"] = Relationship(back_populates="stats")


class PostStatsCreate(PostStatsBase):
    pass


class PostStatsRead(PostStatsBase):
    id: int
    created_at: datetime
    updated_at: datetime


class PostStatsUpdate(SQLModel):
    view_count: Optional[int] = None
    like_count: Optional[int] = None
    share_count: Optional[int] = None
    comment_count: Optional[int] = None


class PostStatsIncrement(SQLModel):
    """用于增加统计数据的模型"""
    view_count: Optional[int] = Field(default=1, description="增加的观看次数")
    like_count: Optional[int] = Field(default=1, description="增加的点赞次数")
    share_count: Optional[int] = Field(default=1, description="增加的分享次数")
    comment_count: Optional[int] = Field(default=1, description="增加的评论次数")

