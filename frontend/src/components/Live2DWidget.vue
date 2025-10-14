<template>
  <!-- Live2D 看板娘容器 -->
  <div id="live2d-widget-container"></div>
</template>

<script setup>
import { onMounted, onUnmounted, watch, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const isScriptLoaded = ref(false)
const isWidgetVisible = ref(false)

// 检查是否应该显示看板娘
const shouldShowLive2D = () => {
  // 不在管理页面显示
  return !route.path.startsWith('/admin')
}

// 动态加载看板娘脚本
const loadLive2DWidget = () => {
  if (!shouldShowLive2D()) {
    hideWidget()
    return
  }

  // 如果脚本已经加载过，只需要显示/隐藏看板娘
  if (isScriptLoaded.value) {
    showWidget()
    return
  }

  // 检查是否已经加载过脚本
  if (document.querySelector('script[src*="live2d-widget"]')) {
    isScriptLoaded.value = true
    showWidget()
    return
  }

  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/autoload.js'
  script.async = true
  
  script.onload = () => {
    isScriptLoaded.value = true
    console.log('🎭 Live2D 看板娘脚本已加载')
    showWidget()
  }
  
  script.onerror = () => {
    console.error('🎭 Live2D 看板娘脚本加载失败')
  }
  
  document.head.appendChild(script)
}

// 显示看板娘
const showWidget = () => {
  if (!shouldShowLive2D()) return
  
  // 等待看板娘元素创建
  const checkWidget = () => {
    const waifu = document.querySelector('#waifu')
    if (waifu) {
      waifu.style.display = 'block'
      waifu.style.visibility = 'visible'
      waifu.style.opacity = '1'
      isWidgetVisible.value = true
      console.log('🎭 Live2D 看板娘已显示')
    } else {
      // 如果元素还没创建，继续等待
      setTimeout(checkWidget, 100)
    }
  }
  
  checkWidget()
}

// 隐藏看板娘
const hideWidget = () => {
  const waifu = document.querySelector('#waifu')
  if (waifu) {
    waifu.style.display = 'none'
    waifu.style.visibility = 'hidden'
    waifu.style.opacity = '0'
    isWidgetVisible.value = false
    console.log('🎭 Live2D 看板娘已隐藏')
  }
}

// 完全移除看板娘（仅在组件卸载时使用）
const removeLive2DWidget = () => {
  // 移除看板娘相关元素
  const live2dElements = document.querySelectorAll('#waifu, #waifu-tips, .waifu-tool')
  live2dElements.forEach(el => el.remove())

  // 移除相关样式
  const live2dStyles = document.querySelectorAll('style[data-live2d]')
  live2dStyles.forEach(style => style.remove())

  // 移除脚本
  const existingScript = document.querySelector('script[src*="live2d-widget"]')
  if (existingScript) {
    existingScript.remove()
  }

  isScriptLoaded.value = false
  isWidgetVisible.value = false
  console.log('🎭 Live2D 看板娘已完全移除')
}

onMounted(() => {
  // 延迟加载，确保页面渲染完成
  setTimeout(() => {
    loadLive2DWidget()
  }, 1000)
})

onUnmounted(() => {
  // 组件卸载时完全移除看板娘
  removeLive2DWidget()
})

// 监听路由变化
watch(
  () => route.path,
  (newPath, oldPath) => {
    if (newPath !== oldPath) {
      // 路由变化时重新处理看板娘
      setTimeout(() => {
        loadLive2DWidget()
      }, 300)
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
  /* 移除 pointer-events: none，让看板娘可以被拖拽 */
}
</style>
