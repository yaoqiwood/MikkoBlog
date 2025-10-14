<template>
  <!-- Live2D 看板娘容器 -->
  <div id="live2d-widget-container"></div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// 检查是否应该显示看板娘
const shouldShowLive2D = () => {
  // 不在管理页面显示
  return !route.path.startsWith('/admin')
}

// 动态加载看板娘脚本
const loadLive2DWidget = () => {
  if (!shouldShowLive2D()) return

  // 检查是否已经加载过
  if (document.querySelector('script[src*="live2d-widget"]')) return

  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/autoload.js'
  script.async = true
  document.head.appendChild(script)

  console.log('🎭 Live2D 看板娘已加载')
}

// 移除看板娘
const removeLive2DWidget = () => {
  // 移除脚本
  const existingScript = document.querySelector('script[src*="live2d-widget"]')
  if (existingScript) {
    existingScript.remove()
  }

  // 移除看板娘相关元素
  const live2dElements = document.querySelectorAll('#waifu, #waifu-tips, .waifu-tool')
  live2dElements.forEach(el => el.remove())

  // 移除相关样式
  const live2dStyles = document.querySelectorAll('style[data-live2d]')
  live2dStyles.forEach(style => style.remove())

  console.log('🎭 Live2D 看板娘已移除')
}

onMounted(() => {
  // 延迟加载，确保页面渲染完成
  setTimeout(() => {
    if (shouldShowLive2D()) {
      loadLive2DWidget()
    }
  }, 1000)
})

onUnmounted(() => {
  removeLive2DWidget()
})

// 监听路由变化
import { watch } from 'vue'
watch(
  () => route.path,
  (newPath, oldPath) => {
    if (newPath !== oldPath) {
      // 路由变化时重新处理看板娘
      setTimeout(() => {
        if (shouldShowLive2D()) {
          loadLive2DWidget()
        } else {
          removeLive2DWidget()
        }
      }, 500)
    }
  }
)
</script>

<style scoped>
#live2d-widget-container {
  position: fixed;
  bottom: 0;
  right: 0;
  z-index: 1000;
  pointer-events: none;
}
</style>
