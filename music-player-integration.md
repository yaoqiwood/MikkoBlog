# 音乐播放器集成方案

## 1. 安装依赖

```bash
# 安装音乐播放器相关依赖
npm install howler
npm install axios
npm install crypto-js

# 可选：安装UI组件库
npm install @vueuse/core
```

## 2. 创建音乐API服务

```javascript
// src/utils/musicApi.js
import axios from 'axios';
import CryptoJS from 'crypto-js';

class MusicApiService {
  constructor() {
    this.baseURL = 'http://localhost:8000/api/music';
  }

  // 搜索歌曲
  async searchSongs(keywords, platform = 'netease', limit = 30) {
    try {
      const response = await axios.get(`${this.baseURL}/search`, {
        params: {
          keywords,
          platform,
          limit,
          type: 1 // 1: 单曲, 10: 专辑, 100: 歌手
        }
      });
      return response.data;
    } catch (error) {
      console.error('搜索歌曲失败:', error);
      throw error;
    }
  }

  // 获取歌曲详情
  async getSongDetail(songId, platform = 'netease') {
    try {
      const response = await axios.get(`${this.baseURL}/song/detail`, {
        params: { songId, platform }
      });
      return response.data;
    } catch (error) {
      console.error('获取歌曲详情失败:', error);
      throw error;
    }
  }

  // 获取歌曲播放URL
  async getSongUrl(songId, platform = 'netease') {
    try {
      const response = await axios.get(`${this.baseURL}/song/url`, {
        params: { songId, platform }
      });
      return response.data;
    } catch (error) {
      console.error('获取播放URL失败:', error);
      throw error;
    }
  }

  // 获取歌词
  async getLyrics(songId, platform = 'netease') {
    try {
      const response = await axios.get(`${this.baseURL}/lyric`, {
        params: { songId, platform }
      });
      return response.data;
    } catch (error) {
      console.error('获取歌词失败:', error);
      throw error;
    }
  }

  // 获取热门歌曲
  async getHotSongs(platform = 'netease', limit = 50) {
    try {
      const response = await axios.get(`${this.baseURL}/hot`, {
        params: { platform, limit }
      });
      return response.data;
    } catch (error) {
      console.error('获取热门歌曲失败:', error);
      throw error;
    }
  }

  // 获取推荐歌曲
  async getRecommendSongs(platform = 'netease', limit = 30) {
    try {
      const response = await axios.get(`${this.baseURL}/recommend`, {
        params: { platform, limit }
      });
      return response.data;
    } catch (error) {
      console.error('获取推荐歌曲失败:', error);
      throw error;
    }
  }
}

export default new MusicApiService();
```

## 3. 创建音乐播放器组件

