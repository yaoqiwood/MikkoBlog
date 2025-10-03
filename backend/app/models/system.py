from datetime import datetime
from typing import Optional, Any
from enum import Enum

from sqlmodel import Field, SQLModel, Column
from sqlalchemy import Enum as SQLEnum


class DataType(str, Enum):
    string = "string"
    number = "number"
    boolean = "boolean"
    json = "json"
    url = "url"


class SystemDefaultBase(SQLModel):
    category: str
    key_name: str
    key_value: Optional[str] = None
    description: Optional[str] = None
    data_type: DataType = DataType.string
    is_editable: int = 1
    is_public: int = 0
    sort_order: int = 0


class SystemDefault(SystemDefaultBase, table=True):
    __tablename__ = "system_defaults"
    id: Optional[int] = Field(default=None, primary_key=True)
    data_type: DataType = Field(
        sa_column=Column(SQLEnum(DataType))
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )


class SystemDefaultRead(SystemDefaultBase):
    id: int
    created_at: datetime
    updated_at: datetime


class SystemDefaultUpdate(SQLModel):
    key_value: Optional[Any] = None
    description: Optional[str] = None
    data_type: Optional[DataType] = None
    is_editable: Optional[int] = None
    is_public: Optional[int] = None
    sort_order: Optional[int] = None


class SystemDefaultCreate(SystemDefaultBase):
    pass
