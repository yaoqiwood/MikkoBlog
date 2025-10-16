<template>
  <div class="columns-content">
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
        @click="$emit('viewColumnDetail', column)"
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
</template>

<script setup>
import { getFullUrl } from '@/utils/urlUtils';
import { Icon } from 'view-ui-plus';

defineProps({
  columnsList: {
    type: Array,
    default: () => [],
  },
  columnsLoading: {
    type: Boolean,
    default: false,
  },
});

defineEmits(['viewColumnDetail']);

// 获取完整图片URL
const getFullImageUrl = url => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return getFullUrl(url);
};
</script>

<style scoped>
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
</style>
