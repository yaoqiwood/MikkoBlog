<template>
  <!-- Live2D 看板娘容器 -->
  <div v-if="shouldShowLive2D" id="live2d-widget-container">
    <!-- 看板娘会在这里自动创建 -->
  </div>
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
  script.src = 'https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/autoload.js';
  script.async = true;

  script.onload = () => {
    console.log('🎭 Live2D 看板娘脚本已加载');
    // 等待看板娘自动初始化完成
    window.setTimeout(() => {
      // 检查看板娘是否已经创建
      const waifu = document.querySelector('#waifu');
      if (waifu) {
        console.log('🎭 Live2D 看板娘已自动加载');
        // 设置看板娘位置为绝对定位，使用百分比控制
        waifu.style.position = 'absolute';
        waifu.style.left = '85%'; // 默认位置
        waifu.style.bottom = '0px';
        waifu.style.zIndex = '1000';

        // 启用拖拽功能
        if (window.initWidget) {
          try {
            window.initWidget({
              drag: true,
              logLevel: 'error',
            });
            console.log('🎭 拖拽功能已启用');
          } catch (error) {
            console.error('🎭 拖拽功能启用失败:', error);
          }
        }
      } else {
        console.log('🎭 看板娘未自动加载，尝试手动初始化');
        // 如果自动加载失败，尝试手动初始化
        if (window.initWidget) {
          try {
            window.initWidget({
              drag: true,
              logLevel: 'error',
            });
            console.log('🎭 Live2D 看板娘已手动初始化');
          } catch (error) {
            console.error('🎭 看板娘手动初始化失败:', error);
          }
        }
      }
    }, 3000); // 增加等待时间
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
      // 确保位置设置正确
      waifu.style.position = 'absolute';
      waifu.style.left = '85%';
      waifu.style.bottom = '0px';
      waifu.style.zIndex = '1000';
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
          // 确保看板娘在路由切换后能正确显示
          const waifu = document.querySelector('#waifu');
          if (waifu) {
            showWidget();
          } else {
            // 如果看板娘不存在，重新加载
            console.log('🎭 看板娘不存在，重新加载');
            loadLive2DWidget();
          }
        } else {
          hideWidget();
        }
      }, 200);
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
/* 看板娘全局样式 */
#waifu {
  position: absolute !important;
  left: 85% !important;
  bottom: 0px !important;
  z-index: 1000 !important;
  pointer-events: auto !important;
}

/* 确保看板娘在管理页面隐藏 */
.admin-page #waifu {
  display: none !important;
  visibility: hidden !important;
  opacity: 0 !important;
}
</style>
