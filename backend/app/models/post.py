from datetime import datetime
from typing import Optional, List

from sqlmodel import Field, SQLModel, Relationship


class PostBase(SQLModel):
    title: str
    content: str
    summary: Optional[str] = None
    cover_image_url: Optional[str] = None
    is_published: bool = False
    is_deleted: bool = False
    is_visible: bool = True


class Post(PostBase, table=True):
    __tablename__ = "post"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

    # 关联关系
    comments: List["Comment"] = Relationship(back_populates="post")


class PostCreate(PostBase):
    pass


class PostRead(PostBase):
    id: int
    created_at: datetime
    updated_at: datetime


class PostUpdate(SQLModel):
    title: Optional[str] = None
    content: Optional[str] = None
    summary: Optional[str] = None
    cover_image_url: Optional[str] = None
    is_published: Optional[bool] = None
    is_deleted: Optional[bool] = None
    is_visible: Optional[bool] = None
