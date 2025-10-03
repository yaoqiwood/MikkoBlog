<template>
  <div class="blog-home" :style="{ '--bg-image': backgroundImageUrl }">
    <!-- 头部导航 -->
    <header class="blog-header">
      <div class="header-container">
        <div class="blog-title">
          <h1>{{ homepageSettings.header_title || userProfile.blog_title || 'MikkoBlog' }}</h1>
        </div>
        <nav class="main-nav">
          <a
            href="#"
            class="nav-item"
            :class="{ active: currentView === 'home' }"
            @click="switchView('home')"
            >首页</a
          >
          <a
            href="#"
            class="nav-item"
            :class="{ active: currentView === 'columns' }"
            @click="switchView('columns')"
            >专栏</a
          >
          <a href="#" class="nav-item">关于我</a>
        </nav>
        <div class="search-box">
          <i class="search-icon">🔍</i>
        </div>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="main-content">
      <div class="content-container">
        <!-- 左侧边栏 -->
        <aside class="left-sidebar">
          <!-- 用户信息卡片 -->
          <div class="user-card">
            <div class="profile-banner">
              <img v-if="bannerImageUrl" :src="bannerImageUrl" alt="Profile Banner" />
              <img
                v-else
                src="https://via.placeholder.com/300x120/ffb6c1/ffffff?text=Anime+Girl"
                alt="Profile Banner"
              />
            </div>
            <div class="profile-info">
              <!-- 加载状态 -->
              <div v-if="profileLoading" class="profile-loading">
                <div class="loading-spinner"></div>
                <span>加载用户信息中...</span>
              </div>

              <!-- 用户信息内容 -->
              <div v-else>
                <div class="avatar">
                  <img :src="userProfile.avatar" :alt="userProfile.nickname" />
                </div>
                <div class="username">@{{ userProfile.nickname }}</div>
                <div class="stats">
                  <span class="stat-item">14 博客</span>
                  <span class="stat-item">37 分享</span>
                  <button class="share-btn">分享</button>
                </div>
                <div class="contact-info">
                  <div v-if="userProfile.email" class="contact-item">
                    <i class="contact-icon">✉️</i>
                    <span>{{ userProfile.email }}</span>
                  </div>
                  <div v-if="userProfile.github_url" class="contact-item">
                    <i class="contact-icon">🐙</i>
                    <span>{{ userProfile.github_url }}</span>
                  </div>
                  <div v-if="userProfile.twitter_url" class="contact-item">
                    <i class="contact-icon">🐦</i>
                    <span>{{ userProfile.twitter_url }}</span>
                  </div>
                  <div v-if="userProfile.weibo_url" class="contact-item">
                    <i class="contact-icon">🔴</i>
                    <span>{{ userProfile.weibo_url }}</span>
                  </div>
                  <div v-if="userProfile.website_url" class="contact-item">
                    <i class="contact-icon">🌐</i>
                    <span>{{ userProfile.website_url }}</span>
                  </div>
                </div>
                <div class="motto">
                  <p>{{ userProfile.motto }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- 音乐播放器 -->
          <div class="music-player">
            <div class="player-header">
              <h3>🎵 音乐播放器</h3>
            </div>
            <div class="current-track">
              <div class="track-info">
                <div class="track-title">風の住む街 - 磯村由纪子</div>
                <div class="track-controls">
                  <button class="play-btn">▶️</button>
                  <div class="progress-bar">
                    <div class="progress"></div>
                  </div>
                  <div class="time">00:00 / 04:45</div>
                  <button class="volume-btn">🔊</button>
                </div>
              </div>
            </div>
            <div class="playlist">
              <div class="playlist-item">風の住む街</div>
              <div class="playlist-item">ヨスガノソラメインテーマ - 記</div>
              <div class="playlist-item">蝶恋</div>
              <div class="playlist-item">月光の雲海</div>
            </div>
          </div>

          <!-- 最受欢迎 -->
          <div class="popular-posts">
            <h3>🌟 最受欢迎</h3>
            <div class="popular-list">
              <div class="popular-item">
                <img src="https://via.placeholder.com/60x60/ff69b4/ffffff?text=1" alt="Popular 1" />
                <div class="popular-info">
                  <div class="popular-title">敏感词过滤已上线</div>
                  <div class="popular-stats">49 浏览</div>
                </div>
              </div>
              <div class="popular-item">
                <img src="https://via.placeholder.com/60x60/87ceeb/ffffff?text=2" alt="Popular 2" />
                <div class="popular-info">
                  <div class="popular-title">小林家的龙女仆</div>
                  <div class="popular-stats">56 浏览</div>
                </div>
              </div>
            </div>
          </div>
        </aside>

        <!-- 主内容区 -->
        <main class="main-area">
          <!-- 首页内容 -->
          <div v-if="currentView === 'home'" class="home-content">
            <div class="content-nav">
              <a
                href="#"
                class="content-nav-item"
                :class="{ active: activeContentType === 'all' }"
                @click.prevent="switchContentType('all')"
              >
                全部
              </a>
              <a
                href="#"
                class="content-nav-item"
                :class="{ active: activeContentType === 'blog' }"
                @click.prevent="switchContentType('blog')"
              >
                博客
              </a>
              <a
                href="#"
                class="content-nav-item"
                :class="{ active: activeContentType === 'moments' }"
                @click.prevent="switchContentType('moments')"
              >
                说说
              </a>
            </div>
            <div class="posts-wrapper">
              <!-- 错误提示 -->
              <div v-if="error" class="error-message">
                <div class="error-content">
                  <i class="error-icon">⚠️</i>
                  <span>{{ error }}</span>
                  <button @click="reloadPosts" class="retry-btn">重新加载</button>
                </div>
              </div>

              <div class="posts-container" @scroll="handleScroll">
                <!-- 内容列表 -->
                <article
                  class="blog-post"
                  v-for="(item, index) in displayedContent"
                  :key="`${item.type}-${item.id}`"
                >
                  <div class="post-header">
                    <div class="post-avatar">
                      <img :src="getFullUrl(item.author_avatar)" :alt="item.author_name" />
                      <div class="post-meta">
                        <div class="author-name">{{ item.author_name }}</div>
                      </div>
                    </div>
                    <div class="content-type-badge" :class="item.type">
                      {{ item.type === 'blog' ? '博客' : '说说' }}
                    </div>
                  </div>
                  <div class="post-content">
                    <!-- 博客文章内容 -->
                    <template v-if="item.type === 'blog'">
                      <h3 class="post-title">{{ item.title }}</h3>
                      <p>{{ item.content }}</p>
                      <div v-if="item.image" class="post-image">
                        <img :src="item.image" :alt="item.title" />
                      </div>
                    </template>

                    <!-- 说说内容 -->
                    <template v-else-if="item.type === 'moment'">
                      <p class="moment-content">{{ item.content }}</p>
                      <!-- 说说图片 -->
                      <div v-if="item.images && item.images.length > 0" class="moment-images">
                        <div class="images-grid" :class="getImageGridClass(item.images.length)">
                          <div
                            v-for="(image, imgIndex) in item.images"
                            :key="image.id"
                            class="moment-image-item"
                            @click="previewImage(item.images, imgIndex)"
                          >
                            <img :src="getFullUrl(image.url)" :alt="image.filename" />
                          </div>
                        </div>
                      </div>
                    </template>
                  </div>
                  <div class="post-stats">
                    <div class="stat-item">
                      <i class="stat-icon">👁️</i>
                      <span>{{ item.views }}</span>
                    </div>
                    <div class="stat-item">
                      <i class="stat-icon">💬</i>
                      <span>{{ item.comments }}</span>
                    </div>
                    <div class="stat-item">
                      <i class="stat-icon">👍</i>
                      <span>{{ item.likes }}</span>
                    </div>
                    <div class="stat-item">
                      <i class="stat-icon">📤</i>
                      <span>{{ item.shares }}</span>
                    </div>
                    <div class="post-time-info">
                      {{ item.create_or_update_time }}
                    </div>
                  </div>
                  <div v-if="index < displayedContent.length - 1" class="post-divider"></div>
                </article>

                <!-- 空状态 -->
                <div v-if="!loading && displayedContent.length === 0 && !error" class="empty-state">
                  <div class="empty-content">
                    <i class="empty-icon">📝</i>
                    <h3>暂无内容</h3>
                    <p>还没有发布任何内容，请稍后再来查看</p>
                  </div>
                </div>

                <!-- 加载状态 -->
                <div v-if="loading" class="loading-indicator">
                  <div class="loading-spinner"></div>
                  <span>加载中...</span>
                </div>

                <!-- 没有更多数据提示 -->
                <div v-if="!hasMore && displayedContent.length > 0" class="no-more-data">
                  <span>没有更多内容了</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 专栏展示 -->
          <div v-if="currentView === 'columns'" class="columns-content">
            <div class="columns-header">
              <h2>📚 博主专栏</h2>
              <p>探索不同技术领域的深度内容</p>
            </div>

            <div v-if="columnsLoading" class="loading-indicator">
              <div class="loading-spinner"></div>
              <span>加载中...</span>
            </div>

            <div v-else class="columns-grid">
              <div
                v-for="column in columnsList"
                :key="column.id"
                class="column-card"
                @click="viewColumnDetail(column)"
              >
                <div class="column-cover">
                  <img
                    v-if="column.cover_image_url"
                    :src="getFullImageUrl(column.cover_image_url)"
                    :alt="column.name"
                  />
                  <div v-else class="default-cover">
                    <span>{{ column.name.charAt(0) }}</span>
                  </div>
                </div>
                <div class="column-info">
                  <h3 class="column-name">{{ column.name }}</h3>
                  <p class="column-description">{{ column.description }}</p>
                  <div class="column-stats">
                    <span class="stat-item">
                      <Icon type="ios-document" />
                      {{ column.post_count }} 篇文章
                    </span>
                    <span class="stat-item">
                      <Icon type="ios-eye" />
                      {{ column.view_count }} 浏览
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="!columnsLoading && columnsList.length === 0" class="empty-columns">
              <Icon type="ios-folder-open" size="48" />
              <p>暂无专栏内容</p>
            </div>
          </div>
        </main>

        <!-- 右侧边栏 -->
        <aside class="right-sidebar">
          <!-- 博主专栏 -->
          <div class="blogger-column">
            <h3>📚 博主专栏</h3>
            <div v-if="sidebarColumnsLoading" class="column-loading">
              <div class="loading-spinner"></div>
              <span>加载中...</span>
            </div>
            <div v-else-if="sidebarColumnsList.length === 0" class="empty-columns">
              <p>暂无专栏</p>
            </div>
            <div v-else class="column-list">
              <div
                v-for="column in sidebarColumnsList.slice(0, 6)"
                :key="column.id"
                class="column-item"
                @click="viewColumnDetail(column)"
              >
                <img
                  v-if="column.cover_image_url"
                  :src="getFullImageUrl(column.cover_image_url)"
                  :alt="column.name"
                />
                <div v-else class="default-column-cover">
                  <span>{{ column.name.charAt(0) }}</span>
                </div>
                <div class="column-title">{{ column.name }}</div>
              </div>
            </div>
          </div>

          <!-- 标签云 -->
          <div class="tag-cloud">
            <h3>🏷️ 标签云</h3>
            <div class="tags">
              <span class="tag large">都是时辰的错!</span>
              <span class="tag medium">生化危机</span>
              <span class="tag small">java</span>
              <span class="tag medium">惊悚恐怖</span>
              <span class="tag small">LO</span>
              <span class="tag large">蕾姆</span>
              <span class="tag medium">二次元</span>
              <span class="tag small">游戏</span>
              <span class="tag medium">Tomcat</span>
              <span class="tag small">Redis</span>
              <span class="tag medium">寂静</span>
              <span class="tag small">Mysql</span>
              <span class="tag medium">开发</span>
              <span class="tag small">生</span>
            </div>
            <div class="tag-decoration">
              <img src="https://via.placeholder.com/100x100/ffb6c1/ffffff?text=Rem" alt="Rem" />
            </div>
          </div>

          <!-- 分类 -->
          <div class="categories">
            <h3>📂 分类</h3>
            <div class="category-list">
              <div class="category-item">默认分类</div>
            </div>
          </div>
        </aside>
      </div>
    </div>

    <!-- 全屏提示 -->
    <div class="fullscreen-tip" v-if="showFullscreenTip">
      <div class="tip-content">按 F11 即可退出全屏模式</div>
    </div>

    <!-- 图片预览 -->
    <Modal
      v-model="showImagePreview"
      width="90%"
      class-name="image-preview-modal"
      :mask-closable="true"
      :closable="true"
    >
      <template #header>
        <div class="preview-header">
          <span
            >图片预览 ({{ previewIndex + 1 }} / {{ previewImages.length }}) -
            {{ Math.round(imageScale * 100) }}%</span
          >
          <div class="preview-actions">
            <Button type="text" @click="zoomOut" size="small" title="缩小 (-)">
              <Icon type="ios-remove" />
            </Button>
            <Button type="text" @click="resetZoom" size="small" title="重置 (0)">
              {{ Math.round(imageScale * 100) }}%
            </Button>
            <Button type="text" @click="zoomIn" size="small" title="放大 (+)">
              <Icon type="ios-add" />
            </Button>
            <Button type="text" @click="prevImage" :disabled="previewIndex === 0" size="small">
              <Icon type="ios-arrow-back" />
              上一张
            </Button>
            <Button
              type="text"
              @click="nextImage"
              :disabled="previewIndex === previewImages.length - 1"
              size="small"
            >
              下一张
              <Icon type="ios-arrow-forward" />
            </Button>
          </div>
        </div>
      </template>
      <div
        class="image-preview-container"
        @wheel="handleWheel"
        @mousemove="onDrag"
        @mouseup="endDrag"
        @mouseleave="endDrag"
      >
        <!-- 左侧箭头 -->
        <div v-if="previewIndex > 0" class="nav-arrow nav-arrow-left" @click="prevImage">
          <Icon type="ios-arrow-back" size="32" />
        </div>

        <!-- 右侧箭头 -->
        <div
          v-if="previewIndex < previewImages.length - 1"
          class="nav-arrow nav-arrow-right"
          @click="nextImage"
        >
          <Icon type="ios-arrow-forward" size="32" />
        </div>

        <img
          :src="previewImageUrl"
          alt="预览图片"
          :style="imageStyle"
          @mousedown="startDrag"
          @click="imageScale > 1 ? null : closeImagePreview()"
          @dragstart.prevent
        />
        <div class="preview-tip">
          {{ imageScale > 1 ? '拖拽移动图片 | 滚轮缩放' : '点击图片关闭预览' }} | 使用 ← →
          键切换图片 | +/- 键缩放 | 0 键重置 | ESC 键关闭
        </div>
      </div>
      <template #footer>
        <div class="preview-footer">
          <Button @click="closeImagePreview">关闭</Button>
        </div>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import {
  authApi,
  columnsApi,
  homepageApi,
  mixedContentApi,
  momentsApi,
  postApi,
} from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';

// 响应式数据
const showFullscreenTip = ref(false);
const blogPosts = ref([]);
const moments = ref([]);
const loading = ref(false);
const hasMore = ref(true);
const currentPage = ref(1);
const pageSize = 10;
const error = ref('');

// 内容类型切换
const activeContentType = ref('all'); // 'all', 'blog', 'moments'

// 视图切换
const currentView = ref('home'); // 'home', 'columns'

// 专栏相关数据
const columnsList = ref([]);
const columnsLoading = ref(false);

// 右侧边栏专栏数据
const sidebarColumnsList = ref([]);
const sidebarColumnsLoading = ref(false);

// 图片预览
const showImagePreview = ref(false);
const previewImages = ref([]);
const previewIndex = ref(0);
const previewImageUrl = ref('');
const imageScale = ref(1);
const imagePosition = ref({ x: 0, y: 0 });
const isDragging = ref(false);
const dragStart = ref({ x: 0, y: 0 });

// 用户资料数据
const userProfile = ref({
  nickname: '',
  email: '',
  bio: '',
  avatar: 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
  blog_title: '',
  blog_subtitle: '',
  motto: '',
  github_url: '',
  twitter_url: '',
  weibo_url: '',
  website_url: '',
});
const profileLoading = ref(false);
const profileError = ref('');

// 主页设置数据
const homepageSettings = ref({
  header_title: '',
  banner_image_url: '',
  background_image_url: '',
  show_music_player: false,
  music_url: '',
  show_live2d: false,
});

// 将相对路径转换为完整URL
const getFullUrl = url => {
  if (!url) return '';

  // 如果是相对路径，转换为完整URL
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }

  return url;
};

