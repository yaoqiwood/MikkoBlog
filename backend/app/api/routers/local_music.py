# backend/app/api/routers/local_music.py
import os
import uuid
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlmodel import Session, select, func

from app.db.session import get_db
from app.models.local_music import LocalMusic, MusicPlaylist, PlaylistMusic
from app.models.user import User
from app.models.system_setting import SystemSetting, SettingType
from app.api.routers.auth import get_current_user

router = APIRouter(tags=["local-music"])

# 支持的音乐格式
ALLOWED_FORMATS = {'.mp3', '.wav', '.ogg', '.m4a', '.flac'}
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB


@router.post("/upload")
async def upload_music(
    file: UploadFile = File(...),
    title: str = Form(...),
    artist: Optional[str] = Form(None),
    album: Optional[str] = Form(None),
    genre: Optional[str] = Form(None),
    year: Optional[str] = Form(None),
    lyrics: Optional[str] = Form(None),
    cover_image: Optional[UploadFile] = File(None),
    playlist_id: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """上传音乐文件"""

    # 检查文件格式
    file_extension = os.path.splitext(file.filename)[1].lower()
    if file_extension not in ALLOWED_FORMATS:
        raise HTTPException(
            status_code=400,
            detail=f"不支持的文件格式。支持的格式: {', '.join(ALLOWED_FORMATS)}"
        )

    # 检查文件大小
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"文件太大。最大支持 {MAX_FILE_SIZE // (1024*1024)}MB"
        )

    # 生成唯一文件名
    file_id = str(uuid.uuid4())
    file_extension = os.path.splitext(file.filename)[1].lower()
    filename = f"{file_id}{file_extension}"

    # 创建上传目录
    upload_dir = "uploads/music"
    os.makedirs(upload_dir, exist_ok=True)
    file_path = os.path.join(upload_dir, filename)

    try:
        # 保存音乐文件
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)

        # 处理年份字段
        year_value = None
        if year and year.strip():
            try:
                year_value = int(year)
            except ValueError:
                year_value = None

        # 创建数据库记录
        music = LocalMusic(
            title=title,
            artist=artist or "未知艺术家",
            album=album,
            genre=genre,
            year=year_value,
            lyrics=lyrics,
            file_url=f"/uploads/music/{filename}",
            duration=180,  # 默认3分钟，后续可以从文件元数据获取
        )

        db.add(music)
        db.commit()
        db.refresh(music)

        # 处理封面图片
        if cover_image:
            cover_id = str(uuid.uuid4())
            cover_extension = os.path.splitext(cover_image.filename)[1].lower()
            cover_filename = f"{cover_id}{cover_extension}"
            cover_path = os.path.join(upload_dir, cover_filename)

            with open(cover_path, "wb") as buffer:
                cover_content = await cover_image.read()
                buffer.write(cover_content)

            music.cover_image_url = f"/uploads/music/{cover_filename}"
            db.commit()

        # 如果指定了播放列表，添加到播放列表中
        playlist_added = False
        if playlist_id and playlist_id.strip():
            try:
                playlist_id_int = int(playlist_id)
                playlist = db.get(MusicPlaylist, playlist_id_int)
                if playlist and playlist.is_active:
                    # 检查是否已经在播放列表中
                    existing = db.exec(
                        select(PlaylistMusic).where(
                            PlaylistMusic.playlist_id == playlist_id_int,
                            PlaylistMusic.track_id == music.id
                        )
                    ).first()

                    if not existing:
                        playlist_music = PlaylistMusic(
                            playlist_id=playlist_id_int,
                            track_id=music.id,
                            position=0
                        )
                        db.add(playlist_music)
                        db.commit()
                        playlist_added = True
                        print(
                            f"DEBUG: 音乐 {music.id} 已添加到播放列表 {playlist_id_int}"
                        )
                    else:
                        print(
                            f"DEBUG: 音乐 {music.id} 已在播放列表 {playlist_id_int} 中"
                        )
            except ValueError:
                print(f"DEBUG: 无效的播放列表ID: {playlist_id}")

        return {
            "id": music.id,
            "title": music.title,
            "artist": music.artist,
            "album": music.album,
            "genre": music.genre,
            "year": music.year,
            "file_url": music.file_url,
            "cover_image_url": music.cover_image_url,
            "playlist_added": playlist_added
        }

    except Exception as e:
        # 如果数据库操作失败，删除已上传的文件
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"上传失败: {str(e)}")


