# backend/app/models/music.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime

class MusicPlaylistBase(SQLModel):
    name: str = Field(max_length=255, description="播放列表名称")
    description: Optional[str] = Field(default=None, description="播放列表描述")
    cover_image_url: Optional[str] = Field(default=None, max_length=500, description="封面图片URL")
    is_public: bool = Field(default=True, description="是否公开")
    is_active: bool = Field(default=True, description="是否启用")
    user_id: int = Field(description="创建用户ID")

class MusicPlaylist(MusicPlaylistBase, table=True):
    __tablename__ = "music_playlist"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # 关系
    tracks: List["PlaylistTrack"] = Relationship(back_populates="playlist")

class MusicTrackBase(SQLModel):
    title: str = Field(max_length=255, description="歌曲标题")
    artist: str = Field(max_length=255, description="艺术家")
    album: Optional[str] = Field(default=None, max_length=255, description="专辑名称")
    duration: Optional[int] = Field(default=None, description="时长(秒)")
    file_url: Optional[str] = Field(default=None, max_length=500, description="音频文件URL")
    stream_url: Optional[str] = Field(default=None, max_length=500, description="流媒体URL")
    cover_image_url: Optional[str] = Field(default=None, max_length=500, description="封面图片URL")
    lyrics: Optional[str] = Field(default=None, description="歌词")
    genre: Optional[str] = Field(default=None, max_length=100, description="音乐类型")
    year: Optional[int] = Field(default=None, description="发行年份")
    external_id: Optional[str] = Field(default=None, max_length=100, description="外部平台ID")
    platform: Optional[str] = Field(default=None, max_length=50, description="来源平台")
    is_active: bool = Field(default=True, description="是否启用")

class MusicTrack(MusicTrackBase, table=True):
    __tablename__ = "music_track"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # 关系
    playlists: List["PlaylistTrack"] = Relationship(back_populates="track")

class PlaylistTrackBase(SQLModel):
    playlist_id: int = Field(description="播放列表ID")
    track_id: int = Field(description="曲目ID")
    position: int = Field(default=0, description="在播放列表中的位置")

class PlaylistTrack(PlaylistTrackBase, table=True):
    __tablename__ = "playlist_track"

    id: Optional[int] = Field(default=None, primary_key=True)
    added_at: datetime = Field(default_factory=datetime.utcnow, description="添加到播放列表的时间")

    # 关系
    playlist: Optional[MusicPlaylist] = Relationship(back_populates="tracks")
    track: Optional[MusicTrack] = Relationship(back_populates="playlists")

class MusicPlayHistoryBase(SQLModel):
    user_id: int = Field(description="用户ID")
    track_id: int = Field(description="曲目ID")
    playlist_id: Optional[int] = Field(default=None, description="播放列表ID")
    duration_played: Optional[int] = Field(default=None, description="播放时长(秒)")
    is_completed: bool = Field(default=False, description="是否完整播放")

class MusicPlayHistory(MusicPlayHistoryBase, table=True):
    __tablename__ = "music_play_history"

    id: Optional[int] = Field(default=None, primary_key=True)
    played_at: datetime = Field(default_factory=datetime.utcnow, description="播放时间")

class MusicFavoriteBase(SQLModel):
    user_id: int = Field(description="用户ID")
    track_id: int = Field(description="曲目ID")

class MusicFavorite(MusicFavoriteBase, table=True):
    __tablename__ = "music_favorite"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