// 获取说说图片网格样式类
const getImageGridClass = count => {
  if (count === 1) return 'images-grid-1';
  if (count === 2) return 'images-grid-2';
  if (count === 3) return 'images-grid-3';
  if (count === 4) return 'images-grid-4';
  return 'images-grid-9';
};

// 预览图片
const previewImage = (images, index) => {
  previewImages.value = images;
  previewIndex.value = index;
  previewImageUrl.value = getFullUrl(images[index].url);
  showImagePreview.value = true;

  // 添加键盘事件监听
  document.addEventListener('keydown', handleKeydown);
};

// 键盘导航
const handleKeydown = event => {
  if (!showImagePreview.value) return;

  switch (event.key) {
    case 'ArrowLeft':
      event.preventDefault();
      prevImage();
      break;
    case 'ArrowRight':
      event.preventDefault();
      nextImage();
      break;
    case 'Escape':
      event.preventDefault();
      closeImagePreview();
      break;
    case '=':
    case '+':
      event.preventDefault();
      zoomIn();
      break;
    case '-':
      event.preventDefault();
      zoomOut();
      break;
    case '0':
      event.preventDefault();
      resetZoom();
      break;
  }
};

// 关闭图片预览
const closeImagePreview = () => {
  showImagePreview.value = false;
  document.removeEventListener('keydown', handleKeydown);
  // 重置缩放和位置
  imageScale.value = 1;
  imagePosition.value = { x: 0, y: 0 };
};

