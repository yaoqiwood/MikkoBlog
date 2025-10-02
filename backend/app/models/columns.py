"""
专栏相关的数据模型
"""
from datetime import datetime
from typing import List, Optional

from sqlmodel import Field, Relationship, SQLModel


class ColumnsBase(SQLModel):
    """专栏基础模型"""
    name: str = Field(max_length=100, description="专栏名称")
    description: Optional[str] = Field(default=None, description="专栏描述")
    cover_image_url: Optional[str] = Field(
        default=None, max_length=255, description="专栏封面图片URL"
    )
    sort_order: int = Field(default=0, description="排序顺序，数字越小越靠前")
    is_visible: bool = Field(default=True, description="是否可见")
    is_deleted: bool = Field(default=False, description="是否已删除")
    user_id: int = Field(
        foreign_key="user_profiles.user_id", description="创建者用户ID"
    )
    post_count: int = Field(default=0, description="专栏文章数量")
    view_count: int = Field(default=0, description="专栏浏览量")


class Columns(ColumnsBase, table=True):
    """专栏表"""
    __tablename__ = "columns"

    id: Optional[int] = Field(
        default=None, primary_key=True, description="专栏ID"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False, description="创建时间"
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False, description="更新时间"
    )

    # 关联关系
    post_columns: List["PostColumns"] = Relationship(back_populates="column")


class ColumnsCreate(ColumnsBase):
    """创建专栏的请求模型"""
    pass


class ColumnsUpdate(SQLModel):
    """更新专栏的请求模型"""
    name: Optional[str] = Field(
        default=None, max_length=100, description="专栏名称"
    )
    description: Optional[str] = Field(default=None, description="专栏描述")
    cover_image_url: Optional[str] = Field(
        default=None, max_length=255, description="专栏封面图片URL"
    )
    sort_order: Optional[int] = Field(default=None, description="排序顺序")
    is_visible: Optional[bool] = Field(default=None, description="是否可见")


class ColumnsRead(ColumnsBase):
    """专栏读取响应模型"""
    id: int
    created_at: datetime
    updated_at: datetime

    # 扩展字段
    user_nickname: Optional[str] = Field(default=None, description="创建者昵称")
    posts: Optional[List[dict]] = Field(default=None, description="专栏文章列表")


class ColumnsListResponse(SQLModel):
    """专栏列表响应模型"""
    items: List[ColumnsRead]
    total: int
    page: int
    limit: int
    has_more: bool


# 文章专栏关联模型
class PostColumnsBase(SQLModel):
    """文章专栏关联基础模型"""
    post_id: int = Field(foreign_key="post.id", description="文章ID")
    column_id: int = Field(foreign_key="columns.id", description="专栏ID")
    sort_order: int = Field(default=0, description="在专栏中的排序顺序")


class PostColumns(PostColumnsBase, table=True):
    """文章专栏关联表"""
    __tablename__ = "post_columns"

    id: Optional[int] = Field(
        default=None, primary_key=True, description="关联ID"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False, description="创建时间"
    )

    # 关联关系
    column: Optional[Columns] = Relationship(back_populates="post_columns")


class PostColumnsCreate(PostColumnsBase):
    """创建文章专栏关联的请求模型"""
    pass


class PostColumnsRead(PostColumnsBase):
    """文章专栏关联读取响应模型"""
    id: int
    created_at: datetime
