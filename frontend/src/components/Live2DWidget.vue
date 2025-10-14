<template>
  <!-- Live2D 看板娘控制器 -->
  <div class="live2d-controller"></div>
</template>

<script setup>
import { onMounted, onUnmounted, watch } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

// 检查是否应该显示看板娘
const shouldShowLive2D = () => {
  // 不在管理页面显示
  return !route.path.startsWith('/admin');
};

// 控制看板娘显示/隐藏
const toggleLive2D = () => {
  const waifu = document.querySelector('#waifu');
  if (waifu) {
    if (shouldShowLive2D()) {
      // 显示看板娘
      waifu.style.display = 'block';
      waifu.style.visibility = 'visible';
      waifu.style.opacity = '1';
      waifu.style.pointerEvents = 'auto';
      console.log('🎭 Live2D 看板娘已显示');
    } else {
      // 隐藏看板娘
      waifu.style.display = 'none';
      waifu.style.visibility = 'hidden';
      waifu.style.opacity = '0';
      waifu.style.pointerEvents = 'none';
      console.log('🎭 Live2D 看板娘已隐藏');
    }
  }
};

// 等待看板娘元素创建并控制显示
const waitAndControlLive2D = () => {
  const checkInterval = setInterval(() => {
    const waifu = document.querySelector('#waifu');
    if (waifu) {
      clearInterval(checkInterval);
      toggleLive2D();
    }
  }, 100);

  // 最多等待10秒
  setTimeout(() => {
    clearInterval(checkInterval);
  }, 10000);
};

onMounted(() => {
  // 延迟控制，确保看板娘脚本已加载
  setTimeout(() => {
    waitAndControlLive2D();
  }, 2000);
});

// 监听路由变化
watch(
  () => route.path,
  () => {
    // 路由变化时重新控制看板娘显示
    setTimeout(() => {
      toggleLive2D();
    }, 100);
  }
);
</script>

<style scoped>
.live2d-controller {
  display: none;
}

/* 全局样式：确保看板娘在管理页面隐藏 */
:global(.admin-page) #waifu {
  display: none !important;
  visibility: hidden !important;
  opacity: 0 !important;
  pointer-events: none !important;
}
</style>
