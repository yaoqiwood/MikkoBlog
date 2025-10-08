# backend/app/api/routers/music.py
from fastapi import APIRouter, Depends, HTTPException
import requests

router = APIRouter(prefix="", tags=["music"])


# 网易云音乐API
class NeteaseMusicAPI:
    def __init__(self):
        self.base_url = "https://music.163.com/api"
        self.headers = {
            'User-Agent': ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                         'AppleWebKit/537.36')
        }

    def search(self, keywords, limit=30):
        """搜索歌曲"""
        url = f"{self.base_url}/search/get"
        params = {
            's': keywords,
            'type': 1,  # 1: 单曲
            'limit': limit,
            'offset': 0
        }

        try:
            response = requests.get(url, params=params, headers=self.headers)
            data = response.json()
            return self._format_search_results(data)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"搜索失败: {str(e)}")

    def get_song_url(self, song_id):
        """获取歌曲播放URL"""
        url = f"{self.base_url}/song/url"
        params = {'id': song_id}

        try:
            response = requests.get(url, params=params, headers=self.headers, timeout=10)
            data = response.json()

            # 如果API返回错误，返回默认URL
            if data.get('code') != 200:
                return {
                    'url': f'https://music.163.com/song/media/outer/url?id={song_id}',
                    'code': 200,
                    'message': '使用默认播放URL'
                }

            return data
        except Exception as e:
            # 如果API调用失败，返回默认URL
            return {
                'url': f'https://music.163.com/song/media/outer/url?id={song_id}',
                'code': 200,
                'message': f'API调用失败，使用默认URL: {str(e)}'
            }

    def _format_search_results(self, data):
        """格式化搜索结果"""
        songs = []
        if 'result' in data and 'songs' in data['result']:
            for song in data['result']['songs']:
                songs.append({
                    'id': song['id'],
                    'title': song['name'],
                    'artist': ', '.join([artist['name'] for artist in song['artists']]),
                    'album': song['album']['name'],
                    'duration': song['duration'] // 1000,  # 转换为秒
                    'platform': 'netease'
                })
        return {'songs': songs}


@router.get("/search")
async def search_songs(
    keywords: str,
    platform: str = "netease",
    limit: int = 30
):
    """搜索歌曲"""
    if platform == "netease":
        api = NeteaseMusicAPI()
        return api.search(keywords, limit)
    else:
        raise HTTPException(status_code=400, detail="不支持的平台")


@router.get("/song/url")
async def get_song_url(
    song_id: str,
    platform: str = "netease"
):
    """获取歌曲播放URL"""
    if platform == "netease":
        api = NeteaseMusicAPI()
        return api.get_song_url(song_id)
    else:
        raise HTTPException(status_code=400, detail="不支持的平台")


@router.get("/hot")
async def get_hot_songs(
    platform: str = "netease",
    limit: int = 50
):
    """获取热门歌曲"""
    if platform == "netease":
        # 返回默认的热门歌曲列表
        return {
            "songs": [
                {
                    "id": 1,
                    "title": "風の住む街",
                    "artist": "磯村由纪子",
                    "album": "風の住む街",
                    "duration": 285,
                    "platform": "netease",
                    "url": "https://music.163.com/song/media/outer/url?id=123456"
                },
                {
                    "id": 2,
                    "title": "ヨスガノソラメインテーマ",
                    "artist": "記",
                    "album": "ヨスガノソラ",
                    "duration": 180,
                    "platform": "netease",
                    "url": "https://music.163.com/song/media/outer/url?id=123457"
                },
                {
                    "id": 3,
                    "title": "蝶恋",
                    "artist": "仙剑奇侠传",
                    "album": "仙剑奇侠传原声带",
                    "duration": 240,
                    "platform": "netease",
                    "url": "https://music.163.com/song/media/outer/url?id=123458"
                },
                {
                    "id": 4,
                    "title": "月光の雲海",
                    "artist": "久石让",
                    "album": "天空之城",
                    "duration": 200,
                    "platform": "netease",
                    "url": "https://music.163.com/song/media/outer/url?id=123459"
                }
            ]
        }
    else:
        raise HTTPException(status_code=400, detail="不支持的平台")
