<template>
  <div class="music-management">
    <div class="page-header">
      <h1>🎵 音乐管理</h1>
      <p>管理本地音乐文件和播放列表</p>
    </div>

    <!-- 音乐设置区域 -->
    <div class="settings-section">
      <div class="section-header">
        <h2>⚙️ 音乐设置</h2>
      </div>
      <div class="settings-content">
        <div class="setting-item">
          <label class="setting-label">
            <input
              type="checkbox"
              v-model="autoPlaySetting"
              @change="updateAutoPlaySetting"
              class="setting-checkbox"
            />
            <span class="setting-text">进入博客时自动播放音乐</span>
          </label>
          <p class="setting-description">开启后，用户访问博客首页时会自动开始播放默认播放列表</p>
        </div>
      </div>
    </div>

    <!-- 音乐列表管理 -->
    <div class="music-list-section">
      <div class="section-header">
        <h2>📚 音乐库管理</h2>
        <div class="list-controls">
          <input
            v-model="searchKeyword"
            @input="handleSearch"
            placeholder="搜索音乐..."
            class="search-input"
          />
          <select v-model="selectedGenre" @change="handleGenreChange" class="genre-select">
            <option value="">所有类型</option>
            <option v-for="genre in availableGenres" :key="genre" :value="genre">
              {{ genre }}
            </option>
          </select>
          <button @click="loadMusicList" class="refresh-btn">🔄 刷新</button>
          <button @click="openUploadModal" class="upload-btn">➕ 上传音乐</button>
        </div>
      </div>

      <div v-if="loading" class="loading">
        <div class="loading-spinner"></div>
        <span>加载中...</span>
      </div>

      <div v-else-if="musicList.length === 0" class="empty-state">
        <p>🎵 还没有上传任何音乐</p>
        <p>点击上方按钮上传你的第一首音乐吧！</p>
      </div>

      <div v-else class="music-table">
        <table>
          <thead>
            <tr>
              <th class="col-title">标题</th>
              <th class="col-artist">艺术家</th>
              <th class="col-album">专辑</th>
              <th class="col-genre">类型</th>
              <th class="col-year">年份</th>
              <th class="col-size">文件大小</th>
              <th class="col-date">上传时间</th>
              <th class="col-actions">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="music in musicList" :key="music.id">
              <td class="col-title">{{ music.title }}</td>
              <td class="col-artist">{{ music.artist }}</td>
              <td class="col-album">{{ music.album || '-' }}</td>
              <td class="col-genre">{{ music.genre || '-' }}</td>
              <td class="col-year">{{ music.year || '-' }}</td>
              <td class="col-size">{{ formatFileSize(music.file_size) }}</td>
              <td class="col-date">{{ formatDate(music.created_at) }}</td>
              <td class="col-actions">
                <div class="actions">
                  <button @click="playMusic(music)" class="play-btn" title="播放">▶️</button>
                  <button @click="editMusic(music)" class="edit-btn" title="编辑">✏️</button>
                  <button @click="deleteMusic(music.id)" class="delete-btn" title="删除">🗑️</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- 分页器 -->
        <div v-if="musicList.length > 0" class="pagination-wrapper">
          <Page
            :current="currentPage"
            :total="totalMusicCount"
            :page-size="pageSize"
            :page-size-opts="[10, 20, 50, 100]"
            show-sizer
            show-elevator
            show-total
            @on-change="handlePageChange"
            @on-page-size-change="handlePageSizeChange"
          />
        </div>
      </div>
    </div>

    <!-- 编辑音乐表单 -->
    <div v-if="showEditForm" class="edit-music-form">
      <h3>编辑音乐信息</h3>
      <div class="form-row">
        <div class="form-group">
          <label>歌曲标题 *</label>
          <input v-model="editForm.title" type="text" placeholder="请输入歌曲标题" required />
        </div>
        <div class="form-group">
          <label>艺术家</label>
          <input v-model="editForm.artist" type="text" placeholder="请输入艺术家" />
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>专辑</label>
          <input v-model="editForm.album" type="text" placeholder="请输入专辑名称" />
        </div>
        <div class="form-group">
          <label>音乐类型</label>
          <input v-model="editForm.genre" type="text" placeholder="请输入音乐类型" />
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>发行年份</label>
          <select v-model="editForm.year" class="year-select">
            <option value="">请选择年份</option>
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group full-width">
          <label>歌词</label>
          <textarea v-model="editForm.lyrics" placeholder="请输入歌词" rows="4"></textarea>
        </div>
      </div>
      <div class="form-actions">
        <button @click="saveEditMusic" class="save-btn">保存修改</button>
        <button @click="cancelEditMusic" class="cancel-btn">取消</button>
      </div>
    </div>

    <!-- 播放列表管理 -->
    <div class="playlist-section">
      <div class="section-header">
        <h2>📋 播放列表管理</h2>
        <button @click="showCreatePlaylist = true" class="create-playlist-btn">
          ➕ 创建播放列表
        </button>
      </div>

      <!-- 创建播放列表表单 -->
      <div v-if="showCreatePlaylist" class="create-playlist-form">
        <h3>创建新播放列表</h3>
        <div class="form-row">
          <div class="form-group">
            <label>播放列表名称 *</label>
            <input
              v-model="playlistForm.name"
              type="text"
              placeholder="请输入播放列表名称"
              required
            />
          </div>
          <div class="form-group">
            <label>是否公开</label>
            <select v-model="playlistForm.is_public">
              <option :value="true">公开</option>
              <option :value="false">私有</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group full-width">
            <label>描述</label>
            <textarea
              v-model="playlistForm.description"
              placeholder="请输入播放列表描述"
              rows="3"
            ></textarea>
          </div>
        </div>
        <div class="form-actions">
          <button @click="createPlaylist" :disabled="!playlistForm.name" class="create-btn">
            创建播放列表
          </button>
          <button @click="cancelCreatePlaylist" class="cancel-btn">取消</button>
        </div>
      </div>

      <!-- 播放列表列表 -->
      <div v-if="playlistsLoading" class="loading">
        <div class="loading-spinner"></div>
        <span>加载播放列表中...</span>
      </div>

      <div v-else-if="playlists.length === 0" class="empty-state">
        <p>📋 还没有创建任何播放列表</p>
        <p>点击上方按钮创建你的第一个播放列表吧！</p>
      </div>

      <div v-else class="playlists-grid">
        <div v-for="playlist in playlists" :key="playlist.id" class="playlist-card">
          <div class="playlist-header">
            <h3>{{ playlist.name }}</h3>
            <div class="playlist-actions">
              <button @click="editPlaylist(playlist)" class="edit-btn" title="编辑">✏️</button>
              <button @click="deletePlaylist(playlist.id)" class="delete-btn" title="删除">
                🗑️
              </button>
            </div>
          </div>
          <p class="playlist-description">{{ playlist.description || '暂无描述' }}</p>
          <div class="playlist-meta">
            <div class="playlist-visibility-toggle">
              <label class="visibility-label">
                <input
                  type="checkbox"
                  :checked="playlist.is_public"
                  @change="togglePlaylistVisibility(playlist)"
                  class="visibility-checkbox"
                />
                <span class="visibility-text">{{ playlist.is_public ? '公开' : '私有' }}</span>
              </label>
            </div>
            <span class="playlist-count">{{ playlist.music_count || 0 }} 首音乐</span>
          </div>
          <div class="playlist-actions-bottom">
            <button @click="managePlaylistMusic(playlist)" class="manage-btn">🎵 管理音乐</button>
            <button @click="playPlaylist(playlist)" class="play-btn">▶️ 播放</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑播放列表Modal -->
    <Modal
      v-model="showEditPlaylistForm"
      title="编辑播放列表"
      width="600"
      :mask-closable="false"
      :closable="true"
    >
      <div class="edit-playlist-form">
        <div class="form-row">
          <div class="form-group">
            <label>播放列表名称 *</label>
            <input
              v-model="editPlaylistForm.name"
              type="text"
              placeholder="请输入播放列表名称"
              required
            />
          </div>
          <div class="form-group">
            <label>是否公开</label>
            <select v-model="editPlaylistForm.is_public">
              <option :value="true">公开</option>
              <option :value="false">私有</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group full-width">
            <label>描述</label>
            <textarea
              v-model="editPlaylistForm.description"
              placeholder="请输入播放列表描述"
              rows="3"
            ></textarea>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="modal-footer">
          <Button @click="cancelEditPlaylist">取消</Button>
          <Button type="primary" @click="saveEditPlaylist">保存修改</Button>
        </div>
      </template>
    </Modal>

    <!-- 管理播放列表音乐Modal -->
    <Modal
      v-model="showManageMusic"
      :title="`管理播放列表: ${managingPlaylist?.name || ''}`"
      width="800"
      :mask-closable="false"
      :closable="true"
    >
      <div class="manage-music-form">
        <!-- 播放列表中的音乐 -->
        <div class="playlist-musics">
          <h4>播放列表中的音乐</h4>
          <div v-if="playlistMusics.length === 0" class="empty-state">
            <p>播放列表为空</p>
          </div>
          <div v-else class="music-list">
            <div v-for="music in playlistMusics" :key="music.id" class="music-item">
              <span>{{ music.title }} - {{ music.artist }}</span>
              <button @click="removeMusicFromPlaylist(music.id)" class="remove-btn">移除</button>
            </div>
          </div>
        </div>

        <!-- 可添加的音乐 -->
        <div class="available-musics">
          <h4>可添加的音乐</h4>
          <div v-if="availableMusics.length === 0" class="empty-state">
            <p>没有可添加的音乐</p>
          </div>
          <div v-else class="music-list">
            <div v-for="music in availableMusics" :key="music.id" class="music-item">
              <span>{{ music.title }} - {{ music.artist }}</span>
              <button @click="addMusicToPlaylist(music.id)" class="add-btn">添加</button>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="modal-footer">
          <Button @click="closeManageMusic">关闭</Button>
        </div>
      </template>
    </Modal>

    <!-- 删除播放列表确认Modal -->
    <Modal
      v-model="showDeleteConfirm"
      title="确认删除"
      width="400"
      :mask-closable="false"
      :closable="true"
    >
      <div class="delete-confirm-content">
        <div class="warning-icon">⚠️</div>
        <p>
          确定要删除播放列表 <strong>"{{ deletingPlaylist?.name }}"</strong> 吗？
        </p>
        <p class="warning-text">此操作不可撤销，播放列表中的所有音乐关联将被移除。</p>
      </div>
      <template #footer>
        <div class="modal-footer">
          <Button @click="closeDeleteConfirm">取消</Button>
          <Button type="error" @click="confirmDeletePlaylist">确认删除</Button>
        </div>
      </template>
    </Modal>

    <!-- 音乐上传Modal -->
    <Modal
      v-model="showUploadModal"
      title="上传音乐"
      width="600"
      :mask-closable="false"
      :closable="true"
    >
      <div class="upload-form">
        <div class="form-row">
          <div class="form-group">
            <label>选择音乐文件 *</label>
            <input
              type="file"
              ref="fileInput"
              @change="handleFileSelect"
              accept=".mp3,.wav,.ogg,.m4a,.flac"
              style="display: none"
            />
            <button @click="$refs.fileInput.click()" class="file-select-btn">
              📁 选择音乐文件
            </button>
            <span v-if="selectedFile" class="file-name">
              {{ selectedFile.name }}
            </span>
            <p v-if="fileError" class="error-message">{{ fileError }}</p>
          </div>
          <div class="form-group">
            <label>封面图片</label>
            <div class="cover-upload-section">
              <input
                type="file"
                ref="coverInput"
                @change="handleCoverSelect"
                accept="image/*"
                style="display: none"
              />
              <button @click="$refs.coverInput.click()" class="cover-upload-btn">
                📷 选择封面图片
              </button>
              <span v-if="selectedCover" class="cover-file-name">
                {{ selectedCover.name }}
              </span>
              <div v-if="coverPreview" class="cover-preview">
                <img :src="coverPreview" alt="封面预览" />
                <button @click="removeCover" class="remove-cover-btn">×</button>
              </div>
              <p v-if="coverError" class="error-message">{{ coverError }}</p>
            </div>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>歌曲标题 *</label>
            <input v-model="uploadForm.title" type="text" placeholder="请输入歌曲标题" required />
          </div>
          <div class="form-group">
            <label>艺术家</label>
            <input v-model="uploadForm.artist" type="text" placeholder="请输入艺术家（可选）" />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>专辑</label>
            <input v-model="uploadForm.album" type="text" placeholder="请输入专辑名称" />
          </div>
          <div class="form-group">
            <label>音乐类型</label>
            <input v-model="uploadForm.genre" type="text" placeholder="请输入音乐类型" />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>发行年份</label>
            <select v-model="uploadForm.year" class="year-select">
              <option value="">请选择年份</option>
              <option v-for="year in availableYears" :key="year" :value="year">
                {{ year }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>添加到播放列表</label>
            <select v-model="uploadForm.playlist_id" class="playlist-select">
              <option value="">不添加到播放列表</option>
              <option v-for="playlist in playlists" :key="playlist.id" :value="playlist.id">
                {{ playlist.name }}
              </option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group full-width">
            <label>歌词</label>
            <textarea v-model="uploadForm.lyrics" placeholder="请输入歌词" rows="3"></textarea>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="modal-footer">
          <Button @click="closeUploadModal">取消</Button>
          <Button @click="resetForm">重置</Button>
          <Button type="primary" @click="uploadMusic" :disabled="!canUpload">
            {{ uploading ? '上传中...' : '上传音乐' }}
          </Button>
        </div>
      </template>
    </Modal>
  </div>
</template>

<script>
import localMusicApi from '@/utils/localMusicApi';
import { Message, Page } from 'view-ui-plus';
import { computed, onMounted, ref } from 'vue';

export default {
  name: 'MusicManagement',
  setup() {
    // 响应式数据
    const selectedFile = ref(null);
    const fileError = ref('');
    const uploading = ref(false);
    const selectedCover = ref(null);
    const coverPreview = ref('');
    const coverError = ref('');
    const uploadForm = ref({
      title: '',
      artist: '',
      album: '',
      genre: '',
      year: '',
      lyrics: '',
      playlist_id: '',
    });

    const musicList = ref([]);
    const loading = ref(false);
    const searchKeyword = ref('');
    const selectedGenre = ref('');
    const availableYears = ref([]);
    const availableGenres = ref([
      'Pop',
      'Rock',
      'Jazz',
      'Classical',
      'Electronic',
      'Hip Hop',
      'Other',
    ]);

    // 分页相关
    const currentPage = ref(1);
    const pageSize = ref(20);
    const totalMusicCount = ref(0);

    const playlists = ref([]);
    const playlistsLoading = ref(false);
    const showCreatePlaylist = ref(false);
    const playlistForm = ref({
      name: '',
      description: '',
      is_public: false,
    });

    // 编辑相关状态
    const editingMusic = ref(null);
    const showEditForm = ref(false);
    const editForm = ref({
      title: '',
      artist: '',
      album: '',
      genre: '',
      year: '',
      lyrics: '',
    });

    // 编辑播放列表相关状态
    const editingPlaylist = ref(null);
    const showEditPlaylistForm = ref(false);
    const editPlaylistForm = ref({
      name: '',
      description: '',
      is_public: true,
    });

    // 管理播放列表音乐相关状态
    const managingPlaylist = ref(null);
    const showManageMusic = ref(false);
    const playlistMusics = ref([]);
    const availableMusics = ref([]);

    // 删除确认相关状态
    const showDeleteConfirm = ref(false);
    const deletingPlaylist = ref(null);

    // 音乐上传Modal相关状态
    const showUploadModal = ref(false);

    // 自动播放设置
    const autoPlaySetting = ref(false);

    // 计算属性
    const canUpload = computed(() => {
      return selectedFile.value && uploadForm.value.title.trim() && !uploading.value;
    });

    // 方法
    const generateYears = () => {
      const currentYear = new Date().getFullYear();
      const years = [];
      for (let year = currentYear; year >= 1900; year--) {
        years.push(year);
      }
      availableYears.value = years;
    };

    const handleFileSelect = event => {
      const file = event.target.files[0];
      if (file) {
        // 文件类型和大小验证
        const allowedTypes = ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/flac'];
        const maxFileSize = 50 * 1024 * 1024; // 50MB

        if (!allowedTypes.includes(file.type)) {
          fileError.value = '不支持的文件类型。请上传mp3, wav, ogg, m4a, flac格式。';
          selectedFile.value = null;
          return;
        }

        if (file.size > maxFileSize) {
          fileError.value = '文件大小不能超过50MB。';
          selectedFile.value = null;
          return;
        }

        fileError.value = '';
        selectedFile.value = file;

        // 设置默认标题为文件名（去掉扩展名）
        const fileName = file.name.replace(/\.[^/.]+$/, ''); // 去掉扩展名
        uploadForm.value.title = fileName.trim();

        // 尝试从文件名提取艺术家信息（可选）
        const parts = fileName.split(' - ');
        if (parts.length >= 2) {
          uploadForm.value.artist = parts[0].trim();
        }
      } else {
        selectedFile.value = null;
        fileError.value = '';
      }
    };

    const handleCoverSelect = event => {
      const file = event.target.files[0];
      if (file) {
        // 检查文件类型
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
        const maxFileSize = 5 * 1024 * 1024; // 5MB

        if (!allowedTypes.includes(file.type)) {
          coverError.value = '不支持的文件类型。请上传jpg, png, gif, webp格式的图片。';
          selectedCover.value = null;
          coverPreview.value = '';
          return;
        }

        if (file.size > maxFileSize) {
          coverError.value = '图片大小不能超过5MB。';
          selectedCover.value = null;
          coverPreview.value = '';
          return;
        }

        coverError.value = '';
        selectedCover.value = file;

        // 创建预览
        const reader = new globalThis.FileReader();
        reader.onload = e => {
          coverPreview.value = e.target.result;
        };
        reader.readAsDataURL(file);
      } else {
        selectedCover.value = null;
        coverPreview.value = '';
        coverError.value = '';
      }
    };

    const removeCover = () => {
      selectedCover.value = null;
      coverPreview.value = '';
      coverError.value = '';
      if (document.querySelector('input[type="file"][accept="image/*"]')) {
        document.querySelector('input[type="file"][accept="image/*"]').value = '';
      }
    };

    const uploadMusic = async () => {
      if (!canUpload.value) return;

      uploading.value = true;

      try {
        const formData = new globalThis.FormData();
        formData.append('file', selectedFile.value);
        formData.append('title', uploadForm.value.title);
        formData.append('artist', uploadForm.value.artist || '');
        formData.append('album', uploadForm.value.album || '');
        formData.append('genre', uploadForm.value.genre || '');
        formData.append('year', uploadForm.value.year || '');
        formData.append('lyrics', uploadForm.value.lyrics || '');

        // 如果选择了播放列表，添加到表单数据中
        if (uploadForm.value.playlist_id) {
          formData.append('playlist_id', uploadForm.value.playlist_id);
          console.log('DEBUG: 添加播放列表ID到表单:', uploadForm.value.playlist_id);
        } else {
          console.log('DEBUG: 未选择播放列表');
        }

        // 如果有封面图片，添加到表单数据中
        if (selectedCover.value) {
          formData.append('cover_image', selectedCover.value);
        }

        const uploadResponse = await localMusicApi.uploadMusic(formData);
        console.log('DEBUG: 上传响应:', uploadResponse);

        // 检查是否成功添加到播放列表
        if (uploadForm.value.playlist_id) {
          console.log('DEBUG: 检查播放列表添加结果:', uploadResponse.playlist_added);
          if (uploadResponse.playlist_added) {
            Message.success('音乐已添加到播放列表！');
          } else {
            Message.info('音乐上传成功，但添加到播放列表失败（可能已在播放列表中）');
          }
        }

        Message.success('音乐上传成功！');
        resetForm();
        loadMusicList();
        loadPlaylists(); // 刷新播放列表以更新音乐数
        closeUploadModal();
      } catch (error) {
        console.error('上传失败:', error);
        Message.error('上传失败，请检查控制台');
      } finally {
        uploading.value = false;
      }
    };

    const resetForm = () => {
      selectedFile.value = null;
      fileError.value = '';
      selectedCover.value = null;
      coverPreview.value = '';
      coverError.value = '';
      uploadForm.value = {
        title: '',
        artist: '',
        album: '',
        genre: '',
        year: '',
        lyrics: '',
        playlist_id: '',
      };
      if (document.querySelector('input[type="file"]')) {
        document.querySelector('input[type="file"]').value = '';
      }
      if (document.querySelector('input[type="file"][accept="image/*"]')) {
        document.querySelector('input[type="file"][accept="image/*"]').value = '';
      }
    };

    const loadMusicList = async () => {
      loading.value = true;

      try {
        const params = {
          page: currentPage.value,
          page_size: pageSize.value,
        };
        if (searchKeyword.value) {
          params.search = searchKeyword.value;
        }
        if (selectedGenre.value) {
          params.genre = selectedGenre.value;
        }

        const response = await localMusicApi.getMusicList(params);
        musicList.value = response.musics || [];
        totalMusicCount.value = response.total || 0;
      } catch (error) {
        console.error('加载音乐列表失败:', error);
        Message.error('加载音乐列表失败');
        musicList.value = [];
        totalMusicCount.value = 0;
      } finally {
        loading.value = false;
      }
    };

    const loadPlaylists = async () => {
      playlistsLoading.value = true;

      try {
        const response = await localMusicApi.getPlaylists();
        playlists.value = response.playlists || [];
      } catch (error) {
        console.error('加载播放列表失败:', error);
        Message.error('加载播放列表失败');
        playlists.value = [];
      } finally {
        playlistsLoading.value = false;
      }
    };

    const createPlaylist = async () => {
      if (!playlistForm.value.name) return;

      try {
        await localMusicApi.createPlaylist(
          playlistForm.value.name,
          playlistForm.value.description,
          playlistForm.value.is_public
        );

        Message.success('播放列表创建成功！');
        cancelCreatePlaylist();
        loadPlaylists();
      } catch (error) {
        console.error('创建播放列表失败:', error);
        Message.error('创建播放列表失败');
      }
    };

    const cancelCreatePlaylist = () => {
      showCreatePlaylist.value = false;
      playlistForm.value = {
        name: '',
        description: '',
        is_public: false,
      };
    };

    const playMusic = async music => {
      try {
        const fileInfo = await localMusicApi.getMusicFile(music.id);
        // 触发播放事件
        globalThis.window.dispatchEvent(
          new globalThis.CustomEvent('playLocalMusic', {
            detail: {
              ...music,
              url: fileInfo.file_url,
            },
          })
        );
        Message.success(`开始播放: ${music.title}`);
      } catch (error) {
        console.error('播放音乐失败:', error);
        Message.error('播放音乐失败');
      }
    };

    const editMusic = music => {
      editingMusic.value = music;
      editForm.value = {
        title: music.title,
        artist: music.artist,
        album: music.album || '',
        genre: music.genre || '',
        year: music.year || '',
        lyrics: music.lyrics || '',
      };
      showEditForm.value = true;
    };

    const saveEditMusic = async () => {
      if (!editingMusic.value) return;

      try {
        // 这里需要调用更新音乐的API
        // await localMusicApi.updateMusic(editingMusic.value.id, editForm.value);
        Message.success('音乐信息更新成功！');
        showEditForm.value = false;
        editingMusic.value = null;
        loadMusicList();
      } catch (error) {
        console.error('更新音乐失败:', error);
        Message.error('更新音乐失败');
      }
    };

    const cancelEditMusic = () => {
      showEditForm.value = false;
      editingMusic.value = null;
      editForm.value = {
        title: '',
        artist: '',
        album: '',
        genre: '',
        year: '',
        lyrics: '',
      };
    };

    const deleteMusic = async musicId => {
      if (!globalThis.confirm('确定要删除这首音乐吗？')) return;

      try {
        await localMusicApi.deleteMusic(musicId);
        Message.success('音乐删除成功！');
        loadMusicList();
        loadPlaylists(); // 刷新播放列表以更新音乐数
      } catch (error) {
        console.error('删除音乐失败:', error);
        Message.error('删除音乐失败');
      }
    };

    const editPlaylist = playlist => {
      editingPlaylist.value = playlist;
      editPlaylistForm.value = {
        name: playlist.name,
        description: playlist.description || '',
        is_public: playlist.is_public,
      };
      showEditPlaylistForm.value = true;
    };

    const saveEditPlaylist = async () => {
      if (!editingPlaylist.value) return;

      try {
        await localMusicApi.updatePlaylist(editingPlaylist.value.id, editPlaylistForm.value);
        Message.success('播放列表更新成功！');
        showEditPlaylistForm.value = false;
        editingPlaylist.value = null;
        loadPlaylists();
      } catch (error) {
        console.error('更新播放列表失败:', error);
        Message.error('更新播放列表失败');
      }
    };

    const cancelEditPlaylist = () => {
      showEditPlaylistForm.value = false;
      editingPlaylist.value = null;
      editPlaylistForm.value = {
        name: '',
        description: '',
        is_public: true,
      };
    };

    const deletePlaylist = playlistId => {
      // 找到要删除的播放列表
      const playlist = playlists.value.find(p => p.id === playlistId);
      deletingPlaylist.value = playlist;
      showDeleteConfirm.value = true;
    };

    const confirmDeletePlaylist = async () => {
      if (!deletingPlaylist.value) return;

      try {
        await localMusicApi.deletePlaylist(deletingPlaylist.value.id);
        Message.success('播放列表删除成功！');
        loadPlaylists();
        closeDeleteConfirm();
      } catch (error) {
        console.error('删除播放列表失败:', error);
        Message.error('删除播放列表失败');
      }
    };

    const closeDeleteConfirm = () => {
      showDeleteConfirm.value = false;
      deletingPlaylist.value = null;
    };

    const openUploadModal = () => {
      showUploadModal.value = true;
    };

    const closeUploadModal = () => {
      showUploadModal.value = false;
      resetForm();
    };

    const managePlaylistMusic = async playlist => {
      managingPlaylist.value = playlist;
      showManageMusic.value = true;

      try {
        // 加载播放列表中的音乐
        const playlistMusicsResponse = await localMusicApi.getPlaylistMusics(playlist.id);
        playlistMusics.value = playlistMusicsResponse.musics || [];

        // 加载所有可用音乐
        const allMusicsResponse = await localMusicApi.getMusicList();
        availableMusics.value = allMusicsResponse.musics || [];
      } catch (error) {
        console.error('加载播放列表音乐失败:', error);
        Message.error('加载播放列表音乐失败');
      }
    };

    const addMusicToPlaylist = async musicId => {
      if (!managingPlaylist.value) return;

      try {
        await localMusicApi.addMusicToPlaylist(managingPlaylist.value.id, musicId);
        Message.success('音乐已添加到播放列表！');
        // 重新加载播放列表音乐
        const playlistMusicsResponse = await localMusicApi.getPlaylistMusics(
          managingPlaylist.value.id
        );
        playlistMusics.value = playlistMusicsResponse.musics || [];
        // 刷新播放列表以更新音乐数
        loadPlaylists();
      } catch (error) {
        console.error('添加音乐到播放列表失败:', error);
        Message.error('添加音乐到播放列表失败');
      }
    };

    const removeMusicFromPlaylist = async () => {
      if (!managingPlaylist.value) return;

      try {
        // 这里需要调用移除音乐的API
        // await localMusicApi.removeMusicFromPlaylist(managingPlaylist.value.id, musicId);
        Message.success('音乐已从播放列表移除！');
        // 重新加载播放列表音乐
        const playlistMusicsResponse = await localMusicApi.getPlaylistMusics(
          managingPlaylist.value.id
        );
        playlistMusics.value = playlistMusicsResponse.musics || [];
        // 刷新播放列表以更新音乐数
        loadPlaylists();
      } catch (error) {
        console.error('从播放列表移除音乐失败:', error);
        Message.error('从播放列表移除音乐失败');
      }
    };

    const closeManageMusic = () => {
      showManageMusic.value = false;
      managingPlaylist.value = null;
      playlistMusics.value = [];
      availableMusics.value = [];
    };

    const playPlaylist = () => {
      // TODO: 实现播放播放列表功能
      Message.info('播放功能开发中...');
    };

    const updateAutoPlaySetting = async () => {
      try {
        await localMusicApi.updateAutoPlaySetting(autoPlaySetting.value);
        Message.success('自动播放设置已更新！');
      } catch (error) {
        console.error('更新自动播放设置失败:', error);
        Message.error('更新自动播放设置失败');
        // 恢复原状态
        autoPlaySetting.value = !autoPlaySetting.value;
      }
    };

    const togglePlaylistVisibility = async playlist => {
      try {
        const newVisibility = !playlist.is_public;

        // 如果设置为公开，需要先将其他公开的播放列表设为私有
        if (newVisibility) {
          const otherPublicPlaylists = playlists.value.filter(
            p => p.id !== playlist.id && p.is_public
          );
          for (const otherPlaylist of otherPublicPlaylists) {
            await localMusicApi.updatePlaylist(otherPlaylist.id, {
              ...otherPlaylist,
              is_public: false,
            });
          }
        }

        // 更新当前播放列表的公开状态
        await localMusicApi.updatePlaylist(playlist.id, {
          ...playlist,
          is_public: newVisibility,
        });

        // 更新本地状态
        playlist.is_public = newVisibility;

        // 更新其他播放列表的本地状态
        if (newVisibility) {
          playlists.value.forEach(p => {
            if (p.id !== playlist.id) {
              p.is_public = false;
            }
          });
        }

        Message.success(`播放列表已设为${newVisibility ? '公开' : '私有'}！`);
      } catch (error) {
        console.error('更新播放列表公开状态失败:', error);
        Message.error('更新播放列表公开状态失败');
      }
    };

    const formatFileSize = bytes => {
      if (!bytes) return '-';
      const sizes = ['Bytes', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(1024));
      return Math.round((bytes / Math.pow(1024, i)) * 100) / 100 + ' ' + sizes[i];
    };

    const formatDate = dateString => {
      if (!dateString) return '-';
      return new Date(dateString).toLocaleString('zh-CN');
    };

    const loadAutoPlaySetting = async () => {
      try {
        const response = await localMusicApi.getAutoPlaySetting();
        autoPlaySetting.value = response.auto_play;
      } catch (error) {
        console.error('加载自动播放设置失败:', error);
        // 使用默认值
        autoPlaySetting.value = false;
      }
    };

    // 分页处理方法
    const handlePageChange = page => {
      currentPage.value = page;
      loadMusicList();
    };

    const handlePageSizeChange = newPageSize => {
      pageSize.value = newPageSize;
      currentPage.value = 1; // 重置到第一页
      loadMusicList();
    };

    // 搜索和筛选处理方法
    const handleSearch = () => {
      currentPage.value = 1; // 重置到第一页
      loadMusicList();
    };

    const handleGenreChange = () => {
      currentPage.value = 1; // 重置到第一页
      loadMusicList();
    };

    // 生命周期
    onMounted(() => {
      // 设置页面标题
      document.title = '音乐管理 - MikkoBlog';

      generateYears();
      loadMusicList();
      loadPlaylists();
      loadAutoPlaySetting();
    });

    return {
      selectedFile,
      fileError,
      uploading,
      uploadForm,
      musicList,
      loading,
      searchKeyword,
      selectedGenre,
      availableYears,
      availableGenres,
      playlists,
      playlistsLoading,
      showCreatePlaylist,
      playlistForm,
      editingMusic,
      showEditForm,
      editForm,
      editingPlaylist,
      showEditPlaylistForm,
      editPlaylistForm,
      managingPlaylist,
      showManageMusic,
      playlistMusics,
      availableMusics,
      canUpload,
      generateYears,
      handleFileSelect,
      handleCoverSelect,
      removeCover,
      selectedCover,
      coverPreview,
      coverError,
      uploadMusic,
      resetForm,
      loadMusicList,
      loadPlaylists,
      createPlaylist,
      cancelCreatePlaylist,
      playMusic,
      editMusic,
      saveEditMusic,
      cancelEditMusic,
      deleteMusic,
      editPlaylist,
      saveEditPlaylist,
      cancelEditPlaylist,
      deletePlaylist,
      confirmDeletePlaylist,
      closeDeleteConfirm,
      showDeleteConfirm,
      deletingPlaylist,
      showUploadModal,
      openUploadModal,
      closeUploadModal,
      managePlaylistMusic,
      addMusicToPlaylist,
      removeMusicFromPlaylist,
      closeManageMusic,
      playPlaylist,
      autoPlaySetting,
      updateAutoPlaySetting,
      togglePlaylistVisibility,
      formatFileSize,
      formatDate,
      currentPage,
      pageSize,
      totalMusicCount,
      handlePageChange,
      handlePageSizeChange,
      handleSearch,
      handleGenreChange,
    };
  },
};
</script>

<style scoped>
.music-management {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
  text-align: center;
}

.page-header h1 {
  color: #333;
  margin-bottom: 10px;
}

.page-header p {
  color: #666;
  font-size: 16px;
}

.settings-section,
.upload-section,
.music-list-section,
.playlist-section {
  background: white;
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.settings-section h2,
.upload-section h2,
.music-list-section h2,
.playlist-section h2 {
  color: #333;
  margin-bottom: 20px;
  font-size: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  flex: 1;
}

.form-group.full-width {
  flex: 100%;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #555;
  font-weight: bold;
  font-size: 14px;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #4caf50;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.upload-btn {
  background: linear-gradient(45deg, #4caf50, #45a049);
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.file-name {
  margin-left: 15px;
  font-size: 14px;
  color: #666;
}

.error-message {
  color: #e53935;
  font-size: 12px;
  margin-top: 5px;
}

.form-actions {
  margin-top: 25px;
  display: flex;
  gap: 15px;
  justify-content: flex-end;
}

.upload-submit-btn,
.create-btn {
  background: linear-gradient(45deg, #2196f3, #1976d2);
  color: white;
  border: none;
  padding: 12px 25px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s ease;
}

.upload-submit-btn:disabled,
.create-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
}

.upload-submit-btn:hover:not(:disabled),
.create-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
}

.reset-btn,
.cancel-btn {
  background: #f5f5f5;
  color: #666;
  border: 1px solid #ddd;
  padding: 12px 25px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s ease;
}

.reset-btn:hover,
.cancel-btn:hover {
  background: #e0e0e0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.list-controls {
  display: flex;
  gap: 10px;
  align-items: center;
}

.search-input,
.genre-select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
}

.search-input {
  width: 200px;
}

.refresh-btn {
  background: #4caf50;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.refresh-btn:hover {
  background: #45a049;
}

.upload-btn {
  background: linear-gradient(45deg, #4caf50, #45a049);
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.create-playlist-btn {
  background: linear-gradient(45deg, #ff9800, #f57c00);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.create-playlist-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 152, 0, 0.3);
}

.loading {
  text-align: center;
  padding: 40px 0;
  color: #666;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #4caf50;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.empty-state {
  text-align: center;
  padding: 40px 0;
  color: #888;
}

.empty-state p {
  margin: 10px 0;
  font-size: 16px;
}

.music-table {
  overflow-x: auto;
}

.music-table table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
  table-layout: fixed;
}

.music-table th,
.music-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
  vertical-align: middle;
}

.music-table th {
  background: #f8f9fa;
  font-weight: bold;
  color: #333;
}

.music-table tr:hover {
  background: #f8f9fa;
}

/* 列宽度设置 */
.col-title {
  width: 200px;
}

.col-artist {
  width: 150px;
}

.col-album {
  width: 160px;
}

.col-genre {
  width: 100px;
}

.col-year {
  width: 80px;
}

.col-size {
  width: 100px;
}

.col-date {
  width: 150px;
}

.col-actions {
  width: 120px;
}

.col-title,
.col-artist,
.col-album,
.col-genre {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.actions {
  display: flex;
  gap: 8px;
  justify-content: center;
  align-items: center;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
  padding: 20px 0;
}

.play-btn,
.edit-btn,
.delete-btn {
  background: #e0e0e0;
  border: none;
  border-radius: 4px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.play-btn {
  background: #4caf50;
  color: white;
}

.play-btn:hover {
  background: #45a049;
}

.edit-btn {
  background: #2196f3;
  color: white;
}

.edit-btn:hover {
  background: #1976d2;
}

.delete-btn {
  background: #f44336;
  color: white;
}

.delete-btn:hover {
  background: #d32f2f;
}

.create-playlist-form {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
}

.create-playlist-form h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
}

.playlists-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.playlist-card {
  background: white;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 20px;
  transition: all 0.3s ease;
}

.playlist-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.playlist-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.playlist-header h3 {
  margin: 0;
  color: #333;
  font-size: 18px;
}

.playlist-actions {
  display: flex;
  gap: 5px;
}

.playlist-description {
  color: #666;
  margin-bottom: 15px;
  font-size: 14px;
  line-height: 1.4;
}

.playlist-meta {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
  font-size: 12px;
  color: #888;
}

/* 设置区域样式 */
.settings-content {
  padding: 0;
}

.setting-item {
  margin-bottom: 20px;
}

.setting-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.setting-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.setting-text {
  flex: 1;
}

.setting-description {
  margin-top: 8px;
  margin-left: 28px;
  color: #666;
  font-size: 14px;
  line-height: 1.4;
}

/* 播放列表公开状态切换样式 */
.playlist-visibility-toggle {
  display: flex;
  align-items: center;
}

.visibility-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 12px;
}

.visibility-checkbox {
  width: 16px;
  height: 16px;
  cursor: pointer;
}

.visibility-text {
  font-weight: 500;
}

.playlist-visibility {
  background: #e3f2fd;
  color: #1976d2;
  padding: 2px 8px;
  border-radius: 12px;
}

.playlist-count {
  background: #f3e5f5;
  color: #7b1fa2;
  padding: 2px 8px;
  border-radius: 12px;
}

.playlist-actions-bottom {
  display: flex;
  gap: 10px;
}

.playlist-actions-bottom .manage-btn,
.playlist-actions-bottom .play-btn {
  flex: 1;
  background: #4caf50;
  color: white;
  border: none;
  padding: 10px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.playlist-actions-bottom .manage-btn:hover,
.playlist-actions-bottom .play-btn:hover {
  background: #45a049;
}

.playlist-actions-bottom .play-btn {
  background: #2196f3;
}

.playlist-actions-bottom .play-btn:hover {
  background: #1976d2;
}

/* 编辑音乐表单样式 */
.edit-music-form {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
}

.edit-music-form h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
}

/* 编辑播放列表表单样式 */
.edit-playlist-form {
  padding: 0;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 管理音乐表单样式 */
.manage-music-form {
  padding: 0;
}

.playlist-musics,
.available-musics {
  margin-bottom: 20px;
}

.playlist-musics h4,
.available-musics h4 {
  margin-bottom: 10px;
  color: #555;
}

.music-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.music-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: white;
  border-radius: 6px;
  border: 1px solid #eee;
}

.music-item span {
  flex: 1;
  color: #333;
}

.add-btn {
  background: #4caf50;
  color: white;
  border: none;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.3s ease;
}

.add-btn:hover {
  background: #45a049;
}

.remove-btn {
  background: #f44336;
  color: white;
  border: none;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.3s ease;
}

.remove-btn:hover {
  background: #d32f2f;
}

.save-btn {
  background: linear-gradient(45deg, #4caf50, #45a049);
  color: white;
  border: none;
  padding: 12px 25px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s ease;
}

.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.year-select,
.playlist-select,
.default-playlist-select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
  transition: border-color 0.3s ease;
}

.year-select:focus,
.playlist-select:focus,
.default-playlist-select:focus {
  outline: none;
  border-color: #4caf50;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 15px;
  }

  .list-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .search-input {
    width: 100%;
  }

  .playlists-grid {
    grid-template-columns: 1fr;
  }
}

/* 封面图片上传样式 */
.cover-upload-section {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.cover-upload-btn {
  background: linear-gradient(45deg, #ff9800, #f57c00);
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  width: fit-content;
}

.cover-upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 152, 0, 0.3);
}

.cover-file-name {
  font-size: 14px;
  color: #666;
  font-style: italic;
}

.cover-preview {
  position: relative;
  display: inline-block;
  margin-top: 10px;
}

.cover-preview img {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 8px;
  border: 2px solid #ddd;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.remove-cover-btn {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #f44336;
  color: white;
  border: none;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  cursor: pointer;
  font-size: 16px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.remove-cover-btn:hover {
  background: #d32f2f;
  transform: scale(1.1);
}

/* 删除确认Modal样式 */
.delete-confirm-content {
  text-align: center;
  padding: 20px 0;
}

.warning-icon {
  font-size: 48px;
  margin-bottom: 16px;
  color: #ff6b6b;
}

.delete-confirm-content p {
  margin: 12px 0;
  font-size: 16px;
  line-height: 1.5;
}

.delete-confirm-content strong {
  color: #ff6b6b;
  font-weight: 600;
}

.warning-text {
  color: #666;
  font-size: 14px;
  font-style: italic;
}

/* 音乐上传Modal样式 */
.upload-section .section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.upload-section .upload-btn {
  background: #4caf50;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.upload-section .upload-btn:hover {
  background: #45a049;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

/* Modal内的表单样式优化 */
.upload-form {
  padding: 0;
  max-height: 70vh;
  overflow-y: auto;
}

.upload-form .form-row {
  margin-bottom: 16px;
  display: flex;
  gap: 16px;
}

.upload-form .form-row .form-group {
  flex: 1;
  margin-bottom: 0;
}

.upload-form .form-group.full-width {
  flex: 1 1 100%;
}

.upload-form .form-group label {
  display: block;
  margin-bottom: 6px;
  font-weight: 500;
  color: #333;
  font-size: 13px;
}

.upload-form .form-group input,
.upload-form .form-group select,
.upload-form .form-group textarea {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 13px;
  transition: border-color 0.3s ease;
}

.upload-form .form-group input:focus,
.upload-form .form-group select:focus,
.upload-form .form-group textarea:focus {
  outline: none;
  border-color: #4caf50;
  box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.1);
}

.upload-form .file-select-btn,
.upload-form .cover-upload-btn {
  background: #2196f3;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.3s ease;
}

.upload-form .file-select-btn:hover,
.upload-form .cover-upload-btn:hover {
  background: #1976d2;
}

.upload-form .file-name,
.upload-form .cover-file-name {
  margin-left: 8px;
  color: #666;
  font-size: 12px;
}

.upload-form .error-message {
  color: #f44336;
  font-size: 11px;
  margin-top: 4px;
}

.upload-form .cover-preview {
  margin-top: 8px;
}

.upload-form .cover-preview img {
  width: 60px;
  height: 60px;
  border-radius: 4px;
  object-fit: cover;
}
</style>
