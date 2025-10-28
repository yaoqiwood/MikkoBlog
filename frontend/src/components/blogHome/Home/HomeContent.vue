<template>
  <div class="home-content">
    <div class="content-nav">
      <a
        href="#"
        class="content-nav-item"
        :class="{ active: activeContentType === 'all' }"
        @click.prevent="$emit('switchContentType', 'all')"
      >
        全部
      </a>
      <a
        href="#"
        class="content-nav-item"
        :class="{ active: activeContentType === 'blog' }"
        @click.prevent="$emit('switchContentType', 'blog')"
      >
        博客
      </a>
      <a
        href="#"
        class="content-nav-item"
        :class="{ active: activeContentType === 'moments' }"
        @click.prevent="$emit('switchContentType', 'moments')"
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
          <button @click="$emit('reloadPosts')" class="retry-btn">重新加载</button>
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
              <h3 class="post-title" @click="$emit('viewBlogDetail', item.id)">{{ item.title }}</h3>
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
                    @click="$emit('previewImage', item.images, imgIndex)"
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
</template>

<script setup>
defineProps({
  activeContentType: {
    type: String,
    default: 'all',
  },
  displayedContent: {
    type: Array,
    default: () => [],
  },
  loading: {
    type: Boolean,
    default: false,
  },
  hasMore: {
    type: Boolean,
    default: true,
  },
  error: {
    type: String,
    default: '',
  },
});

const emit = defineEmits([
  'switchContentType',
  'viewBlogDetail',
  'previewImage',
  'reloadPosts',
  'handleScroll',
]);

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

// 滚动加载更多
const handleScroll = event => {
  emit('handleScroll', event);
};
</script>

<style scoped>
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
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: #ff6b6b #f0f0f0;
  max-height: 101vh; /* 设置最大高度，确保有滚动条 */
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
  cursor: pointer;
  transition: all 0.3s ease;
}

.post-title:hover {
  color: #ff6b6b;
  transform: translateX(5px);
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
</style>
