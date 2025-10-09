<template>
  <Modal
    :model-value="show"
    @update:model-value="$emit('update:show', $event)"
    width="90%"
    class-name="image-preview-modal"
    :mask-closable="true"
    :closable="true"
  >
    <template #header>
      <div class="preview-header">
        <span
          >图片预览 ({{ previewIndex + 1 }} / {{ previewImages.length }}) -
          {{ Math.round(imageScale * 100) }}%</span
        >
        <div class="preview-actions">
          <Button type="text" @click="zoomOut" size="small" title="缩小 (-)">
            <Icon type="ios-remove" />
          </Button>
          <Button type="text" @click="resetZoom" size="small" title="重置 (0)">
            {{ Math.round(imageScale * 100) }}%
          </Button>
          <Button type="text" @click="zoomIn" size="small" title="放大 (+)">
            <Icon type="ios-add" />
          </Button>
          <Button type="text" @click="prevImage" :disabled="previewIndex === 0" size="small">
            <Icon type="ios-arrow-back" />
            上一张
          </Button>
          <Button
            type="text"
            @click="nextImage"
            :disabled="previewIndex === previewImages.length - 1"
            size="small"
          >
            下一张
            <Icon type="ios-arrow-forward" />
          </Button>
        </div>
      </div>
    </template>
    <div
      class="image-preview-container"
      @wheel="handleWheel"
      @mousemove="onDrag"
      @mouseup="endDrag"
      @mouseleave="endDrag"
    >
      <!-- 左侧箭头 -->
      <div v-if="previewIndex > 0" class="nav-arrow nav-arrow-left" @click="prevImage">
        <Icon type="ios-arrow-back" size="32" />
      </div>

      <!-- 右侧箭头 -->
      <div
        v-if="previewIndex < previewImages.length - 1"
        class="nav-arrow nav-arrow-right"
        @click="nextImage"
      >
        <Icon type="ios-arrow-forward" size="32" />
      </div>

      <img
        :src="previewImageUrl"
        alt="预览图片"
        :style="imageStyle"
        @mousedown="startDrag"
        @click="imageScale > 1 ? null : closeImagePreview()"
        @dragstart.prevent
      />
      <div class="preview-tip">
        {{ imageScale > 1 ? '拖拽移动图片 | 滚轮缩放' : '点击图片关闭预览' }} | 使用 ← → 键切换图片
        | +/- 键缩放 | 0 键重置 | ESC 键关闭
      </div>
    </div>
    <template #footer>
      <div class="preview-footer">
        <Button @click="closeImagePreview">关闭</Button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { Button, Icon, Modal } from 'view-ui-plus';
import { computed, onUnmounted, ref, watch } from 'vue';

const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  previewImages: {
    type: Array,
    default: () => [],
  },
  previewIndex: {
    type: Number,
    default: 0,
  },
  previewImageUrl: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['update:show', 'close', 'prevImage', 'nextImage']);

const imageScale = ref(1);
const imagePosition = ref({ x: 0, y: 0 });
const isDragging = ref(false);
const dragStart = ref({ x: 0, y: 0 });

// 计算图片样式
const imageStyle = computed(() => ({
  transform: `scale(${imageScale.value}) translate(${imagePosition.value.x / imageScale.value}px, ${imagePosition.value.y / imageScale.value}px)`,
  cursor: imageScale.value > 1 ? (isDragging.value ? 'grabbing' : 'grab') : 'pointer',
  transition: isDragging.value ? 'none' : 'transform 0.2s ease',
}));

// 关闭图片预览
const closeImagePreview = () => {
  emit('update:show', false);
  emit('close');
  // 重置缩放和位置
  imageScale.value = 1;
  imagePosition.value = { x: 0, y: 0 };
};

// 上一张图片
const prevImage = () => {
  if (props.previewIndex > 0) {
    emit('prevImage');
    // 重置缩放和位置
    imageScale.value = 1;
    imagePosition.value = { x: 0, y: 0 };
  }
};

