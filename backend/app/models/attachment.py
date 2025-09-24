from datetime import datetime
from typing import Optional
from enum import Enum

from sqlmodel import Field, SQLModel


class FileCategory(str, Enum):
    IMAGE = "image"
    DOCUMENT = "document"
    VIDEO = "video"
    AUDIO = "audio"
    OTHER = "other"


class AttachmentStatus(str, Enum):
    ACTIVE = "active"
    DELETED = "deleted"
    HIDDEN = "hidden"


class AttachmentBase(SQLModel):
    filename: str
    original_name: str
    file_path: str
    file_url: str
    file_size: int
    file_type: str
    file_extension: str
    file_category: FileCategory = FileCategory.IMAGE
    width: Optional[int] = None
    height: Optional[int] = None
    alt_text: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[str] = None
    is_public: bool = True
    is_featured: bool = False
    download_count: int = 0
    view_count: int = 0
    uploaded_by: int
    related_type: Optional[str] = None
    related_id: Optional[int] = None
    status: AttachmentStatus = AttachmentStatus.ACTIVE


class Attachment(AttachmentBase, table=True):
    __tablename__ = "attachments"
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    deleted_at: Optional[datetime] = None


class AttachmentRead(AttachmentBase):
    id: int
    created_at: datetime
    updated_at: datetime
    deleted_at: Optional[datetime] = None


class AttachmentCreate(AttachmentBase):
    pass


class AttachmentUpdate(SQLModel):
    filename: Optional[str] = None
    original_name: Optional[str] = None
    file_path: Optional[str] = None
    file_url: Optional[str] = None
    file_size: Optional[int] = None
    file_type: Optional[str] = None
    file_extension: Optional[str] = None
    file_category: Optional[FileCategory] = None
    width: Optional[int] = None
    height: Optional[int] = None
    alt_text: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[str] = None
    is_public: Optional[bool] = None
    is_featured: Optional[bool] = None
    related_type: Optional[str] = None
    related_id: Optional[int] = None
    status: Optional[AttachmentStatus] = None


class AttachmentSearch(SQLModel):
    file_category: Optional[FileCategory] = None
    file_type: Optional[str] = None
    is_public: Optional[bool] = None
    is_featured: Optional[bool] = None
    status: Optional[AttachmentStatus] = None
    uploaded_by: Optional[int] = None
    related_type: Optional[str] = None
    related_id: Optional[int] = None
    tags: Optional[str] = None
    search: Optional[str] = None  # 搜索文件名、标题、描述
    page: int = 1
    page_size: int = 20
