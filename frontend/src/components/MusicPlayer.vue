<!-- src/components/MusicPlayer.vue -->
<template>
  <div class="music-player">
    <!-- 播放器头部 -->
    <div class="player-header">
      <h3>🎵 音乐播放器</h3>
    </div>

    <!-- 当前播放歌曲信息 -->
    <div class="track-title">{{ currentSong?.title || '暂无播放' }}</div>

    <!-- 静音状态提示 -->
    <div v-if="isMuted && isPlaying" class="mute-tip">
      <span class="mute-icon">🔇</span>
      <span class="mute-text">音乐已静音</span>
    </div>

    <!-- 播放控制 -->
    <div class="track-controls">
      <button @click="previousSong" class="play-btn">⏮</button>
      <button @click="togglePlay" class="play-btn">
        {{ isPlaying ? '⏸️' : '▶️' }}
      </button>
      <button @click="nextSong" class="play-btn">⏭</button>

      <div class="progress-bar" @click="seekTo">
        <div class="progress" :style="{ width: progressPercent + '%' }"></div>
      </div>

      <span class="time">{{ formatTime(currentTime) }}</span>
      <button @click="toggleMute" class="volume-btn">
        {{ isMuted ? '🔇' : '🔊' }}
      </button>
    </div>

    <!-- 播放列表 -->
    <div class="playlist">
      <div
        v-for="(song, index) in playlist"
        :key="song.id"
        :class="['playlist-item', { active: index === currentIndex }]"
        @click="playSong(index)"
      >
        {{ song.title }} - {{ song.artist }}
      </div>
    </div>
  </div>
</template>

<script setup>
import freeMusicApi from '@/utils/freeMusicApi';
import localMusicApi from '@/utils/localMusicApi';
import logger from '@/utils/logger';
import { Howl } from 'howler';
import { computed, onMounted, onUnmounted, ref } from 'vue';

// 响应式数据
const currentSong = ref(null);
const playlist = ref([]);
const currentIndex = ref(0);
const isPlaying = ref(false);
const currentTime = ref(0);
const duration = ref(0);
const volume = ref(0.8);
const isMuted = ref(false); // 恢复默认不静音

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
    logger.music('初始化播放器，歌曲URL:', currentSong.value.url);

    // 检查URL是否为网易云音乐格式
    let audioUrl = currentSong.value.url;
    if (audioUrl.includes('music.163.com/song/media/outer/url')) {
      logger.music('检测到网易云音乐URL，使用原始URL');
      // 直接使用原始URL，让浏览器处理
      audioUrl = currentSong.value.url;
    }
    sound = new Howl({
      src: [audioUrl],
      html5: true,
      volume: volume.value, // 恢复正常音量
      format: ['mp3', 'ogg', 'wav'], // 指定支持的格式
      onplay: () => {
        logger.music('开始播放');
        isPlaying.value = true;
        updateTime();
      },
      onpause: () => {
        logger.music('暂停播放');
        isPlaying.value = false;
      },
      onend: () => {
        logger.music('播放结束');
        nextSong();
      },
      onload: () => {
        logger.music('音频加载完成，时长:', sound.duration());
        duration.value = sound.duration();
        // 移除自动播放逻辑
      },
      onloaderror: (id, error) => {
        console.error('音频加载失败:', error);
        logger.music('音乐加载失败，可能是网络问题或文件不存在');
      },
      onplayerror: (id, error) => {
        console.error('播放失败:', error);
        logger.music('音乐播放失败，可能是网络问题或文件损坏');
      },
    });
  } else {
    logger.warn('无法初始化播放器：缺少歌曲或URL');
  }
};

const updateTime = () => {
  if (sound) {
    currentTime.value = sound.seek();
    if (isPlaying.value) {
      window.requestAnimationFrame(updateTime);
    }
  }
};