@router.get("/list")
async def get_music_list(
    page: int = 1,
    page_size: int = 20,
    search: Optional[str] = None,
    genre: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取音乐列表"""

    # 构建查询
    query = select(LocalMusic).where(LocalMusic.is_active.is_(True))

    # 搜索过滤
    if search:
        query = query.where(
            LocalMusic.title.contains(search) |
            LocalMusic.artist.contains(search) |
            LocalMusic.album.contains(search)
        )

    # 类型过滤
    if genre:
        query = query.where(LocalMusic.genre == genre)

    # 分页
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)

    musics = db.exec(query).all()

    return {
        "musics": musics,
        "page": page,
        "page_size": page_size,
        "total": len(musics)
    }


@router.get("/{music_id}")
async def get_music_detail(
    music_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取音乐详情"""

    music = db.get(LocalMusic, music_id)
    if not music or not music.is_active:
        raise HTTPException(status_code=404, detail="音乐不存在")

    return music


@router.get("/{music_id}/file")
async def get_music_file(
    music_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取音乐文件URL"""

    music = db.get(LocalMusic, music_id)
    if not music or not music.is_active:
        raise HTTPException(status_code=404, detail="音乐不存在")

    # 直接返回文件URL，不检查文件是否存在（前端会处理404）
    if not music.file_url:
        raise HTTPException(status_code=404, detail="音乐文件URL无效")

    return {
        "file_url": music.file_url,
        "file_size": 0,  # 暂时返回0，后续可以添加文件大小字段
        "file_format": os.path.splitext(music.file_url)[1].lower()
    }


@router.get("/settings/auto-play")
async def get_auto_play_setting(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取自动播放设置"""

    # 查询自动播放设置
    statement = select(SystemSetting).where(
        SystemSetting.category == "music",
        SystemSetting.key_name == "auto_play"
    )
    setting = db.exec(statement).first()

    if not setting:
        # 如果不存在，创建默认设置
        setting = SystemSetting(
            category="music",
            key_name="auto_play",
            key_value="false",
            key_type=SettingType.boolean,
            description="进入博客时是否自动播放音乐",
            is_editable=True,
            is_public=True
        )
        db.add(setting)
        db.commit()
        db.refresh(setting)

    return {
        "auto_play": setting.key_value.lower() == "true"
    }


@router.put("/settings/auto-play")
async def update_auto_play_setting(
    auto_play: bool,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """更新自动播放设置"""

    # 查询或创建自动播放设置
    statement = select(SystemSetting).where(
        SystemSetting.category == "music",
        SystemSetting.key_name == "auto_play"
    )
    setting = db.exec(statement).first()

    if not setting:
        setting = SystemSetting(
            category="music",
            key_name="auto_play",
            key_value=str(auto_play).lower(),
            key_type=SettingType.boolean,
            description="进入博客时是否自动播放音乐",
            is_editable=True,
            is_public=True
        )
        db.add(setting)
    else:
        setting.key_value = str(auto_play).lower()
        setting.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(setting)

    return {
        "auto_play": auto_play,
        "message": "自动播放设置已更新"
    }


@router.get("/settings/public-playlist")
async def get_public_playlist(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取公开的播放列表（用于博客首页播放）"""

    # 查询公开的播放列表
    statement = select(MusicPlaylist).where(
        MusicPlaylist.is_public.is_(True),
        MusicPlaylist.is_active.is_(True)
    )
    public_playlist = db.exec(statement).first()

    if not public_playlist:
        return {
            "playlist": None,
            "message": "没有公开的播放列表"
        }

    # 获取播放列表中的音乐
    playlist_musics_statement = select(PlaylistMusic, LocalMusic).join(
        LocalMusic, PlaylistMusic.track_id == LocalMusic.id
    ).where(
        PlaylistMusic.playlist_id == public_playlist.id,
        LocalMusic.is_active.is_(True)
    ).order_by(PlaylistMusic.position)

    playlist_musics = db.exec(playlist_musics_statement).all()

    musics = []
    for playlist_music, music in playlist_musics:
        musics.append({
            "id": music.id,
            "title": music.title,
            "artist": music.artist,
            "album": music.album,
            "duration": music.duration,
            "file_url": music.file_url,
            "cover_image_url": music.cover_image_url,
            "genre": music.genre,
            "year": music.year
        })

    return {
        "playlist": {
            "id": public_playlist.id,
            "name": public_playlist.name,
            "description": public_playlist.description,
            "cover_image_url": public_playlist.cover_image_url,
            "music_count": len(musics),
            "musics": musics
        }
    }


@router.delete("/{music_id}")
async def delete_music(
    music_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """删除音乐"""

    music = db.get(LocalMusic, music_id)
    if not music:
        raise HTTPException(status_code=404, detail="音乐不存在")

    # 软删除
    music.is_active = False
    db.commit()

    # 删除文件
    if music.file_url:
        file_path = music.file_url.lstrip('/')
        if os.path.exists(file_path):
            try:
                os.remove(file_path)
            except Exception as e:
                print(f"删除文件失败: {e}")

    return {"message": "音乐删除成功"}


# 播放列表相关API
@router.get("/playlists/list")
async def get_playlists(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取播放列表"""

    playlists = db.exec(
        select(MusicPlaylist).where(MusicPlaylist.is_active.is_(True))
    ).all()

    # 为每个播放列表计算音乐数量并创建包含music_count的字典
    playlists_with_count = []
    for playlist in playlists:
        music_count = db.exec(
            select(func.count(PlaylistMusic.id)).where(
                PlaylistMusic.playlist_id == playlist.id
            )
        ).first()

        playlist_dict = {
            "id": playlist.id,
            "name": playlist.name,
            "description": (
                playlist.description
                if playlist.description and playlist.description != "null"
                else ""
            ),
            "cover_image_url": playlist.cover_image_url,
            "is_public": playlist.is_public,
            "is_active": playlist.is_active,
            "user_id": playlist.user_id,
            "created_at": playlist.created_at,
            "updated_at": playlist.updated_at,
            "music_count": music_count or 0
        }
        playlists_with_count.append(playlist_dict)

    return {"playlists": playlists_with_count}


@router.post("/playlists")
async def create_playlist(
    name: str = Form(...),
    description: Optional[str] = Form(None),
    is_public: str = Form("false"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """创建播放列表"""

    # 将字符串转换为布尔值
    is_public_bool = is_public.lower() in ("true", "1", "yes", "on")

    # 如果设置为公开，需要先将其他公开的播放列表设为私有
    if is_public_bool:
        other_public_playlists = db.exec(
            select(MusicPlaylist).where(
                MusicPlaylist.is_public.is_(True),
                MusicPlaylist.is_active.is_(True)
            )
        ).all()

        for other_playlist in other_public_playlists:
            other_playlist.is_public = False
            other_playlist.updated_at = datetime.utcnow()

    playlist = MusicPlaylist(
        name=name,
        description=description or "",
        is_public=is_public_bool,
        user_id=current_user.id
    )

    db.add(playlist)
    db.commit()
    db.refresh(playlist)

    return playlist


@router.put("/playlists/{playlist_id}")
async def update_playlist(
    playlist_id: int,
    name: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    is_public: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """更新播放列表"""

    playlist = db.get(MusicPlaylist, playlist_id)
    if not playlist:
        raise HTTPException(status_code=404, detail="播放列表不存在")

    if name is not None:
        playlist.name = name
    if description is not None:
        playlist.description = description or ""
    if is_public is not None:
        # 将字符串转换为布尔值
        new_is_public = is_public.lower() in ("true", "1", "yes", "on")

        # 如果设置为公开，需要先将其他公开的播放列表设为私有
        if new_is_public:
            other_public_playlists = db.exec(
                select(MusicPlaylist).where(
                    MusicPlaylist.is_public.is_(True),
                    MusicPlaylist.is_active.is_(True),
                    MusicPlaylist.id != playlist_id
                )
            ).all()

            for other_playlist in other_public_playlists:
                other_playlist.is_public = False
                other_playlist.updated_at = datetime.utcnow()

        playlist.is_public = new_is_public

    playlist.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(playlist)

    return playlist


@router.delete("/playlists/{playlist_id}")
async def delete_playlist(
    playlist_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """删除播放列表"""

    playlist = db.get(MusicPlaylist, playlist_id)
    if not playlist:
        raise HTTPException(status_code=404, detail="播放列表不存在")

    # 软删除
    playlist.is_active = False
    db.commit()

    return {"message": "播放列表删除成功"}


@router.get("/playlists/{playlist_id}/musics")
async def get_playlist_musics(
    playlist_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """获取播放列表中的音乐"""

    playlist = db.get(MusicPlaylist, playlist_id)
    if not playlist or not playlist.is_active:
        raise HTTPException(status_code=404, detail="播放列表不存在")

    # 获取播放列表中的音乐
    playlist_musics_statement = select(PlaylistMusic, LocalMusic).join(
        LocalMusic, PlaylistMusic.track_id == LocalMusic.id
    ).where(
        PlaylistMusic.playlist_id == playlist_id,
        LocalMusic.is_active.is_(True)
    ).order_by(PlaylistMusic.position)

    playlist_musics = db.exec(playlist_musics_statement).all()

    musics = []
    for playlist_music, music in playlist_musics:
        musics.append({
            "id": music.id,
            "title": music.title,
            "artist": music.artist,
            "album": music.album,
            "duration": music.duration,
            "file_url": music.file_url,
            "cover_image_url": music.cover_image_url,
            "genre": music.genre,
            "year": music.year
        })

    return {"musics": musics}


@router.post("/playlists/{playlist_id}/add")
async def add_music_to_playlist(
    playlist_id: int,
    music_id: int = Form(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """添加音乐到播放列表"""

    playlist = db.get(MusicPlaylist, playlist_id)
    if not playlist or not playlist.is_active:
        raise HTTPException(status_code=404, detail="播放列表不存在")

    music = db.get(LocalMusic, music_id)
    if not music or not music.is_active:
        raise HTTPException(status_code=404, detail="音乐不存在")

    # 检查是否已经在播放列表中
    existing = db.exec(
        select(PlaylistMusic).where(
            PlaylistMusic.playlist_id == playlist_id,
            PlaylistMusic.track_id == music_id
        )
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="音乐已在播放列表中")

    playlist_music = PlaylistMusic(
        playlist_id=playlist_id,
        track_id=music_id,
        position=0
    )

    db.add(playlist_music)
    db.commit()

    return {"message": "音乐已添加到播放列表"}


@router.delete("/playlists/{playlist_id}/musics/{music_id}")
async def remove_music_from_playlist(
    playlist_id: int,
    music_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """从播放列表中移除音乐"""

    playlist_music = db.exec(
        select(PlaylistMusic).where(
            PlaylistMusic.playlist_id == playlist_id,
            PlaylistMusic.track_id == music_id
        )
    ).first()

    if not playlist_music:
        raise HTTPException(status_code=404, detail="音乐不在播放列表中")

    db.delete(playlist_music)
    db.commit()

    return {"message": "音乐已从播放列表移除"}