// 上一张图片
const prevImage = () => {
  if (previewIndex.value > 0) {
    previewIndex.value--;
    previewImageUrl.value = getFullUrl(previewImages.value[previewIndex.value].url);
    // 重置缩放和位置
    imageScale.value = 1;
    imagePosition.value = { x: 0, y: 0 };
  }
};

// 下一张图片
const nextImage = () => {
  if (previewIndex.value < previewImages.value.length - 1) {
    previewIndex.value++;
    previewImageUrl.value = getFullUrl(previewImages.value[previewIndex.value].url);
    // 重置缩放和位置
    imageScale.value = 1;
    imagePosition.value = { x: 0, y: 0 };
  }
};

// 图片缩放功能
const zoomIn = () => {
  if (imageScale.value < 3) {
    imageScale.value = Math.min(imageScale.value + 0.2, 3);
  }
};

const zoomOut = () => {
  if (imageScale.value > 0.5) {
    imageScale.value = Math.max(imageScale.value - 0.2, 0.5);
    // 如果缩放到1，重置位置
    if (imageScale.value === 1) {
      imagePosition.value = { x: 0, y: 0 };
    }
  }
};

const resetZoom = () => {
  imageScale.value = 1;
  imagePosition.value = { x: 0, y: 0 };
};

// 鼠标滚轮缩放
const handleWheel = event => {
  event.preventDefault();
  if (event.deltaY < 0) {
    zoomIn();
  } else {
    zoomOut();
  }
};

