<template>
  <div class="waifu-widget" v-if="show">
    <!-- 看板娘容器 -->
    <div id="waifu" ref="waifuContainer"></div>

    <!-- 位置控制按钮 -->
    <div class="waifu-controls" v-if="showControls">
      <button
        class="control-btn position-btn"
        @click="togglePosition"
        :title="position === 'left' ? '切换到右下角' : '切换到左下角'"
      >
        <i class="icon-position"></i>
      </button>
      <button class="control-btn close-btn" @click="closeWidget" title="关闭看板娘">
        <i class="icon-close">×</i>
      </button>
    </div>
  </div>
</template>

<script setup>
import { nextTick, onMounted, onUnmounted, ref, watch } from 'vue';

// Props
const props = defineProps({
  show: {
    type: Boolean,
    default: true,
  },
  position: {
    type: String,
    default: 'left', // 'left' 或 'right'
    validator: value => ['left', 'right'].includes(value),
  },
  showControls: {
    type: Boolean,
    default: true,
  },
  cdnPath: {
    type: String,
    default: 'https://fastly.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/',
  },
});

// Emits
const emit = defineEmits(['update:show', 'update:position']);

// 响应式数据
const waifuContainer = ref(null);
const currentPosition = ref(props.position);
const isInitialized = ref(false);

// 初始化 Live2D 看板娘
const initLive2D = async () => {
  if (isInitialized.value || !waifuContainer.value) return;

  try {
    // 动态加载 Live2D 脚本
    await loadScript(`${props.cdnPath}autoload.js`);

    // 等待 DOM 更新和 Live2D 看板娘完全加载
    await nextTick();

    // 延迟一段时间确保 Live2D 看板娘完全初始化
    globalThis.setTimeout(() => {
      updatePosition();
    }, 1000);

    isInitialized.value = true;
    console.log('Live2D 看板娘初始化成功');
  } catch (error) {
    console.error('Live2D 看板娘初始化失败:', error);
  }
};

// 动态加载脚本
const loadScript = src => {
  return new Promise((resolve, reject) => {
    // 检查是否已经加载
    if (document.querySelector(`script[src="${src}"]`)) {
      resolve();
      return;
    }

    const script = document.createElement('script');
    script.src = src;
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
};

// 更新位置
const updatePosition = () => {
  const waifuElement = document.getElementById('waifu');
  if (!waifuElement) {
    console.log('看板娘元素未找到，稍后重试...');
    // 如果看板娘还没加载，延迟重试
    globalThis.setTimeout(updatePosition, 500);
    return;
  }

  // 强制设置所有相关样式
  const styles = {
    position: 'fixed',
    bottom: '0px',
    top: 'auto',
    zIndex: '1000',
    transition: 'all 0.3s ease',
  };

  if (currentPosition.value === 'left') {
    styles.left = '0px';
    styles.right = 'auto';
  } else {
    styles.left = 'auto';
    styles.right = '0px';
  }

  // 应用所有样式
  Object.assign(waifuElement.style, styles);

  // 同时通过 CSS 类来确保样式生效
  waifuElement.className = waifuElement.className.replace(/waifu-(left|right)/g, '');
  waifuElement.classList.add(`waifu-${currentPosition.value}`);

  console.log('看板娘位置已更新到:', currentPosition.value, '样式:', styles);
};

// 切换位置
const togglePosition = () => {
  console.log('切换位置前:', currentPosition.value);
  currentPosition.value = currentPosition.value === 'left' ? 'right' : 'left';
  console.log('切换位置后:', currentPosition.value);

  updatePosition();
  emit('update:position', currentPosition.value);

  // 保存位置设置到本地存储
  localStorage.setItem('waifu-position', currentPosition.value);

  console.log('位置切换完成，已保存到本地存储');
};

// 关闭看板娘
const closeWidget = () => {
  emit('update:show', false);

  // 保存关闭状态到本地存储
  localStorage.setItem('waifu-show', 'false');
};

// 监听 show 属性变化
watch(
  () => props.show,
  newShow => {
    if (newShow && !isInitialized.value) {
      nextTick(() => {
        initLive2D();
      });
    }
  }
);

// 监听 position 属性变化
watch(
  () => props.position,
  newPosition => {
    currentPosition.value = newPosition;
    updatePosition();
  }
);

// 从本地存储加载设置
const loadSettings = () => {
  const savedShow = localStorage.getItem('waifu-show');
  const savedPosition = localStorage.getItem('waifu-position');

  if (savedShow === 'false') {
    emit('update:show', false);
  }

  if (savedPosition && ['left', 'right'].includes(savedPosition)) {
    currentPosition.value = savedPosition;
    emit('update:position', savedPosition);
  }
};

// 生命周期
onMounted(() => {
  loadSettings();

  if (props.show) {
    nextTick(() => {
      initLive2D();
    });
  }

  // 定期检查并更新看板娘位置
  const positionInterval = globalThis.setInterval(() => {
    const waifuElement = document.getElementById('waifu');
    if (waifuElement && isInitialized.value) {
      // 检查当前样式是否与期望位置一致
      const currentLeft = waifuElement.style.left;
      const currentRight = waifuElement.style.right;

      if (currentPosition.value === 'left' && currentLeft !== '0px') {
        updatePosition();
      } else if (currentPosition.value === 'right' && currentRight !== '0px') {
        updatePosition();
      }
    }
  }, 2000);

  // 清理定时器
  onUnmounted(() => {
    globalThis.clearInterval(positionInterval);
  });
});

onUnmounted(() => {
  // 清理工作
  const waifuElement = document.getElementById('waifu');
  if (waifuElement) {
    waifuElement.remove();
  }
});
</script>

<style scoped>
.waifu-widget {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  pointer-events: none;
  z-index: 1000;
}

.waifu-controls {
  position: fixed;
  bottom: 20px;
  right: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  pointer-events: auto;
  z-index: 1001;
}

.control-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  color: #666;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.control-btn:hover {
  background: rgba(255, 255, 255, 1);
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.position-btn .icon-position::before {
  content: '↔';
  font-size: 18px;
}

.close-btn .icon-close {
  font-size: 20px;
  font-weight: bold;
}

/* 全局样式 - 用于 Live2D 看板娘 */
:global(#waifu) {
  position: fixed !important;
  bottom: 0 !important;
  z-index: 1000 !important;
  pointer-events: auto !important;
  transition: all 0.3s ease !important;
}

/* 确保看板娘容器正确显示 */
:global(.waifu-widget #waifu) {
  position: fixed !important;
  bottom: 0 !important;
  z-index: 1000 !important;
  pointer-events: auto !important;
}

/* 位置类样式 */
:global(#waifu.waifu-left) {
  left: 0 !important;
  right: auto !important;
}

:global(#waifu.waifu-right) {
  left: auto !important;
  right: 0 !important;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .waifu-controls {
    bottom: 10px;
    right: 10px;
  }

  .control-btn {
    width: 35px;
    height: 35px;
    font-size: 14px;
  }

  .position-btn .icon-position::before {
    font-size: 16px;
  }

  .close-btn .icon-close {
    font-size: 18px;
  }
}

/* 确保看板娘在移动端也能正常显示 */
@media (max-width: 480px) {
  :global(#waifu) {
    transform: scale(0.8) !important;
    transform-origin: bottom center !important;
  }
}
</style>
