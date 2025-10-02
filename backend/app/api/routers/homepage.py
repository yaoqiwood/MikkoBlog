from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.homepage import (
    HomePageSettings,
    HomePageSettingsRead,
    HomePageSettingsUpdate,
)
from app.models.system import SystemDefault


router = APIRouter(prefix="/homepage", tags=["homepage"])


@router.get("/settings", response_model=HomePageSettingsRead)
def get_homepage_settings(
    db: Session = Depends(get_db)
) -> HomePageSettingsRead:
    settings = db.exec(select(HomePageSettings)).first()
    if not settings:
        # 若不存在，创建默认记录
        settings = HomePageSettings()
        db.add(settings)
        db.commit()
        db.refresh(settings)
    return HomePageSettingsRead.model_validate(settings)


@router.put("/settings", response_model=HomePageSettingsRead)
def update_homepage_settings(
    payload: HomePageSettingsUpdate,
    _: Optional[object] = Depends(get_current_admin),
    db: Session = Depends(get_db),
) -> HomePageSettingsRead:
    settings = db.exec(select(HomePageSettings)).first()
    if not settings:
        settings = HomePageSettings()

    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(settings, key, value)
    settings.updated_at = datetime.utcnow()

    db.add(settings)
    db.commit()
    db.refresh(settings)

    # 同步到 system_defaults
    sync_system_defaults(db, settings)

    return HomePageSettingsRead.model_validate(settings)


def upsert_default(
    db: Session,
    category: str,
    key: str,
    value: Optional[str],
    data_type: str = "string",
):
    record = db.exec(
        select(SystemDefault).where(
            SystemDefault.category == category,
            SystemDefault.key_name == key,
        )
    ).first()
    if record:
        record.key_value = str(value) if value is not None else None
        record.updated_at = datetime.utcnow()
        db.add(record)
    else:
        record = SystemDefault(
            category=category,
            key_name=key,
            key_value=str(value) if value is not None else None,
            description=f"homepage setting {key}",
            data_type=data_type,
            is_editable=1,
            is_public=1,
            sort_order=0,
        )
        db.add(record)
    db.commit()


def sync_system_defaults(db: Session, settings: HomePageSettings) -> None:
    upsert_default(
        db, "homepage", "header_title", settings.header_title, "string"
    )
    upsert_default(
        db, "homepage", "banner_image_url", settings.banner_image_url, "url"
    )
    upsert_default(
        db,
        "homepage",
        "background_image_url",
        settings.background_image_url,
        "url",
    )
    upsert_default(
        db,
        "homepage",
        "show_music_player",
        str(int(settings.show_music_player)),
        "boolean",
    )
    upsert_default(db, "homepage", "music_url", settings.music_url, "url")
    upsert_default(
        db,
        "homepage",
        "show_live2d",
        str(int(settings.show_live2d)),
        "boolean",
    )