// 拖拽功能
const startDrag = event => {
  if (imageScale.value > 1) {
    isDragging.value = true;
    dragStart.value = {
      x: event.clientX - imagePosition.value.x,
      y: event.clientY - imagePosition.value.y,
    };
    event.preventDefault();
  }
};

const onDrag = event => {
  if (isDragging.value && imageScale.value > 1) {
    imagePosition.value = {
      x: event.clientX - dragStart.value.x,
      y: event.clientY - dragStart.value.y,
    };
  }
};

const endDrag = () => {
  isDragging.value = false;
};

// 计算图片样式
const imageStyle = computed(() => ({
  transform: `scale(${imageScale.value}) translate(${imagePosition.value.x / imageScale.value}px, ${imagePosition.value.y / imageScale.value}px)`,
  cursor: imageScale.value > 1 ? (isDragging.value ? 'grabbing' : 'grab') : 'pointer',
  transition: isDragging.value ? 'none' : 'transform 0.2s ease',
}));

// 计算背景图URL
const backgroundImageUrl = computed(() => {
  const url = homepageSettings.value.background_image_url;

  if (!url) return '';

  const fullUrl = getFullUrl(url);
  return `url(${fullUrl})`;
});

// 计算Banner图片URL
const bannerImageUrl = computed(() => {
  return getFullUrl(homepageSettings.value.banner_image_url);
});

// 计算页面标题
const pageTitle = computed(() => {
  const blogTitle =
    userProfile.value.blog_title || homepageSettings.value.header_title || 'MikkoBlog';
  const blogSubtitle = userProfile.value.blog_subtitle;

  if (blogSubtitle) {
    return `${blogTitle} ${blogSubtitle}`;
  }
  return blogTitle;
});

// 加载主页设置
const loadHomepageSettings = async () => {
  try {
    const settings = await homepageApi.getSettings();
    homepageSettings.value = {
      header_title: settings.header_title || '',
      banner_image_url: settings.banner_image_url || '',
      background_image_url: settings.background_image_url || '',
      show_music_player: !!settings.show_music_player,
      music_url: settings.music_url || '',
      show_live2d: !!settings.show_live2d,
    };
  } catch (err) {
    console.error('加载主页设置失败:', err);
  }
};

// 格式化时间显示
const formatTime = dateString => {
  const date = new Date(dateString);
  const now = new Date();
  const diffTime = Math.abs(now - date);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 1) return '1天前';
  if (diffDays < 7) return `${diffDays}天前`;
  if (diffDays < 30) return `${Math.ceil(diffDays / 7)}周前`;
  if (diffDays < 365) return `${Math.ceil(diffDays / 30)}个月前`;
  return `${Math.ceil(diffDays / 365)}年前`;
};

