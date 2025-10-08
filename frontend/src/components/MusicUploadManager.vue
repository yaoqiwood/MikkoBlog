<!-- src/components/MusicUploadManager.vue -->
<template>
  <div class="music-upload-manager">
    <div class="upload-section">
      <h3>🎵 音乐上传</h3>

      <!-- 上传表单 -->
      <div class="upload-form">
        <div class="file-upload">
          <input
            ref="fileInput"
            type="file"
            accept=".mp3,.wav,.ogg,.m4a,.flac"
            @change="handleFileSelect"
            style="display: none"
          />
          <button @click="$refs.fileInput.click()" class="upload-btn">📁 选择音乐文件</button>
          <span v-if="selectedFile" class="file-name">
            {{ selectedFile.name }}
          </span>
        </div>

        <div class="form-fields">
          <div class="field-group">
            <label>歌曲标题 *</label>
            <input v-model="uploadForm.title" type="text" placeholder="请输入歌曲标题" required />
          </div>

          <div class="field-group">
            <label>艺术家 *</label>
            <input
              v-model="uploadForm.artist"
              type="text"
              placeholder="请输入艺术家名称"
              required
            />
          </div>

          <div class="field-group">
            <label>专辑</label>
            <input v-model="uploadForm.album" type="text" placeholder="请输入专辑名称" />
          </div>

          <div class="field-group">
            <label>音乐类型</label>
            <select v-model="uploadForm.genre">
              <option value="">请选择类型</option>
              <option value="流行">流行</option>
              <option value="摇滚">摇滚</option>
              <option value="古典">古典</option>
              <option value="电子">电子</option>
              <option value="爵士">爵士</option>
              <option value="民谣">民谣</option>
              <option value="说唱">说唱</option>
              <option value="其他">其他</option>
            </select>
          </div>

          <div class="field-group">
            <label>发行年份</label>
            <input
              v-model="uploadForm.year"
              type="number"
              placeholder="如：2023"
              min="1900"
              :max="new Date().getFullYear()"
            />
          </div>

          <div class="field-group">
            <label>歌词</label>
            <textarea
              v-model="uploadForm.lyrics"
              placeholder="请输入歌词（可选）"
              rows="4"
            ></textarea>
          </div>
        </div>

        <div class="upload-actions">
          <button @click="uploadMusic" :disabled="!canUpload" class="upload-submit-btn">
            {{ uploading ? '上传中...' : '上传音乐' }}
          </button>
          <button @click="resetForm" class="reset-btn">重置</button>
        </div>
      </div>
    </div>

    <!-- 音乐列表 -->
    <div class="music-list-section">
      <h3>📚 我的音乐库</h3>

      <div class="list-controls">
        <input
          v-model="searchKeyword"
          @input="searchMusic"
          placeholder="搜索音乐..."
          class="search-input"
        />
        <select v-model="selectedGenre" @change="filterByGenre" class="genre-filter">
          <option value="">所有类型</option>
          <option value="流行">流行</option>
          <option value="摇滚">摇滚</option>
          <option value="古典">古典</option>
          <option value="电子">电子</option>
          <option value="爵士">爵士</option>
          <option value="民谣">民谣</option>
          <option value="说唱">说唱</option>
          <option value="其他">其他</option>
        </select>
      </div>

      <div v-if="loading" class="loading">加载中...</div>

      <div v-else-if="musicList.length === 0" class="empty-state">
        <p>🎵 还没有上传任何音乐</p>
        <p>点击上方按钮开始上传你的音乐吧！</p>
      </div>

      <div v-else class="music-list">
        <div v-for="music in musicList" :key="music.id" class="music-item">
          <div class="music-info">
            <div class="music-title">{{ music.title }}</div>
            <div class="music-artist">{{ music.artist }}</div>
            <div class="music-details">
              <span v-if="music.album">{{ music.album }}</span>
              <span v-if="music.genre"> · {{ music.genre }}</span>
              <span v-if="music.year"> · {{ music.year }}</span>
            </div>
          </div>

          <div class="music-actions">
            <button @click="playMusic(music)" class="play-btn">▶️</button>
            <button @click="deleteMusic(music.id)" class="delete-btn">🗑️</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import localMusicApi from '@/utils/localMusicApi';
import { computed, onMounted, ref } from 'vue';

// 响应式数据
const selectedFile = ref(null);
const uploading = ref(false);
const loading = ref(false);
const musicList = ref([]);
const searchKeyword = ref('');
const selectedGenre = ref('');

const uploadForm = ref({
  title: '',
  artist: '',
  album: '',
  genre: '',
  year: '',
  lyrics: '',
});

// 计算属性
const canUpload = computed(() => {
  return (
    selectedFile.value &&
    uploadForm.value.title.trim() &&
    uploadForm.value.artist.trim() &&
    !uploading.value
  );
});

