<template>
  <!-- Live2D 看板娘容器 -->
  <div v-if="shouldShowLive2D" id="live2d-widget-container"></div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, watch } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

// 检查是否应该显示看板娘
const shouldShowLive2D = computed(() => {
  // 不在管理页面显示
  return !route.path.startsWith('/admin');
});

// 动态加载看板娘脚本
const loadLive2DWidget = () => {
  // 检查是否已经加载过脚本
  if (document.querySelector('script[src*="live2d-widget"]')) {
    // 脚本已加载，只需要控制显示/隐藏
    if (shouldShowLive2D.value) {
      showWidget();
    } else {
      hideWidget();
    }
    return;
  }

  const script = document.createElement('script');
  script.src = 'https://fastly.jsdelivr.net/npm/live2d-widgets@1.0.0-rc.7/dist/autoload.js';
  script.async = true;

  script.onload = () => {
    console.log('🎭 Live2D 看板娘脚本已加载');
    // 等待 initWidget 函数可用
    window.setTimeout(() => {
      if (window.initWidget) {
        // 初始化看板娘，启用拖拽功能
        window.initWidget({
          waifuPath: 'https://fastly.jsdelivr.net/npm/live2d-widgets@1/dist/waifu-tips.json',
          cdnPath: 'https://fastly.jsdelivr.net/gh/fghrsh/live2d_api/',
          drag: true, // 启用拖拽功能
          logLevel: 'info',
        });
        console.log('🎭 Live2D 看板娘已初始化，拖拽功能已启用');
      } else {
        console.error('🎭 initWidget 函数不可用');
      }
    }, 1000);
  };

  script.onerror = () => {
    console.error('🎭 Live2D 看板娘脚本加载失败');
  };

  document.head.appendChild(script);
};

// 显示看板娘
const showWidget = () => {
  if (!shouldShowLive2D.value) return;

  // 等待看板娘元素创建
  const checkWidget = () => {
    const waifu = document.querySelector('#waifu');
    if (waifu) {
      waifu.style.display = 'block';
      waifu.style.visibility = 'visible';
      waifu.style.opacity = '1';
      console.log('🎭 Live2D 看板娘已显示');
    } else {
      // 如果元素还没创建，继续等待
      window.setTimeout(checkWidget, 100);
    }
  };

  checkWidget();
};

// 隐藏看板娘
const hideWidget = () => {
  const waifu = document.querySelector('#waifu');
  if (waifu) {
    waifu.style.display = 'none';
    waifu.style.visibility = 'hidden';
    waifu.style.opacity = '0';
    console.log('🎭 Live2D 看板娘已隐藏');
  }
};

// 完全移除看板娘（仅在组件卸载时使用）
const removeLive2DWidget = () => {
  // 移除看板娘相关元素
  const live2dElements = document.querySelectorAll('#waifu, #waifu-tips, .waifu-tool');
  live2dElements.forEach(el => el.remove());

  // 移除相关样式
  const live2dStyles = document.querySelectorAll('style[data-live2d]');
  live2dStyles.forEach(style => style.remove());

  // 移除脚本
  const existingScript = document.querySelector('script[src*="live2d-widget"]');
  if (existingScript) {
    existingScript.remove();
  }

  console.log('🎭 Live2D 看板娘已完全移除');
};

onMounted(() => {
  // 延迟加载，确保页面渲染完成
  window.setTimeout(() => {
    loadLive2DWidget();
  }, 1000);
});

onUnmounted(() => {
  // 组件卸载时完全移除看板娘
  removeLive2DWidget();
});

// 监听路由变化
watch(
  () => route.path,
  (newPath, oldPath) => {
    if (newPath !== oldPath) {
      console.log(`🎭 路由变化: ${oldPath} -> ${newPath}`);
      // 路由变化时立即处理看板娘显示/隐藏
      window.setTimeout(() => {
        if (shouldShowLive2D.value) {
          showWidget();
        } else {
          hideWidget();
        }
      }, 100);
    }
  }
);
</script>

<style scoped>
#live2d-widget-container {
  position: fixed;
  bottom: 0;
  right: 0;
  z-index: 1000;
  /* 移除 pointer-events: none，让看板娘可以被拖拽 */
}
</style>

<style>
/* 确保看板娘在管理页面隐藏 */
.admin-page #waifu {
  display: none !important;
  visibility: hidden !important;
  opacity: 0 !important;
}
</style>