// 格式化创建/修改时间显示
const formatCreateOrUpdateTime = (createdAt, updatedAt) => {
  const createdDate = new Date(createdAt);
  const updatedDate = updatedAt ? new Date(updatedAt) : null;

  // 如果修改时间为null或空，或者修改时间等于创建时间，显示创建时间
  if (!updatedDate || updatedDate.getTime() === createdDate.getTime()) {
    const timeStr = formatTime(createdAt);
    return `创建于${timeStr}`;
  }

  // 如果修改时间大于创建时间，显示修改时间
  if (updatedDate.getTime() > createdDate.getTime()) {
    const timeStr = formatTime(updatedAt);
    return `修改于${timeStr}`;
  }

  // 默认显示创建时间
  const timeStr = formatTime(createdAt);
  return `创建于${timeStr}`;
};

// 从后端API加载博文
const loadPosts = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    // 调用后端API获取文章列表
    const posts = await postApi.getPosts({
      page: currentPage.value,
      limit: pageSize,
      is_visible: true, // 只获取可见的文章
      is_deleted: false, // 只获取未删除的文章
    });

    if (posts && posts.length > 0) {
      // 转换数据格式以适配前端显示
      const formattedPosts = posts.map(post => ({
        id: post.id,
        type: 'blog',
        title: post.title,
        content: post.summary || post.content.substring(0, 200) + '...',
        time: formatTime(post.created_at),
        display_time: formatTime(post.updated_at || post.created_at), // 优先显示修改时间
        create_or_update_time: formatCreateOrUpdateTime(post.created_at, post.updated_at), // 新的时间显示
        views: post.view_count || 0, // 使用后端返回的真实观看数据
        comments: post.comment_count || 0, // 使用后端返回的真实评论数据
        likes: post.like_count || 0, // 使用后端返回的真实点赞数据
        shares: post.share_count || 0, // 使用后端返回的真实分享数据
        image: post.cover_image_url,
        created_at: post.created_at,
        updated_at: post.updated_at,
        // 添加作者信息 - 使用后端返回的用户信息
        author_name: post.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          post.user_avatar ||
          userProfile.value.avatar ||
          'https://via.placeholder.com/40x40/87ceeb/ffffff?text=A',
      }));

      blogPosts.value.push(...formattedPosts);
      currentPage.value++;

      // 如果返回的文章数量少于页面大小，说明没有更多数据了
      if (posts.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载文章失败:', err);

    // 根据错误类型显示不同的错误信息
    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载文章失败，请稍后重试';
      Message.error('加载文章失败，请稍后重试');
    }

    hasMore.value = false;
  } finally {
    loading.value = false;
  }
};

// 加载说说
const loadMoments = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    const response = await momentsApi.getMoments({
      page: currentPage.value,
      limit: pageSize,
      is_visible: true,
    });

    if (response && response.items && response.items.length > 0) {
      // 转换数据格式以适配前端显示
      const formattedMoments = response.items.map(moment => ({
        id: moment.id,
        type: 'moment',
        content: moment.content,
        time: formatTime(moment.created_at),
        display_time: formatTime(moment.updated_at || moment.created_at),
        create_or_update_time: formatCreateOrUpdateTime(moment.created_at, moment.updated_at),
        views: 0, // 说说暂时没有浏览数
        comments: 0, // 说说暂时没有评论数
        likes: 0, // 说说暂时没有点赞数
        shares: 0, // 说说暂时没有分享数
        images: moment.images || [],
        created_at: moment.created_at,
        updated_at: moment.updated_at,
        author_name: moment.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          moment.user_avatar ||
          userProfile.value.avatar ||
          'https://via.placeholder.com/40x40/87ceeb/ffffff?text=A',
      }));

      moments.value.push(...formattedMoments);
      currentPage.value++;

      // 检查是否还有更多数据
      if (!response.has_more) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载说说失败:', err);

    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载说说失败，请稍后重试';
      Message.error('加载说说失败，请稍后重试');
    }

    hasMore.value = false;
  } finally {
    loading.value = false;
  }
};

// 加载专栏列表
const loadColumns = async () => {
  columnsLoading.value = true;
  try {
    const response = await columnsApi.getColumns({
      is_visible: true,
      limit: 50, // 加载更多专栏
    });

    if (response && response.items) {
      columnsList.value = response.items;
    }
  } catch (err) {
    console.error('加载专栏失败:', err);
    Message.error('加载专栏失败，请稍后重试');
  } finally {
    columnsLoading.value = false;
  }
};

// 加载右侧边栏专栏列表
const loadSidebarColumns = async () => {
  sidebarColumnsLoading.value = true;
  try {
    const response = await columnsApi.getColumns({
      is_visible: true,
      limit: 6, // 只加载前6个专栏用于侧边栏显示
    });

    if (response && response.items) {
      sidebarColumnsList.value = response.items;
    }
  } catch (err) {
    console.error('加载侧边栏专栏失败:', err);
    // 静默失败，不显示错误提示
  } finally {
    sidebarColumnsLoading.value = false;
  }
};

// 视图切换
const switchView = view => {
  if (currentView.value === view) return;

  currentView.value = view;

  if (view === 'columns' && columnsList.value.length === 0) {
    loadColumns();
  }
};

// 查看专栏详情
const viewColumnDetail = column => {
  // 这里可以跳转到专栏详情页面或者展开专栏文章列表
  Message.info(`查看专栏: ${column.name}`);
  // 未来可以实现专栏详情页面
};

// 获取完整图片URL
const getFullImageUrl = url => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return `http://localhost:8000${url}`;
};

