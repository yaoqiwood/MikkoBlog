from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.post import Post


class CommentBase(SQLModel):
    """评论基础模型"""
    content: str = Field(description="评论内容")
    author_name: str = Field(description="评论者姓名")
    author_email: Optional[str] = Field(default=None, description="评论者邮箱")
    author_website: Optional[str] = Field(default=None, description="评论者网站")
    ip_address: Optional[str] = Field(default=None, description="IP地址")
    location: Optional[str] = Field(default=None, description="地域信息")
    user_agent: Optional[str] = Field(default=None, description="用户代理")
    is_approved: bool = Field(default=False, description="是否审核通过")
    is_visible: bool = Field(default=True, description="是否可见")
    is_deleted: bool = Field(default=False, description="是否删除（软删除）")
    parent_id: Optional[int] = Field(default=None, foreign_key="comment.id", description="父评论ID（用于回复）")
    post_id: int = Field(foreign_key="post.id", description="关联的文章ID")


class CommentCreate(CommentBase):
    """创建评论模型"""
    pass


class CommentUpdate(SQLModel):
    """更新评论模型"""
    content: Optional[str] = None
    author_name: Optional[str] = None
    author_email: Optional[str] = None
    author_website: Optional[str] = None
    is_approved: Optional[bool] = None
    is_visible: Optional[bool] = None
    is_deleted: Optional[bool] = None


class CommentRead(CommentBase):
    """读取评论模型"""
    id: int
    created_at: datetime
    updated_at: datetime
    post_id: int
    parent_id: Optional[int] = None

    class Config:
        from_attributes = True


class Comment(CommentBase, table=True):
    """评论数据库表"""
    __tablename__ = "comment"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # 关联关系
    post: Optional["Post"] = Relationship(back_populates="comments")
    parent: Optional["Comment"] = Relationship(
        back_populates="replies",
        sa_relationship_kwargs={"remote_side": "Comment.id"}
    )
    replies: List["Comment"] = Relationship(back_populates="parent")
