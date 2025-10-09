<template>
  <div class="column-detail-content">
    <div class="column-detail-card">
      <div class="column-detail-header">
        <div class="back-button" @click="$emit('backToColumns')">
          <Icon type="ios-arrow-back" />
          <span>返回专栏列表</span>
        </div>
        <div class="column-info">
          <h2>{{ currentColumn?.name }}</h2>
          <p>{{ currentColumn?.description }}</p>
          <div class="column-stats">
            <span class="stat-item">
              <Icon type="ios-document" />
              {{ columnPostsList.length }} 篇文章
            </span>
            <span class="stat-item">
              <Icon type="ios-eye" />
              {{ currentColumn?.view_count || 0 }} 浏览
            </span>
          </div>
        </div>
      </div>

      <div v-if="columnPostsLoading" class="loading-indicator">
        <div class="loading-spinner"></div>
        <span>加载中...</span>
      </div>

      <div v-else class="column-posts-section">
        <div class="posts-card-header">
          <h3>📚 专栏文章</h3>
          <span class="posts-count">{{ columnPostsList.length }} 篇文章</span>
        </div>
        <div v-if="columnPostsList.length > 0" class="column-posts-grid">
          <div
            v-for="post in columnPostsList"
            :key="post.id"
            class="post-card"
            @click="$emit('viewBlogDetail', post.id)"
          >
            <div class="card-cover">
              <img
                v-if="post.image"
                :src="getFullUrl(post.image)"
                :alt="post.title"
                class="cover-image"
              />
              <div v-else class="default-cover">
                <Icon type="ios-document" size="48" />
              </div>
              <div class="card-overlay">
                <div class="content-type-badge blog">博客</div>
              </div>
            </div>
            <div class="card-content">
              <h3 class="card-title">{{ post.title }}</h3>
              <p class="card-summary">{{ post.content }}</p>
              <div class="card-meta">
                <div class="author-info">
                  <img
                    :src="getFullUrl(post.author_avatar)"
                    :alt="post.author_name"
                    class="author-avatar"
                  />
                  <span class="author-name">{{ post.author_name }}</span>
                </div>
                <div class="post-stats">
                  <div class="stat-item">
                    <Icon type="ios-eye" size="14" />
                    <span>{{ post.views }}</span>
                  </div>
                  <div class="stat-item">
                    <Icon type="ios-chatbubble" size="14" />
                    <span>{{ post.comments }}</span>
                  </div>
                  <div class="stat-item">
                    <Icon type="ios-heart" size="14" />
                    <span>{{ post.likes }}</span>
                  </div>
                </div>
              </div>
              <div class="card-footer">
                <span class="post-time">{{ post.create_or_update_time }}</span>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="empty-state">
          <div class="empty-content">
            <i class="empty-icon">📝</i>
            <h3>暂无文章</h3>
            <p>该专栏还没有发布任何文章，请稍后再来查看</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Icon } from 'view-ui-plus';

defineProps({
  currentColumn: {
    type: Object,
    default: null,
  },
  columnPostsList: {
    type: Array,
    default: () => [],
  },
  columnPostsLoading: {
    type: Boolean,
    default: false,
  },
});

defineEmits(['backToColumns', 'viewBlogDetail']);

// 将相对路径转换为完整URL
const getFullUrl = url => {
  if (!url) return '';

  // 如果是相对路径，转换为完整URL
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }

  return url;
};
</script>

<style scoped>
/* 专栏文章列表样式 */
.column-detail-content {
  padding: 0;
}

.column-detail-card {
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  overflow: hidden;
  padding: 24px;
}

.column-detail-header {
  margin-bottom: 30px;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  cursor: pointer;
  margin-bottom: 20px;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s ease;
  width: fit-content;
}

.back-button:hover {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
  transform: translateX(-5px);
}

.back-button i {
  font-size: 16px;
}

.column-info h2 {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.column-info p {
  color: #666;
  font-size: 16px;
  margin-bottom: 15px;
  line-height: 1.6;
}

.column-info .column-stats {
  display: flex;
  gap: 20px;
}

.column-info .stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #999;
  font-size: 14px;
}

.column-info .stat-item i {
  font-size: 16px;
}

/* 专栏文章卡片样式 */
.column-posts-section {
  margin-top: 20px;
}

.posts-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 20px 10px 20px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 20px;
}

.posts-card-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #333;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.posts-count {
  font-size: 14px;
  color: #666;
  background: rgba(102, 126, 234, 0.1);
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 500;
}

.column-posts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  padding: 0 20px 20px 20px;
}

.post-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.post-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.card-cover {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.post-card:hover .cover-image {
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
}

.card-overlay {
  position: absolute;
  top: 12px;
  right: 12px;
}

.card-overlay .content-type-badge {
  background: rgba(255, 255, 255, 0.9);
  color: #333;
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 12px;
  font-weight: 500;
  backdrop-filter: blur(10px);
}

.card-content {
  padding: 20px;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 12px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-summary {
  color: #666;
  font-size: 14px;
  line-height: 1.6;
  margin: 0 0 16px 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.author-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.author-avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  object-fit: cover;
}

.author-name {
  font-size: 13px;
  color: #666;
  font-weight: 500;
}

.post-stats {
  display: flex;
  gap: 12px;
}

.post-stats .stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #999;
  font-size: 12px;
}

.post-stats .stat-item i {
  color: #ccc;
}

.card-footer {
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}

.post-time {
  font-size: 12px;
  color: #999;
  font-style: italic;
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

/* 响应式设计 */
@media (max-width: 768px) {
  .posts-card-header {
    padding: 16px 16px 0 16px;
    margin-bottom: 16px;
  }

  .posts-card-header h3 {
    font-size: 18px;
  }

  .column-posts-grid {
    grid-template-columns: 1fr;
    gap: 16px;
    padding: 0 16px 16px 16px;
  }

  .card-cover {
    height: 160px;
  }

  .card-content {
    padding: 16px;
  }

  .card-title {
    font-size: 16px;
  }

  .card-summary {
    font-size: 13px;
  }
}

@media (max-width: 480px) {
  .posts-card-header {
    padding: 12px 12px 0 12px;
    margin-bottom: 12px;
  }

  .posts-card-header h3 {
    font-size: 16px;
  }

  .column-posts-grid {
    padding: 0 12px 12px 12px;
  }

  .card-cover {
    height: 140px;
  }

  .card-content {
    padding: 12px;
  }
}
</style>