// 下一张图片
const nextImage = () => {
  if (props.previewIndex < props.previewImages.length - 1) {
    emit('nextImage');
    // 重置缩放和位置
    imageScale.value = 1;
    imagePosition.value = { x: 0, y: 0 };
  }
};

// 图片缩放功能
const zoomIn = () => {
  if (imageScale.value < 3) {
    imageScale.value = Math.min(imageScale.value + 0.2, 3);
  }
};

const zoomOut = () => {
  if (imageScale.value > 0.5) {
    imageScale.value = Math.max(imageScale.value - 0.2, 0.5);
    // 如果缩放到1，重置位置
    if (imageScale.value === 1) {
      imagePosition.value = { x: 0, y: 0 };
    }
  }
};

const resetZoom = () => {
  imageScale.value = 1;
  imagePosition.value = { x: 0, y: 0 };
};

// 鼠标滚轮缩放
const handleWheel = event => {
  event.preventDefault();
  if (event.deltaY < 0) {
    zoomIn();
  } else {
    zoomOut();
  }
};

// 拖拽功能
const startDrag = event => {
  if (imageScale.value > 1) {
    isDragging.value = true;
    dragStart.value = {
      x: event.clientX - imagePosition.value.x,
      y: event.clientY - imagePosition.value.y,
    };
    event.preventDefault();
  }
};

const onDrag = event => {
  if (isDragging.value && imageScale.value > 1) {
    imagePosition.value = {
      x: event.clientX - dragStart.value.x,
      y: event.clientY - dragStart.value.y,
    };
  }
};

const endDrag = () => {
  isDragging.value = false;
};

// 键盘导航
const handleKeydown = event => {
  if (!props.show) return;

  switch (event.key) {
    case 'ArrowLeft':
      event.preventDefault();
      prevImage();
      break;
    case 'ArrowRight':
      event.preventDefault();
      nextImage();
      break;
    case 'Escape':
      event.preventDefault();
      closeImagePreview();
      break;
    case '=':
    case '+':
      event.preventDefault();
      zoomIn();
      break;
    case '-':
      event.preventDefault();
      zoomOut();
      break;
    case '0':
      event.preventDefault();
      resetZoom();
      break;
  }
};

// 监听显示状态变化
watch(
  () => props.show,
  newShow => {
    if (newShow) {
      document.addEventListener('keydown', handleKeydown);
    } else {
      document.removeEventListener('keydown', handleKeydown);
    }
  }
);

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown);
});
</script>

<style scoped>
/* 图片预览样式 */
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.preview-actions {
  display: flex;
  gap: 8px;
  margin-right: 20px;
}

.image-preview-container {
  text-align: center;
  position: relative;
  background: #f5f5f5;
  border-radius: 8px;
  padding: 16px;
  min-height: 300px;
  max-height: 60vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  user-select: none;
}

.image-preview-container img {
  max-width: 100%;
  max-height: 50vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform-origin: center center;
}

/* 导航箭头 */
.nav-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 60px;
  height: 60px;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  transition: all 0.3s ease;
  z-index: 20;
  opacity: 0.7;
}

.nav-arrow:hover {
  background: rgba(0, 0, 0, 0.7);
  opacity: 1;
  transform: translateY(-50%) scale(1.1);
}

.nav-arrow-left {
  left: 20px;
}

.nav-arrow-right {
  right: 20px;
}

.preview-tip {
  margin-top: 8px;
  color: #999;
  font-size: 12px;
  line-height: 1.4;
}

.preview-footer {
  text-align: center;
}

:deep(.image-preview-modal .ivu-modal-body) {
  padding: 16px;
}

:deep(.image-preview-modal .ivu-modal-header) {
  border-bottom: 1px solid #e8eaec;
}

:deep(.image-preview-modal .ivu-modal-footer) {
  border-top: 1px solid #e8eaec;
  text-align: center;
}
</style>