// 方法
const handleFileSelect = event => {
  const file = event.target.files[0];
  if (file) {
    // 检查文件大小 (50MB)
    if (file.size > 50 * 1024 * 1024) {
      alert('文件太大，请选择小于50MB的文件');
      return;
    }

    selectedFile.value = file;

    // 尝试从文件名提取信息
    const fileName = file.name.replace(/\.[^/.]+$/, ''); // 去掉扩展名
    const parts = fileName.split(' - ');
    if (parts.length >= 2) {
      uploadForm.value.artist = parts[0].trim();
      uploadForm.value.title = parts[1].trim();
    } else {
      uploadForm.value.title = fileName;
    }
  }
};

const uploadMusic = async () => {
  if (!canUpload.value) return;

  uploading.value = true;

  try {
    const formData = new FormData();
    formData.append('file', selectedFile.value);
    formData.append('title', uploadForm.value.title);
    formData.append('artist', uploadForm.value.artist);
    formData.append('album', uploadForm.value.album || '');
    formData.append('genre', uploadForm.value.genre || '');
    formData.append('year', uploadForm.value.year || '');
    formData.append('lyrics', uploadForm.value.lyrics || '');

    await localMusicApi.uploadMusic(formData);

    alert('音乐上传成功！');
    resetForm();
    loadMusicList();
  } catch (error) {
    console.error('上传失败:', error);
    alert('上传失败: ' + (error.response?.data?.detail || error.message));
  } finally {
    uploading.value = false;
  }
};

const resetForm = () => {
  selectedFile.value = null;
  uploadForm.value = {
    title: '',
    artist: '',
    album: '',
    genre: '',
    year: '',
    lyrics: '',
  };
  if (document.querySelector('input[type="file"]')) {
    document.querySelector('input[type="file"]').value = '';
  }
};

const loadMusicList = async () => {
  loading.value = true;

  try {
    const params = {};
    if (searchKeyword.value) {
      params.search = searchKeyword.value;
    }
    if (selectedGenre.value) {
      params.genre = selectedGenre.value;
    }

    const response = await localMusicApi.getMusicList(params);
    musicList.value = response.musics || [];
  } catch (error) {
    console.error('加载音乐列表失败:', error);
    alert('加载音乐列表失败');
  } finally {
    loading.value = false;
  }
};

const searchMusic = () => {
  loadMusicList();
};

const filterByGenre = () => {
  loadMusicList();
};

const playMusic = async music => {
  try {
    const fileInfo = await localMusicApi.getMusicFile(music.id);
    // 触发播放事件
    window.dispatchEvent(
      new CustomEvent('playLocalMusic', {
        detail: {
          ...music,
          url: fileInfo.file_url,
        },
      })
    );
  } catch (error) {
    console.error('播放音乐失败:', error);
    alert('播放音乐失败');
  }
};

const deleteMusic = async musicId => {
  if (!confirm('确定要删除这首音乐吗？')) return;

  try {
    await localMusicApi.deleteMusic(musicId);
    alert('音乐删除成功');
    loadMusicList();
  } catch (error) {
    console.error('删除音乐失败:', error);
    alert('删除音乐失败');
  }
};

// 生命周期
onMounted(() => {
  loadMusicList();
});
</script>

<style scoped>
.music-upload-manager {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.upload-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.upload-section h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 20px;
}

.upload-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.file-upload {
  display: flex;
  align-items: center;
  gap: 12px;
}

.upload-btn {
  background: linear-gradient(45deg, #4caf50, #45a049);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.file-name {
  color: #666;
  font-size: 14px;
}

.form-fields {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-group label {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}

.field-group input,
.field-group select,
.field-group textarea {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.3s ease;
}

.field-group input:focus,
.field-group select:focus,
.field-group textarea:focus {
  outline: none;
  border-color: #4caf50;
}

.upload-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.upload-submit-btn {
  background: linear-gradient(45deg, #2196f3, #1976d2);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.upload-submit-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.reset-btn {
  background: #f5f5f5;
  color: #666;
  border: 1px solid #ddd;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.reset-btn:hover {
  background: #e0e0e0;
}

.music-list-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.music-list-section h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 20px;
}

.list-controls {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.search-input,
.genre-filter {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
}

.search-input {
  flex: 1;
}

.genre-filter {
  min-width: 120px;
}

.loading {
  text-align: center;
  padding: 40px;
  color: #666;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #666;
}

.empty-state p {
  margin: 8px 0;
}

.music-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.music-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border: 1px solid #eee;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.music-item:hover {
  border-color: #4caf50;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.1);
}

.music-info {
  flex: 1;
}

.music-title {
  font-weight: 600;
  color: #333;
  font-size: 16px;
  margin-bottom: 4px;
}

.music-artist {
  color: #666;
  font-size: 14px;
  margin-bottom: 4px;
}

.music-details {
  color: #999;
  font-size: 12px;
}

.music-actions {
  display: flex;
  gap: 8px;
}

.play-btn,
.delete-btn {
  background: none;
  border: none;
  padding: 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s ease;
}

.play-btn:hover {
  background: #e8f5e8;
}

.delete-btn:hover {
  background: #ffebee;
}
</style>
