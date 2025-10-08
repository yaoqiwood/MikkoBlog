from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class HomePageSettingsBase(SQLModel):
    header_title: Optional[str] = None
    banner_image_url: Optional[str] = None
    background_image_url: Optional[str] = None
    show_music_player: bool = False
    music_url: Optional[str] = None
    show_live2d: bool = False
    welcome_modal_type: str = "bible"  # "bible" 或 "quotes"


class HomePageSettings(HomePageSettingsBase, table=True):
    __tablename__ = "home_page_settings"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow, nullable=False
    )


class HomePageSettingsRead(HomePageSettingsBase):
    id: int
    created_at: datetime
    updated_at: datetime


class HomePageSettingsUpdate(SQLModel):
    header_title: Optional[str] = None
    banner_image_url: Optional[str] = None
    background_image_url: Optional[str] = None
    show_music_player: Optional[bool] = None
    music_url: Optional[str] = None
    show_live2d: Optional[bool] = None
    welcome_modal_type: Optional[str] = None