// 计算当前显示的内容
const displayedContent = computed(() => {
  let allContent = [];

  if (activeContentType.value === 'all') {
    // 合并博客和说说，按时间排序
    allContent = [...blogPosts.value, ...moments.value];
  } else if (activeContentType.value === 'blog') {
    allContent = [...blogPosts.value];
  } else if (activeContentType.value === 'moments') {
    allContent = [...moments.value];
  }

  // 按创建时间倒序排序
  return allContent.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
});

// 内容类型切换
const switchContentType = type => {
  if (activeContentType.value === type) return;

  activeContentType.value = type;
  currentPage.value = 1;
  hasMore.value = true;
  error.value = '';

  // 清空对应的数据并重新加载
  if (type === 'all') {
    blogPosts.value = [];
    moments.value = [];
    loadAllContent();
  } else if (type === 'blog') {
    blogPosts.value = [];
    loadPosts();
  } else if (type === 'moments') {
    moments.value = [];
    loadMoments();
  }
};

// 加载所有内容（博客+说说）
const loadAllContent = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    const response = await mixedContentApi.getMixedContent({
      page: currentPage.value,
      limit: pageSize,
    });

    if (response && response.items && response.items.length > 0) {
      // 添加格式化的时间信息
      const formattedItems = response.items.map(item => ({
        ...item,
        time: formatTime(item.created_at),
        display_time: formatTime(item.updated_at || item.created_at),
        create_or_update_time: formatCreateOrUpdateTime(item.created_at, item.updated_at),
        author_name: item.author_name || userProfile.value.nickname || '',
        author_avatar:
          item.author_avatar ||
          userProfile.value.avatar ||
          'https://via.placeholder.com/40x40/87ceeb/ffffff?text=A',
      }));

      // 分别添加到对应数组
      blogPosts.value.push(...formattedItems.filter(item => item.type === 'blog'));
      moments.value.push(...formattedItems.filter(item => item.type === 'moment'));

      currentPage.value++;

      // 检查是否还有更多数据
      if (!response.has_more) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载内容失败:', err);

    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载内容失败，请稍后重试';
      Message.error('加载内容失败，请稍后重试');
    }

    hasMore.value = false;
  } finally {
    loading.value = false;
  }
};

// 滚动加载更多
const handleScroll = event => {
  const { scrollTop, scrollHeight, clientHeight } = event.target;
  const threshold = 100; // 距离底部100px时开始加载

  if (scrollHeight - scrollTop - clientHeight < threshold && hasMore.value && !loading.value) {
    if (activeContentType.value === 'all') {
      loadAllContent();
    } else if (activeContentType.value === 'blog') {
      loadPosts();
    } else if (activeContentType.value === 'moments') {
      loadMoments();
    }
  }
};

// 加载用户资料
const loadUserProfile = async () => {
  try {
    profileLoading.value = true;
    profileError.value = '';

    // 假设用户ID为1，实际项目中可能需要从路由参数或其他方式获取
    const userId = 1;
    const profile = await authApi.getPublicProfile(userId);

    // 更新用户资料数据
    userProfile.value = {
      nickname: profile.nickname || '',
      email: profile.email || '',
      bio: profile.bio || '',
      avatar: profile.avatar || 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
      blog_title: profile.blog_title || '',
      blog_subtitle: profile.blog_subtitle || '',
      motto: profile.motto || '',
      github_url: profile.github_url || '',
      twitter_url: profile.twitter_url || '',
      weibo_url: profile.weibo_url || '',
      website_url: profile.website_url || '',
    };
  } catch (err) {
    console.error('加载用户资料失败:', err);

    // 根据错误类型显示不同的错误信息
    if (err.type === 'NETWORK_ERROR') {
      profileError.value = '服务器连接失败，无法加载用户资料';
    } else {
      profileError.value = '加载用户资料失败，使用默认信息';
    }

    // 使用默认数据，不显示错误提示
    console.log('使用默认用户资料数据');
  } finally {
    profileLoading.value = false;
  }
};

// 重新加载数据
const reloadPosts = async () => {
  blogPosts.value = [];
  moments.value = [];
  currentPage.value = 1;
  hasMore.value = true;

  if (activeContentType.value === 'all') {
    await loadAllContent();
  } else if (activeContentType.value === 'blog') {
    await loadPosts();
  } else if (activeContentType.value === 'moments') {
    await loadMoments();
  }
};

// 监听页面标题变化
watch(
  pageTitle,
  newTitle => {
    document.title = newTitle;
  },
  { immediate: true }
);

// 生命周期
onMounted(() => {
  // 检查是否全屏模式
  if (document.fullscreenElement) {
    showFullscreenTip.value = true;
  }

  // 初始加载
  loadUserProfile();
  loadAllContent(); // 默认加载所有内容
  loadHomepageSettings();
  loadSidebarColumns(); // 加载右侧边栏专栏
});

onUnmounted(() => {
  // 清理键盘事件监听器
  document.removeEventListener('keydown', handleKeydown);
});
</script>

<style scoped>
.blog-home {
  min-height: 100vh;
  font-family: 'Microsoft YaHei', sans-serif;
  position: relative;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  /* 使用CSS变量设置背景图，如果没有则使用默认渐变 */
  background-image: var(--bg-image, linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%));
}

/* 头部样式 */
.blog-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60px;
  position: relative;
}

.blog-title h1 {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
}

.main-nav {
  display: flex;
  gap: 30px;
}

.nav-item {
  text-decoration: none;
  color: #333;
  font-weight: 500;
  transition: all 0.3s ease;
  position: relative;
}

.nav-item:hover {
  color: #ff6b6b;
  transform: translateY(-2px);
}

.nav-item::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  transition: width 0.3s ease;
}

.nav-item:hover::after {
  width: 100%;
}

.blog-title {
  position: absolute;
  left: 20px;
}

