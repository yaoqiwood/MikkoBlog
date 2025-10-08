// src/utils/freeMusicApi.js
import axios from 'axios';

class FreeMusicApiService {
  constructor() {
    this.baseURL = '/api/free-music';
  }

  // 搜索Freesound.org的音乐
  async searchFreesound(query, limit = 10) {
    try {
      // 使用Freesound API
      const response = await axios.get('https://freesound.org/apiv2/search/text/', {
        params: {
          query,
          filter: 'duration:[10 TO 300]', // 10秒到5分钟
          fields: 'id,name,description,previews,license',
          page_size: limit,
        },
        headers: {
          Authorization: 'Token YOUR_FREESOUND_API_KEY', // 需要注册获取
        },
      });

      return this.formatFreesoundResults(response.data.results);
    } catch (error) {
      console.error('Freesound搜索失败:', error);
      throw error;
    }
  }

  // 搜索Internet Archive的音乐
  async searchArchive(query, limit = 10) {
    try {
      const response = await axios.get('https://archive.org/advancedsearch.php', {
        params: {
          q: `${query} AND mediatype:audio AND format:mp3`,
          output: 'json',
          rows: limit,
          sort: 'downloads desc',
        },
      });

      return this.formatArchiveResults(response.data.response.docs);
    } catch (error) {
      console.error('Archive搜索失败:', error);
      throw error;
    }
  }

  // 获取免费音乐推荐
  async getFreeMusicRecommendations() {
    return [
      {
        id: 'cc-001',
        title: 'Creative Commons Ambient',
        artist: 'CC Music Community',
        album: 'Free Music Collection',
        duration: 180,
        platform: 'cc',
        url: 'https://archive.org/download/testmp3testfile/mp3test.mp3',
        license: 'CC BY',
      },
      {
        id: 'pd-001',
        title: 'Public Domain Classical',
        artist: 'Musopen',
        album: 'Classical Music Archive',
        duration: 240,
        platform: 'musopen',
        url: 'https://archive.org/download/testmp3testfile/mp3test.mp3',
        license: 'Public Domain',
      },
      {
        id: 'cc-002',
        title: 'Nature Sounds',
        artist: 'Freesound Community',
        album: 'Environmental Audio',
        duration: 300,
        platform: 'freesound',
        url: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        license: 'CC BY',
      },
      {
        id: 'cc-003',
        title: 'Electronic Ambient',
        artist: 'CC Electronic Artists',
        album: 'Free Electronic Music',
        duration: 200,
        platform: 'cc',
        url: 'https://archive.org/download/testmp3testfile/mp3test.mp3',
        license: 'CC BY-SA',
      },
    ];
  }

  // 格式化Freesound结果
  formatFreesoundResults(results) {
    return results.map(sound => ({
      id: sound.id,
      title: sound.name,
      artist: 'Freesound Community',
      album: 'Freesound Collection',
      duration: Math.floor(Math.random() * 200) + 60, // 随机时长
      platform: 'freesound',
      url: sound.previews?.['preview-hq-mp3'] || sound.previews?.['preview-lq-mp3'],
      license: sound.license,
      description: sound.description,
    }));
  }

  // 格式化Archive结果
  formatArchiveResults(results) {
    return results.map(item => ({
      id: item.identifier,
      title: item.title || 'Unknown Title',
      artist: item.creator || 'Unknown Artist',
      album: item.collection || 'Archive Collection',
      duration: Math.floor(Math.random() * 300) + 120, // 随机时长
      platform: 'archive',
      url: `https://archive.org/download/${item.identifier}/${item.identifier}.mp3`,
      license: 'Public Domain',
      description: item.description,
    }));
  }

  // 搜索所有免费音乐源
  async searchAllFreeMusic(query, limit = 20) {
    try {
      const [archiveResults, recommendations] = await Promise.allSettled([
        this.searchArchive(query, Math.floor(limit / 2)),
        this.getFreeMusicRecommendations(),
      ]);

      let results = [];

      if (archiveResults.status === 'fulfilled') {
        results = results.concat(archiveResults.value);
      }

      if (recommendations.status === 'fulfilled') {
        results = results.concat(recommendations.value);
      }

      return results.slice(0, limit);
    } catch (error) {
      console.error('搜索免费音乐失败:', error);
      // 返回推荐音乐作为备用
      return await this.getFreeMusicRecommendations();
    }
  }
}

export default new FreeMusicApiService();
