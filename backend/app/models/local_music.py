# backend/app/models/local_music.py
from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class PlaylistMusic(SQLModel, table=True):
    __tablename__ = "playlist_track"
    id: Optional[int] = Field(default=None, primary_key=True)
    playlist_id: int = Field(foreign_key="music_playlist.id")
    track_id: int = Field(foreign_key="music_track.id")
    position: int = Field(default=0, description="在播放列表中的位置")
    added_at: datetime = Field(default_factory=datetime.now)


class LocalMusic(SQLModel, table=True):
    __tablename__ = "music_track"
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(max_length=255, description="歌曲标题")
    artist: str = Field(max_length=255, description="艺术家")
    album: Optional[str] = Field(
        default=None, max_length=255, description="专辑名称"
    )
    duration: Optional[int] = Field(default=None, description="时长(秒)")
    file_url: Optional[str] = Field(
        default=None, max_length=500, description="文件URL"
    )
    stream_url: Optional[str] = Field(
        default=None, max_length=500, description="流媒体URL"
    )
    cover_image_url: Optional[str] = Field(
        default=None, max_length=500, description="封面图片URL"
    )
    lyrics: Optional[str] = Field(default=None, description="歌词")
    genre: Optional[str] = Field(
        default=None, max_length=100, description="音乐类型"
    )
    year: Optional[int] = Field(default=None, description="发行年份")
    external_id: Optional[str] = Field(
        default=None, max_length=100, description="外部ID"
    )
    platform: Optional[str] = Field(
        default=None, max_length=50, description="平台"
    )
    is_active: bool = Field(default=True, description="是否启用")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(
        default_factory=datetime.now,
        sa_column_kwargs={"onupdate": datetime.now}
    )

    # playlists: List["MusicPlaylist"] = Relationship(
    #     back_populates="musics", link_model=PlaylistMusic
    # )
    # play_history: List["MusicPlayHistory"] = Relationship(
    #     back_populates="music"
    # )
    # favorites: List["MusicFavorite"] = Relationship(
    #     back_populates="music"
    # )
    # upload_user: "User" = Relationship(
    #     back_populates="uploaded_music"
    # )  # 暂时注释掉以避免循环导入


class MusicPlaylist(SQLModel, table=True):
    __tablename__ = "music_playlist"
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=255, description="播放列表名称")
    description: Optional[str] = Field(default=None, description="播放列表描述")
    cover_image_url: Optional[str] = Field(
        default=None, max_length=500, description="封面图片URL"
    )
    is_public: bool = Field(default=True, description="是否公开")
    is_active: bool = Field(default=True, description="是否启用")
    user_id: int = Field(
        foreign_key="user.id", index=True, description="创建用户ID"
    )
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(
        default_factory=datetime.now,
        sa_column_kwargs={"onupdate": datetime.now}
    )

    # musics: List["LocalMusic"] = Relationship(
    #     back_populates="playlists", link_model=PlaylistMusic
    # )
    # user: "User" = Relationship(
    #     back_populates="music_playlists"
    # )  # 暂时注释掉以避免循环导入


# 暂时注释掉这些模型以避免SQLAlchemy自动创建表
# class MusicPlayHistory(SQLModel, table=True):
#     id: Optional[int] = Field(default=None, primary_key=True)
#     user_id: int = Field(
#         foreign_key="user.id", index=True, description="用户ID"
#     )
#     music_id: int = Field(
#         foreign_key="music_track.id", index=True, description="音乐ID"
#     )
#     playlist_id: Optional[int] = Field(default=None, description="播放列表ID")
#     played_at: datetime = Field(default_factory=datetime.now)
#     duration_played: Optional[int] = Field(
#         default=None, description="播放时长(秒)"
#     )
#     is_completed: bool = Field(default=False, description="是否完整播放")

#     # music: LocalMusic = Relationship(
#     #     back_populates="play_history"
#     # )
#     # user: "User" = Relationship(
#     #     back_populates="music_play_history"
#     # )  # 暂时注释掉以避免循环导入


# class MusicFavorite(SQLModel, table=True):
#     id: Optional[int] = Field(default=None, primary_key=True)
#     user_id: int = Field(
#         foreign_key="user.id", index=True, description="用户ID"
#     )
#     music_id: int = Field(
#         foreign_key="music_track.id", index=True, description="音乐ID"
#     )
#     created_at: datetime = Field(default_factory=datetime.now)

#     # music: LocalMusic = Relationship(
#     #     back_populates="favorites"
#     # )
#     # user: "User" = Relationship(
#     #     back_populates="music_favorites"
#     # )  # 暂时注释掉以避免循环导入
