// src/utils/localMusicApi.js
import { del, get, post, put } from './httpClient';

class LocalMusicApiService {
  constructor() {
    this.baseURL = '/api/local-music';
  }

  // 上传音乐文件
  async uploadMusic(formData) {
    try {
      const response = await post(`${this.baseURL}/upload`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        // 上传大文件可能耗时较长，单次请求超时提高到 120 秒
        timeout: 120000,
      });
      return response;
    } catch (error) {
      console.error('上传音乐失败:', error);
      throw error;
    }
  }

  // 获取音乐列表
  async getMusicList(params = {}) {
    try {
      const response = await get(`${this.baseURL}/list`, params);
      return response;
    } catch (error) {
      console.error('获取音乐列表失败:', error);
      throw error;
    }
  }

  // 获取音乐详情
  async getMusicDetail(musicId) {
    try {
      const response = await get(`${this.baseURL}/${musicId}`);
      return response;
    } catch (error) {
      console.error('获取音乐详情失败:', error);
      throw error;
    }
  }

  // 获取音乐文件URL
  async getMusicFile(musicId) {
    try {
      const response = await get(`${this.baseURL}/${musicId}/file`);
      return response;
    } catch (error) {
      console.error('获取音乐文件失败:', error);
      throw error;
    }
  }

  // 删除音乐
  async deleteMusic(musicId) {
    try {
      const response = await del(`${this.baseURL}/${musicId}`);
      return response;
    } catch (error) {
      console.error('删除音乐失败:', error);
      throw error;
    }
  }

  // 获取播放列表
  async getPlaylists() {
    try {
      const response = await get(`${this.baseURL}/playlists/list`);
      return response;
    } catch (error) {
      console.error('获取播放列表失败:', error);
      throw error;
    }
  }

  // 创建播放列表
  async createPlaylist(name, description, isPublic = true) {
    try {
      const formData = new globalThis.FormData();
      formData.append('name', name);
      if (description) formData.append('description', description);
      formData.append('is_public', isPublic);

      const response = await post(`${this.baseURL}/playlists`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      console.error('创建播放列表失败:', error);
      throw error;
    }
  }

  // 添加音乐到播放列表
  async addMusicToPlaylist(playlistId, musicId) {
    try {
      const formData = new globalThis.FormData();
      formData.append('music_id', musicId);

      const response = await post(`${this.baseURL}/playlists/${playlistId}/add`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      console.error('添加音乐到播放列表失败:', error);
      throw error;
    }
  }

  // 获取播放列表中的音乐
  async getPlaylistMusics(playlistId) {
    try {
      const response = await get(`${this.baseURL}/playlists/${playlistId}/musics`);
      return response;
    } catch (error) {
      console.error('获取播放列表音乐失败:', error);
      throw error;
    }
  }

  // 删除播放列表
  async deletePlaylist(playlistId) {
    try {
      const response = await del(`${this.baseURL}/playlists/${playlistId}`);
      return response;
    } catch (error) {
      console.error('删除播放列表失败:', error);
      throw error;
    }
  }

  // 更新播放列表
  async updatePlaylist(playlistId, playlistData) {
    try {
      const formData = new globalThis.FormData();
      if (playlistData.name !== undefined) {
        formData.append('name', playlistData.name);
      }
      if (playlistData.description !== undefined) {
        formData.append('description', playlistData.description);
      }
      if (playlistData.is_public !== undefined) {
        formData.append('is_public', playlistData.is_public);
      }

      const response = await put(`${this.baseURL}/playlists/${playlistId}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response;
    } catch (error) {
      console.error('更新播放列表失败:', error);
      throw error;
    }
  }

  // 获取自动播放设置
  async getAutoPlaySetting() {
    try {
      const response = await get(`${this.baseURL}/settings/auto-play`);
      return response;
    } catch (error) {
      console.error('获取自动播放设置失败:', error);
      throw error;
    }
  }

  // 更新自动播放设置
  async updateAutoPlaySetting(autoPlay) {
    try {
      const response = await put(`${this.baseURL}/settings/auto-play`, null, {
        params: { auto_play: autoPlay },
      });
      return response;
    } catch (error) {
      console.error('更新自动播放设置失败:', error);
      throw error;
    }
  }

  // 获取公开播放列表（用于博客首页）
  async getPublicPlaylist() {
    try {
      const response = await get(`${this.baseURL}/settings/public-playlist`);
      return response;
    } catch (error) {
      console.error('获取公开播放列表失败:', error);
      throw error;
    }
  }
}

export default new LocalMusicApiService();
