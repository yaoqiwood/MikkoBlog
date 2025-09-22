<template>
  <div>
    <div v-if="globalLoading" class="global-loading-overlay">
      <div class="global-loading-content">
        <div class="loading-spinner">
          <div class="spinner"></div>
        </div>
        <div class="loading-text">
          <p>正在加载数据...</p>
          <p class="loading-count" v-if="showCount">请求数量: {{ loadingCount }}</p>
        </div>
        <div class="loading-progress">
          <div class="progress-bar"></div>
        </div>
      </div>
    </div>

    <!-- 调试信息 -->
    <div v-if="globalLoading" class="debug-info">
      <p>Debug: globalLoading={{ globalLoading }}, loadingCount={{ loadingCount }}</p>
    </div>
  </div>
</template>

<script setup>
import { globalLoading, loadingCount } from '@/utils/loadingManager';
import { ref } from 'vue';

// 是否显示请求计数（可选）
const showCount = ref(false);
</script>

<style scoped>
.global-loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(2px);
}

.global-loading-content {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  text-align: center;
  min-width: 200px;
}

.loading-spinner {
  margin-bottom: 1rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.loading-text p {
  margin: 0.5rem 0;
  color: #333;
  font-size: 16px;
}

.loading-count {
  font-size: 12px !important;
  color: #666 !important;
}

.loading-progress {
  width: 100%;
  height: 3px;
  background-color: #f0f0f0;
  border-radius: 2px;
  margin-top: 1rem;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 2px;
  animation: progress 2s ease-in-out infinite;
}

@keyframes progress {
  0% {
    width: 0%;
    transform: translateX(-100%);
  }
  50% {
    width: 100%;
    transform: translateX(0%);
  }
  100% {
    width: 0%;
    transform: translateX(100%);
  }
}

.debug-info {
  position: fixed;
  top: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 10px;
  border-radius: 5px;
  z-index: 10000;
  font-size: 12px;
}

.debug-info p {
  margin: 0;
}
@media (max-width: 768px) {
  .global-loading-content {
    margin: 1rem;
    padding: 1.5rem;
  }

  .spinner {
    width: 32px;
    height: 32px;
  }

  .loading-text p {
    font-size: 14px;
  }
}
</style>
