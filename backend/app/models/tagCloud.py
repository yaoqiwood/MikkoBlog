from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime, date
from enum import Enum


class TagSize(str, Enum):
    SMALL = "small"
    MEDIUM = "medium"
    LARGE = "large"


class TagSource(str, Enum):
    MANUAL = "manual"
    AUTO = "auto"
    TRENDING = "trending"


class FetchStatus(str, Enum):
    SUCCESS = "success"
    FAILED = "failed"
    PARTIAL = "partial"


class TagCloudBase(SQLModel):
    name: str = Field(max_length=100, description="标签名称")
    count: int = Field(default=1, description="使用次数")
    size: str = Field(default="medium", max_length=20, description="标签大小")
    color: str = Field(default="#ff6b6b", max_length=20, description="标签颜色")
    category: str = Field(default="general", max_length=50, description="标签分类")
    source: str = Field(default="manual", max_length=50, description="来源")
    is_active: bool = Field(default=True, description="是否激活")
    last_fetched_at: Optional[datetime] = Field(default=None, description="最后获取时间")


class TagCloud(TagCloudBase, table=True):
    __tablename__ = "tag_cloud"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, description="创建时间")
    updated_at: datetime = Field(default_factory=datetime.utcnow, description="更新时间")


class TagCloudCreate(TagCloudBase):
    pass


class TagCloudUpdate(SQLModel):
    name: Optional[str] = Field(default=None, max_length=100)
    count: Optional[int] = Field(default=None)
    size: Optional[str] = Field(default=None, max_length=20)
    color: Optional[str] = Field(default=None, max_length=20)
    category: Optional[str] = Field(default=None, max_length=50)
    source: Optional[str] = Field(default=None, max_length=50)
    is_active: Optional[bool] = Field(default=None)
    last_fetched_at: Optional[datetime] = Field(default=None)


class TagCloudRead(TagCloudBase):
    id: int
    created_at: datetime
    updated_at: datetime


class TagCloudFetchHistoryBase(SQLModel):
    fetch_date: date = Field(description="获取日期")
    source: str = Field(max_length=50, description="数据源")
    total_tags: int = Field(default=0, description="获取的标签总数")
    new_tags: int = Field(default=0, description="新增标签数")
    updated_tags: int = Field(default=0, description="更新标签数")
    status: str = Field(default="success", max_length=20, description="获取状态")
    error_message: Optional[str] = Field(default=None, description="错误信息")


class TagCloudFetchHistory(TagCloudFetchHistoryBase, table=True):
    __tablename__ = "tag_cloud_fetch_history"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, description="创建时间")


class TagCloudFetchHistoryCreate(TagCloudFetchHistoryBase):
    pass


class TagCloudFetchHistoryRead(TagCloudFetchHistoryBase):
    id: int
    created_at: datetime
