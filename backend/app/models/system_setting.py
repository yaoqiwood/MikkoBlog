from datetime import datetime
from typing import Optional, Any
from enum import Enum

from sqlmodel import Field, SQLModel, Column
from sqlalchemy import Enum as SQLEnum


class SettingType(str, Enum):
    string = "string"
    number = "number"
    boolean = "boolean"
    json = "json"
    url = "url"


class SystemSettingBase(SQLModel):
    category: str = Field(max_length=50, description="设置分类")
    key_name: str = Field(max_length=100, description="设置键名")
    key_value: Optional[str] = Field(default=None, description="设置值")
    key_type: SettingType = Field(default=SettingType.string, description="值类型")
    description: Optional[str] = Field(default=None, max_length=255, description="设置描述")
    is_editable: bool = Field(default=True, description="是否可编辑")
    is_public: bool = Field(default=False, description="是否公开")
    sort_order: int = Field(default=0, description="排序")


class SystemSetting(SystemSettingBase, table=True):
    __tablename__ = "system_setting"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, description="创建时间")
    updated_at: datetime = Field(default_factory=datetime.utcnow, description="更新时间")


class SystemSettingCreate(SystemSettingBase):
    pass


class SystemSettingRead(SystemSettingBase):
    id: int
    created_at: datetime
    updated_at: datetime


class SystemSettingUpdate(SQLModel):
    key_value: Optional[str] = None
    key_type: Optional[SettingType] = None
    description: Optional[str] = None
    is_editable: Optional[bool] = None
    is_public: Optional[bool] = None
    sort_order: Optional[int] = None


class SystemSettingBatchUpdate(SQLModel):
    """批量更新系统设置"""
    settings: list[dict] = Field(description="设置列表，格式：[{key_name: 'key', key_value: 'value'}]")


class AISettingConfig(SQLModel):
    """AI设置配置"""
    provider: str = Field(description="AI服务提供商")
    model: str = Field(description="AI模型名称")
    api_key: str = Field(description="AI API密钥")
    base_url: str = Field(description="AI API基础URL")
    max_tokens: int = Field(description="AI最大token数")
    temperature: float = Field(description="AI温度参数")
    prompt_template: str = Field(description="AI提示词模板")
    enabled: bool = Field(description="是否启用AI功能")
    timeout: int = Field(description="AI请求超时时间(秒)")
    retry_count: int = Field(description="AI请求重试次数")