.blog-title h1 {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
}

.main-nav {
  display: flex;
  gap: 30px;
}

.search-box {
  position: absolute;
  right: 20px;
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.search-box:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.05);
}

/* 主内容区域 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.content-container {
  display: grid;
  grid-template-columns: 280px 1fr 280px;
  gap: 20px;
  align-items: start;
}

/* 左侧边栏 */
.left-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.user-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.user-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}

.profile-banner img {
  width: 100%;
  height: 120px;
  object-fit: cover;
}

.profile-info {
  padding: 20px;
  text-align: center;
}

.avatar {
  margin: -40px auto 15px;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 4px solid white;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.username {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.stats {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-bottom: 15px;
}

.stat-item {
  font-size: 14px;
  color: #666;
}

.share-btn {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  border: none;
  padding: 5px 15px;
  border-radius: 15px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.share-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.contact-info {
  margin-bottom: 15px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.contact-icon {
  font-size: 16px;
}

.motto p {
  font-style: italic;
  color: #888;
  font-size: 14px;
  margin: 0;
}

/* 音乐播放器 */
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
}

.progress {
  width: 30%;
  height: 100%;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 2px;
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

/* 最受欢迎 */
.popular-posts {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.popular-posts h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.popular-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.popular-item {
  display: flex;
  gap: 10px;
  align-items: center;
}

.popular-item img {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.popular-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 5px;
}

.popular-stats {
  font-size: 12px;
  color: #666;
}

/* 主内容区 */
.main-area {
  background: transparent;
  border-radius: 15px;
  padding: 0;
}

/* 内容导航 */
.content-nav {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 10px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.content-nav-item {
  text-decoration: none;
  color: #666;
  font-size: 14px;
  padding: 8px 16px;
  border-radius: 20px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.content-nav-item.active,
.content-nav-item:hover {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.posts-wrapper {
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.posts-container {
  padding: 20px;
  padding-top: 5px;
  max-height: 910px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: #ff6b6b #f0f0f0;
}

.posts-container::-webkit-scrollbar {
  width: 6px;
}

.posts-container::-webkit-scrollbar-track {
  background: transparent;
  margin: 15px 0;
}

.posts-container::-webkit-scrollbar-thumb {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 3px;
  border: 1px solid white;
}

.posts-container::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(45deg, #ff5252, #26a69a);
}

.blog-post {
  padding: 20px 0;
  transition: all 0.3s ease;
}

.blog-post:hover {
  background: rgba(255, 107, 107, 0.02);
  border-radius: 10px;
  padding: 20px;
  margin: 0 -20px;
}

.blog-post:last-child {
  padding-bottom: 0;
}

.post-divider {
  height: 1px;
  background: linear-gradient(90deg, transparent, #eee, transparent);
  margin: 20px 0;
}

/* 加载状态 */
.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 20px;
  color: #666;
  font-size: 14px;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 错误提示 */
.error-message {
  margin-bottom: 20px;
}

.error-content {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px 20px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 10px;
  color: #dc2626;
}

.error-icon {
  font-size: 18px;
}

.retry-btn {
  background: #dc2626;
  color: white;
  border: none;
  padding: 5px 15px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.3s ease;
}

.retry-btn:hover {
  background: #b91c1c;
  transform: translateY(-1px);
}

/* 空状态 */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-content {
  color: #666;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 15px;
  display: block;
}

.empty-content h3 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 18px;
}

.empty-content p {
  margin: 0;
  font-size: 14px;
  color: #666;
}

/* 文章标题样式 */
.post-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0 0 10px 0;
  line-height: 1.4;
}

/* 没有更多数据提示 */
.no-more-data {
  text-align: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
  border-top: 1px solid #eee;
  margin-top: 10px;
}

.post-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 15px;
  position: relative;
}

.post-header .post-avatar {
  display: flex;
  align-items: center;
  gap: 10px;
}

.post-avatar img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.author-name {
  font-weight: bold;
  font-size: 16px;
  color: #333;
}

.post-time {
  font-size: 12px;
  color: #666;
}

.post-content {
  margin-bottom: 15px;
}

.post-content p {
  color: #333;
  line-height: 1.6;
  margin: 0 0 10px 0;
}

.post-image img {
  width: 100%;
  max-width: 400px;
  border-radius: 10px;
  margin-top: 10px;
}

.post-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
}

.stat-item:hover {
  color: #ff6b6b;
  transform: translateY(-1px);
}

.post-time-info {
  font-size: 12px;
  color: #999;
  font-style: italic;
  margin-left: auto;
}

/* 右侧边栏 */
.right-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.blogger-column,
.tag-cloud,
.categories {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.blogger-column h3,
.tag-cloud h3,
.categories h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.column-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.column-item {
  text-align: center;
}

.column-item img {
  width: 80px;
  height: 80px;
  border-radius: 10px;
  object-fit: cover;
  margin-bottom: 8px;
}

.column-title {
  font-size: 14px;
  color: #333;
}

/* 标签云 */
.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 15px;
}

.tag {
  padding: 5px 10px;
  border-radius: 15px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tag:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.tag.small {
  font-size: 11px;
  padding: 3px 8px;
}

.tag.medium {
  font-size: 13px;
  padding: 6px 12px;
}

.tag.large {
  font-size: 15px;
  padding: 8px 15px;
}

.tag-decoration {
  text-align: center;
}

.tag-decoration img {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  opacity: 0.8;
}

/* 分类 */
.category-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.category-item {
  padding: 10px 15px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  color: #333;
}

.category-item:hover {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  transform: translateX(5px);
}

/* 全屏提示 */
.fullscreen-tip {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 15px 30px;
  border-radius: 10px;
  z-index: 9999;
  animation: fadeInOut 3s ease-in-out;
}

@keyframes fadeInOut {
  0%,
  100% {
    opacity: 0;
  }
  20%,
  80% {
    opacity: 1;
  }
}

/* 用户资料加载状态 */
.profile-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #666;
}

.profile-loading .loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 10px;
}

.profile-loading span {
  font-size: 14px;
  color: #999;
}

/* 内容类型标识 */
.content-type-badge {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 15px;
  color: white;
  font-weight: 500;
  position: absolute;
  top: 0;
  right: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.content-type-badge.blog {
  background: linear-gradient(45deg, #667eea, #764ba2);
}

.content-type-badge.moment {
  background: linear-gradient(45deg, #f093fb, #f5576c);
}

/* 说说内容样式 */
.moment-content {
  color: #333;
  line-height: 1.6;
  margin: 0 0 10px 0;
  font-size: 16px;
}

/* 说说图片网格 */
.moment-images {
  margin: 12px 0;
}

.images-grid {
  display: grid;
  gap: 4px;
  border-radius: 8px;
  overflow: hidden;
}

.images-grid-1 {
  grid-template-columns: 1fr;
  max-width: 300px;
}

.images-grid-2 {
  grid-template-columns: 1fr 1fr;
  max-width: 300px;
}

.images-grid-3 {
  grid-template-columns: 1fr 1fr 1fr;
  max-width: 300px;
}

.images-grid-4 {
  grid-template-columns: 1fr 1fr;
  max-width: 300px;
}

.images-grid-9 {
  grid-template-columns: 1fr 1fr 1fr;
  max-width: 300px;
}

.moment-image-item {
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.moment-image-item:hover {
  transform: scale(1.02);
}

.moment-image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* 图片预览样式 */
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.preview-actions {
  display: flex;
  gap: 8px;
  margin-right: 20px;
}

.image-preview-container {
  text-align: center;
  position: relative;
  background: #f5f5f5;
  border-radius: 8px;
  padding: 16px;
  min-height: 300px;
  max-height: 60vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  user-select: none;
}

.image-preview-container img {
  max-width: 100%;
  max-height: 50vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform-origin: center center;
}

/* 导航箭头 */
.nav-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 60px;
  height: 60px;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  transition: all 0.3s ease;
  z-index: 20;
  opacity: 0.7;
}

.nav-arrow:hover {
  background: rgba(0, 0, 0, 0.7);
  opacity: 1;
  transform: translateY(-50%) scale(1.1);
}

.nav-arrow-left {
  left: 20px;
}

.nav-arrow-right {
  right: 20px;
}

.preview-tip {
  margin-top: 8px;
  color: #999;
  font-size: 12px;
  line-height: 1.4;
}

.preview-footer {
  text-align: center;
}

:deep(.image-preview-modal .ivu-modal-body) {
  padding: 16px;
}

:deep(.image-preview-modal .ivu-modal-header) {
  border-bottom: 1px solid #e8eaec;
}

:deep(.image-preview-modal .ivu-modal-footer) {
  border-top: 1px solid #e8eaec;
  text-align: center;
}

/* 导航激活状态 */
.nav-item.active {
  color: #2d8cf0;
  font-weight: 600;
  border-bottom: 2px solid #2d8cf0;
}

/* 专栏展示样式 */
.columns-content {
  padding: 20px;
}

.columns-header {
  text-align: center;
  margin-bottom: 30px;
}

.columns-header h2 {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.columns-header p {
  color: #666;
  font-size: 16px;
}

.columns-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.column-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 1px solid #f0f0f0;
}

.column-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.column-cover {
  height: 180px;
  overflow: hidden;
  position: relative;
}

.column-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.column-card:hover .column-cover img {
  transform: scale(1.05);
}

.default-cover {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 48px;
  font-weight: bold;
}

.column-info {
  padding: 20px;
}

.column-name {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin-bottom: 10px;
  line-height: 1.3;
}

.column-description {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 15px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.column-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #999;
  font-size: 13px;
}

.stat-item i {
  font-size: 14px;
}

.empty-columns {
  text-align: center;
  padding: 60px 20px;
  color: #999;
}

.empty-columns i {
  margin-bottom: 15px;
  color: #ddd;
}

.empty-columns p {
  font-size: 16px;
}

/* 右侧边栏专栏样式 */
.column-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
}

.column-loading .loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 8px;
}

.column-item {
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 8px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.column-item:hover {
  background: rgba(255, 107, 107, 0.05);
  transform: translateY(-2px);
}

.column-item img {
  width: 70px;
  height: 70px;
  border-radius: 8px;
  object-fit: cover;
  margin: 0 auto 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: block;
}

.default-column-cover {
  width: 70px;
  height: 70px;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 22px;
  font-weight: bold;
  margin: 0 auto 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.column-title {
  font-size: 12px;
  color: #333;
  font-weight: 500;
  text-align: center;
  word-wrap: break-word;
  max-width: 100%;
  line-height: 1.3;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .blog-home {
    background-size: contain;
    background-attachment: scroll;
  }

  .content-container {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .left-sidebar,
  .right-sidebar {
    order: 2;
  }

  .main-area {
    order: 1;
  }
}

@media (max-width: 768px) {
  .blog-home {
    background-size: contain;
    background-attachment: scroll;
  }

  .header-container {
    flex-direction: column;
    height: auto;
    padding: 15px 20px;
  }

  .main-nav {
    margin: 10px 0;
  }

  .content-container {
    padding: 10px;
  }
}

@media (max-width: 480px) {
  .blog-home {
    background-size: contain;
    background-position: center top;
  }
}
</style>