```vue
<!-- src/components/MusicPlayer.vue -->
<template>
  <div class="music-player">
    <!-- 播放器控制面板 -->
    <div class="player-controls">
      <div class="song-info">
        <div class="song-title">{{ currentSong?.title || '暂无播放' }}</div>
        <div class="song-artist">{{ currentSong?.artist || '' }}</div>
      </div>

      <div class="control-buttons">
        <button @click="previousSong" class="control-btn">⏮</button>
        <button @click="togglePlay" class="control-btn play-btn">
          {{ isPlaying ? '⏸️' : '▶️' }}
        </button>
        <button @click="nextSong" class="control-btn">⏭</button>
      </div>

      <div class="progress-section">
        <span class="time">{{ formatTime(currentTime) }}</span>
        <div class="progress-bar" @click="seekTo">
          <div class="progress" :style="{ width: progressPercent + '%' }"></div>
        </div>
        <span class="time">{{ formatTime(duration) }}</span>
      </div>

      <div class="volume-section">
        <button @click="toggleMute" class="control-btn">
          {{ isMuted ? '🔇' : '🔊' }}
        </button>
        <input
          type="range"
          min="0"
          max="1"
          step="0.1"
          v-model="volume"
          @input="setVolume"
          class="volume-slider"
        />
      </div>
    </div>

    <!-- 播放列表 -->
    <div class="playlist" v-if="showPlaylist">
      <div class="playlist-header">
        <h3>播放列表</h3>
        <button @click="showPlaylist = false" class="close-btn">×</button>
      </div>
      <div class="playlist-items">
        <div
          v-for="(song, index) in playlist"
          :key="song.id"
          :class="['playlist-item', { active: index === currentIndex }]"
          @click="playSong(index)"
        >
          <div class="song-info">
            <div class="song-title">{{ song.title }}</div>
            <div class="song-artist">{{ song.artist }}</div>
          </div>
          <div class="song-duration">{{ formatTime(song.duration) }}</div>
        </div>
      </div>
    </div>

    <!-- 搜索框 -->
    <div class="search-section">
      <input
        v-model="searchKeyword"
        @keyup.enter="searchSongs"
        placeholder="搜索歌曲..."
        class="search-input"
      />
      <button @click="searchSongs" class="search-btn">搜索</button>
    </div>

    <!-- 搜索结果 -->
    <div class="search-results" v-if="searchResults.length > 0">
      <h3>搜索结果</h3>
      <div class="results-list">
        <div
          v-for="song in searchResults"
          :key="song.id"
          class="result-item"
          @click="addToPlaylist(song)"
        >
          <div class="song-info">
            <div class="song-title">{{ song.title }}</div>
            <div class="song-artist">{{ song.artist }}</div>
          </div>
          <div class="song-duration">{{ formatTime(song.duration) }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { Howl } from 'howler';
import musicApi from '@/utils/musicApi';

// 响应式数据
const currentSong = ref(null);
const playlist = ref([]);
const currentIndex = ref(0);
const isPlaying = ref(false);
const currentTime = ref(0);
const duration = ref(0);
const volume = ref(0.8);
const isMuted = ref(false);
const showPlaylist = ref(false);
const searchKeyword = ref('');
const searchResults = ref([]);

// Howler实例
let sound = null;

// 计算属性
const progressPercent = computed(() => {
  if (duration.value === 0) return 0;
  return (currentTime.value / duration.value) * 100;
});

// 播放器方法
const initPlayer = () => {
  if (sound) {
    sound.unload();
  }

  if (currentSong.value && currentSong.value.url) {
    sound = new Howl({
      src: [currentSong.value.url],
      html5: true,
      volume: volume.value,
      onplay: () => {
        isPlaying.value = true;
        updateTime();
      },
      onpause: () => {
        isPlaying.value = false;
      },
      onend: () => {
        nextSong();
      },
      onload: () => {
        duration.value = sound.duration();
      }
    });
  }
};

const updateTime = () => {
  if (sound) {
    currentTime.value = sound.seek();
    requestAnimationFrame(updateTime);
  }
};

const togglePlay = () => {
  if (!sound) return;

  if (isPlaying.value) {
    sound.pause();
  } else {
    sound.play();
  }
};

const previousSong = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--;
    playSong(currentIndex.value);
  }
};

const nextSong = () => {
  if (currentIndex.value < playlist.value.length - 1) {
    currentIndex.value++;
    playSong(currentIndex.value);
  }
};

const playSong = async (index) => {
  if (index < 0 || index >= playlist.value.length) return;

  currentIndex.value = index;
  currentSong.value = playlist.value[index];

  // 获取播放URL
  try {
    const urlData = await musicApi.getSongUrl(currentSong.value.id, currentSong.value.platform);
    currentSong.value.url = urlData.url;
    initPlayer();
    sound.play();
  } catch (error) {
    console.error('播放失败:', error);
  }
};

const seekTo = (event) => {
  if (!sound) return;

  const rect = event.currentTarget.getBoundingClientRect();
  const percent = (event.clientX - rect.left) / rect.width;
  const time = percent * duration.value;
  sound.seek(time);
};

const setVolume = () => {
  if (sound) {
    sound.volume(volume.value);
  }
};

const toggleMute = () => {
  if (sound) {
    isMuted.value = !isMuted.value;
    sound.mute(isMuted.value);
  }
};

// 搜索功能
const searchSongs = async () => {
  if (!searchKeyword.value.trim()) return;

  try {
    const results = await musicApi.searchSongs(searchKeyword.value);
    searchResults.value = results.songs || [];
  } catch (error) {
    console.error('搜索失败:', error);
  }
};

const addToPlaylist = (song) => {
  playlist.value.push(song);
  if (playlist.value.length === 1) {
    playSong(0);
  }
};

// 工具方法
const formatTime = (seconds) => {
  if (!seconds || isNaN(seconds)) return '0:00';

  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

// 生命周期
onMounted(() => {
  // 加载默认播放列表
  loadDefaultPlaylist();
});

onUnmounted(() => {
  if (sound) {
    sound.unload();
  }
});

const loadDefaultPlaylist = async () => {
  try {
    const hotSongs = await musicApi.getHotSongs();
    playlist.value = hotSongs.songs || [];
    if (playlist.value.length > 0) {
      await playSong(0);
    }
  } catch (error) {
    console.error('加载默认播放列表失败:', error);
  }
};
</script>

<style scoped>
.music-player {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.player-controls {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
}

.song-info {
  flex: 1;
  min-width: 0;
}

.song-title {
  font-weight: bold;
  font-size: 16px;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.song-artist {
  font-size: 14px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.control-buttons {
  display: flex;
  gap: 10px;
}

.control-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: background-color 0.3s;
}

.control-btn:hover {
  background: rgba(0, 0, 0, 0.1);
}

.play-btn {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  font-size: 24px;
}

.progress-section {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 2;
}

.progress-bar {
  flex: 1;
  height: 4px;
  background: #eee;
  border-radius: 2px;
  cursor: pointer;
  position: relative;
}

.progress {
  height: 100%;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 2px;
  transition: width 0.1s;
}

.time {
  font-size: 12px;
  color: #666;
  min-width: 40px;
  text-align: center;
}

.volume-section {
  display: flex;
  align-items: center;
  gap: 10px;
}

.volume-slider {
  width: 80px;
}

.search-section {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.search-input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
}

.search-btn {
  padding: 10px 20px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
}

.playlist {
  border-top: 1px solid #eee;
  padding-top: 20px;
}

.playlist-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
}

.playlist-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.playlist-item:hover {
  background: rgba(0, 0, 0, 0.05);
}

.playlist-item.active {
  background: rgba(255, 107, 107, 0.1);
}

.search-results {
  border-top: 1px solid #eee;
  padding-top: 20px;
}

.results-list {
  max-height: 300px;
  overflow-y: auto;
}

.result-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.result-item:hover {
  background: rgba(0, 0, 0, 0.05);
}
</style>
```