const togglePlay = () => {
  logger.music('点击播放按钮，当前状态:', isPlaying.value, 'sound对象:', !!sound);

  if (!sound) {
    logger.warn('sound对象不存在，无法播放');
    return;
  }

  if (isPlaying.value) {
    logger.music('暂停播放');
    sound.pause();
    // 注意：Howler.js 的 pause() 会自动保持播放进度
  } else {
    logger.music('继续播放');
    sound.play();
    // 注意：Howler.js 的 play() 会从暂停的位置继续播放
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

const playSong = async index => {
  logger.music('播放歌曲，索引:', index);
  if (index < 0 || index >= playlist.value.length) return;

  // 如果切换了歌曲，才重新初始化播放器
  const isNewSong = currentIndex.value !== index;
  currentIndex.value = index;
  currentSong.value = playlist.value[index];
  logger.music('设置当前歌曲:', currentSong.value);

  // 如果歌曲已经有URL，直接播放
  if (currentSong.value.url) {
    logger.music('歌曲已有URL');
    if (isNewSong) {
      logger.music('切换歌曲，重新初始化播放器');
      initPlayer();
    }
    if (sound) {
      logger.music('尝试播放歌曲');
      sound.play();
    }
    return;
  }

  // 如果没有URL，直接使用默认URL
  logger.music('使用默认URL');
  currentSong.value.url = `https://music.163.com/song/media/outer/url?id=${currentSong.value.id}`;
  if (isNewSong) {
    logger.music('切换歌曲，重新初始化播放器');
    initPlayer();
  }
  if (sound) {
    sound.play();
  }
};

const seekTo = event => {
  if (!sound) return;

  const rect = event.currentTarget.getBoundingClientRect();
  const percent = (event.clientX - rect.left) / rect.width;
  const time = percent * duration.value;
  sound.seek(time);
};

const toggleMute = () => {
  if (sound) {
    isMuted.value = !isMuted.value;
    sound.mute(isMuted.value);
    // 如果取消静音且正在播放，显示提示
    if (!isMuted.value && isPlaying.value) {
      logger.music('音乐已取消静音，开始播放声音');
    }
  }
};

// 工具方法
const formatTime = seconds => {
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
  logger.music('开始加载默认播放列表');

  try {
    // 优先从后端获取播放列表
    logger.music('尝试获取播放列表');
    const playlistsResponse = await localMusicApi.getPlaylists();
    logger.music('播放列表响应:', playlistsResponse);

    if (playlistsResponse.playlists && playlistsResponse.playlists.length > 0) {
      // 使用第一个播放列表
      const firstPlaylist = playlistsResponse.playlists[0];
      logger.music('使用播放列表:', firstPlaylist.name);

      // 获取播放列表中的音乐
      const playlistMusics = await localMusicApi.getPlaylistMusics(firstPlaylist.id);
      logger.music('播放列表音乐:', playlistMusics);

      if (playlistMusics.musics && playlistMusics.musics.length > 0) {
        // 为音乐添加URL
        const musicsWithUrl = await Promise.all(
          playlistMusics.musics.map(async music => {
            try {
              const fileInfo = await localMusicApi.getMusicFile(music.id);
              return {
                ...music,
                url: fileInfo.file_url,
                duration: music.duration || 180, // 默认3分钟
              };
            } catch (error) {
              console.warn(`获取音乐文件失败: ${music.title}`, error);
              return {
                ...music,
                duration: music.duration || 180,
              };
            }
          })
        );

        playlist.value = musicsWithUrl.filter(music => music.url);
        logger.music('使用播放列表音乐:', playlist.value.length, '首');
      } else {
        logger.music('播放列表为空，尝试获取本地音乐');
        await loadLocalMusicAsFallback();
      }
    } else {
      logger.music('没有播放列表，尝试获取本地音乐');
      await loadLocalMusicAsFallback();
    }

    if (playlist.value.length > 0) {
      // 设置第一首歌为当前播放
      currentSong.value = playlist.value[0];
      currentIndex.value = 0;
      logger.music('设置当前歌曲:', currentSong.value);
      // 初始化播放器
      initPlayer();
    }
  } catch (error) {
    console.error('加载默认播放列表失败:', error);
    await loadLocalMusicAsFallback();
  }
};

// 备用方案：加载本地音乐
const loadLocalMusicAsFallback = async () => {
  try {
    logger.music('尝试加载本地音乐作为备用');
    const localResponse = await localMusicApi.getMusicList({ page_size: 10 });
    logger.music('本地音乐响应:', localResponse);

    if (localResponse.musics && localResponse.musics.length > 0) {
      // 为本地音乐添加URL
      const localMusics = await Promise.all(
        localResponse.musics.map(async music => {
          try {
            const fileInfo = await localMusicApi.getMusicFile(music.id);
            return {
              ...music,
              url: fileInfo.file_url,
              duration: music.duration || 180,
            };
          } catch (error) {
            console.warn(`获取音乐文件失败: ${music.title}`, error);
            return {
              ...music,
              duration: music.duration || 180,
            };
          }
        })
      );

      playlist.value = localMusics.filter(music => music.url);
      logger.music('使用本地音乐播放列表');
    } else {
      logger.music('本地音乐为空，使用免费音乐推荐');
      const freeMusic = await freeMusicApi.getFreeMusicRecommendations();
      playlist.value = freeMusic;
      logger.music('使用免费音乐播放列表');
    }
  } catch (error) {
    console.error('加载本地音乐失败:', error);
    // 最后的备用方案
    playlist.value = [
      {
        id: 1,
        title: 'Creative Commons Music',
        artist: 'Free Music Archive',
        album: 'CC Music Collection',
        duration: 180,
        platform: 'freesound',
        url: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      },
      {
        id: 2,
        title: 'Ambient Soundscape',
        artist: 'Open Music Archive',
        album: 'Public Domain Music',
        duration: 240,
        platform: 'archive',
        url: 'https://archive.org/download/testmp3testfile/mp3test.mp3',
      },
    ];
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

.player-header h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.track-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 10px;
}

/* 静音状态提示 */
.mute-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  border-radius: 8px;
  margin-bottom: 10px;
  font-size: 12px;
  animation: pulse 2s infinite;
}

.mute-icon {
  font-size: 14px;
}

.mute-text {
  flex: 1;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 0.8;
  }
  50% {
    opacity: 1;
  }
}

.track-controls {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.play-btn {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-btn:hover {
  transform: scale(1.2);
}

.progress-bar {
  flex: 1;
  height: 4px;
  background: #eee;
  border-radius: 2px;
  overflow: hidden;
  cursor: pointer;
}

.progress {
  width: 30%;
  height: 100%;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 2px;
  transition: width 0.1s;
}

.time {
  font-size: 12px;
  color: #666;
}

.volume-btn {
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
}

.playlist {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.playlist-item {
  font-size: 12px;
  color: #666;
  padding: 5px 10px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.playlist-item:hover {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
}

/* 自动播放提示样式 */
.auto-play-tip {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  border-radius: 8px;
  margin-top: 10px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  animation: slideDown 0.3s ease-out;
  z-index: 1000;
}

.tip-content {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  gap: 8px;
}

.tip-icon {
  font-size: 16px;
}

.tip-text {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.tip-close {
  background: none;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s ease;
}

.tip-close:hover {
  background: rgba(255, 255, 255, 0.2);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.playlist-item.active {
  background: rgba(255, 107, 107, 0.2);
  color: #ff6b6b;
  font-weight: bold;
}

.no-results {
  text-align: center;
  padding: 20px;
  color: #666;
}

.no-results p {
  margin: 0 0 5px 0;
  font-size: 16px;
}

.no-results small {
  font-size: 12px;
  color: #999;
}
</style>
