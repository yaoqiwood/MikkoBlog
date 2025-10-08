// src/utils/musicApi.js
import axios from 'axios';

class MusicApiService {
  constructor() {
    this.baseURL = '/api/music';
  }

  // 搜索歌曲
  async searchSongs(keywords, platform = 'netease', limit = 30) {
    try {
      const response = await axios.get(`${this.baseURL}/search`, {
        params: {
          keywords,
          platform,
          limit,
          type: 1, // 1: 单曲, 10: 专辑, 100: 歌手
        },
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
        params: { songId, platform },
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
        params: { songId, platform },
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
        params: { songId, platform },
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
        params: { platform, limit },
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
        params: { platform, limit },
      });
      return response.data;
    } catch (error) {
      console.error('获取推荐歌曲失败:', error);
      throw error;
    }
  }
}

export default new MusicApiService();
