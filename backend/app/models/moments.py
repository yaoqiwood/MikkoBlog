from datetime import datetime
from typing import Optional, List

from sqlmodel import Field, SQLModel, Relationship


class MomentsBase(SQLModel):
    content: str = Field(
        max_length=150, description="说说内容，最多150字"
    )
    is_visible: bool = Field(default=True, description="是否可见")
    is_deleted: bool = Field(default=False, description="是否已删除")
    user_id: int = Field(
        foreign_key="user_profiles.user_id", description="发布用户ID"
    )


class Moments(MomentsBase, table=True):
    __tablename__ = "moments"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系
    # author: Optional["UserProfile"] = Relationship(
    #     back_populates="moments"
    # )  # 暂时注释掉以避免循环导入
    images: List["MomentsImages"] = Relationship(back_populates="moment")


class MomentsImages(SQLModel, table=True):
    __tablename__ = "moments_images"

    id: Optional[int] = Field(default=None, primary_key=True)
    moment_id: int = Field(foreign_key="moments.id", description="说说ID")
    attachment_id: int = Field(
        foreign_key="attachments.id", description="图片附件ID"
    )
    sort_order: int = Field(default=0, description="图片排序")
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )

    # 关联关系
    moment: Optional["Moments"] = Relationship(back_populates="images")


class MomentsCreate(SQLModel):
    content: str = Field(
        max_length=150, description="说说内容，最多150字"
    )
    image_ids: Optional[List[int]] = Field(
        default=None, description="图片ID列表"
    )


class MomentsRead(MomentsBase):
    id: int
    created_at: datetime
    updated_at: datetime
    # 用户信息
    user_nickname: Optional[str] = None
    user_avatar: Optional[str] = None
    # 图片信息
    images: Optional[List[dict]] = None


class MomentsUpdate(SQLModel):
    content: Optional[str] = Field(
        default=None, max_length=150, description="说说内容"
    )
    is_visible: Optional[bool] = None
    is_deleted: Optional[bool] = None
    image_ids: Optional[List[int]] = Field(
        default=None, description="图片ID列表"
    )


class MomentsListResponse(SQLModel):
    items: List[MomentsRead]
    total: int
    page: int
    limit: int
    has_more: bool
