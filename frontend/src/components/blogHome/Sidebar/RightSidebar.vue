<template>
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
          @click="$emit('viewColumnDetail', column)"
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
      <div v-if="tagCloudLoading" class="tag-loading">
        <div class="loading-spinner"></div>
        <span>加载中...</span>
      </div>
      <div v-else class="tags">
        <span
          v-for="tag in tagCloudList"
          :key="tag.name"
          class="tag"
          :class="tag.size"
          :style="`background-color: ${tag.color} !important; color: ${getTextColor(tag.color)} !important;`"
        >
          {{ tag.name }}
        </span>
      </div>
    </div>

    <!-- 分类 -->
    <div v-show="false" class="categories">
      <h3>📂 分类</h3>
      <div class="category-list">
        <div class="category-item">默认分类</div>
      </div>
    </div>
  </aside>
</template>

<script setup>
defineProps({
  sidebarColumnsList: {
    type: Array,
    default: () => [],
  },
  sidebarColumnsLoading: {
    type: Boolean,
    default: false,
  },
  tagCloudList: {
    type: Array,
    default: () => [],
  },
  tagCloudLoading: {
    type: Boolean,
    default: false,
  },
});

defineEmits(['viewColumnDetail']);

// 获取完整图片URL
const getFullImageUrl = url => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return `http://localhost:8000${url}`;
};

// 根据背景色计算合适的文字颜色
const getTextColor = backgroundColor => {
  if (!backgroundColor) return '#ffffff';

  // 移除 # 号
  const hex = backgroundColor.replace('#', '');

  // 转换为RGB
  const r = parseInt(hex.substr(0, 2), 16);
  const g = parseInt(hex.substr(2, 2), 16);
  const b = parseInt(hex.substr(4, 2), 16);

  // 计算亮度
  const brightness = (r * 299 + g * 587 + b * 114) / 1000;

  // 根据亮度返回白色或黑色文字
  return brightness > 128 ? '#000000' : '#ffffff';
};
</script>

<style scoped>
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

/* 标签云加载状态 */
.tag-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
}

.tag-loading .loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 8px;
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

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
