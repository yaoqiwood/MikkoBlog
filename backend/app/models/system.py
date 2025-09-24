from datetime import datetime
from typing import Optional
from enum import Enum

from sqlmodel import Field, SQLModel


class DataType(str, Enum):
    STRING = "string"
    NUMBER = "number"
    BOOLEAN = "boolean"
    JSON = "json"
    URL = "url"


class SystemDefaultBase(SQLModel):
    category: str
    key_name: str
    key_value: Optional[str] = None
    description: Optional[str] = None
    data_type: DataType = DataType.STRING
    is_editable: bool = True
    is_public: bool = False
    sort_order: int = 0


class SystemDefault(SystemDefaultBase, table=True):
    __tablename__ = "system_defaults"
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)


class SystemDefaultRead(SystemDefaultBase):
    id: int
    created_at: datetime
    updated_at: datetime


class SystemDefaultUpdate(SQLModel):
    key_value: Optional[str] = None
    description: Optional[str] = None
    is_editable: Optional[bool] = None
    is_public: Optional[bool] = None
    sort_order: Optional[int] = None


class SystemDefaultCreate(SystemDefaultBase):
    pass