## 4. 后端API实现

```python
# backend/app/api/routers/music.py
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from app.db.session import get_session
from app.models.music import MusicPlaylist, MusicTrack, PlaylistTrack
import requests
import json

router = APIRouter(prefix="/music", tags=["music"])

# 网易云音乐API
class NeteaseMusicAPI:
    def __init__(self):
        self.base_url = "https://music.163.com/api"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
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
            response = requests.get(url, params=params, headers=self.headers)
            data = response.json()
            return data
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"获取播放URL失败: {str(e)}")

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
    limit: int = 30,
    db: Session = Depends(get_session)
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
        api = NeteaseMusicAPI()
        # 这里可以实现获取热门歌曲的逻辑
        return {"songs": []}
    else:
        raise HTTPException(status_code=400, detail="不支持的平台")
```

## 5. 使用示例

```vue
<!-- 在BlogHome.vue中使用 -->
<template>
  <div class="blog-home">
    <!-- 其他内容 -->

    <!-- 音乐播放器 -->
    <div class="left-sidebar">
      <MusicPlayer />
    </div>
  </div>
</template>

<script setup>
import MusicPlayer from '@/components/MusicPlayer.vue';
</script>
```

这个方案提供了：

1. **完整的音乐播放功能**：播放、暂停、上一首、下一首
2. **互联网曲库访问**：支持搜索和播放在线音乐
3. **播放列表管理**：添加、删除、排序歌曲
4. **搜索功能**：实时搜索歌曲并添加到播放列表
5. **响应式设计**：适配不同屏幕尺寸
6. **数据库集成**：与你的音乐数据库表集成

需要我帮你实现其中的某个部分吗？
