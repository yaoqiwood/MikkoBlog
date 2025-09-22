<template>
  <div class="markdown-editor">
    <div class="editor-toolbar">
      <div class="toolbar-left">
        <Button size="small" @click="togglePreview">
          {{ showPreview ? '编辑模式' : '预览模式' }}
        </Button>
        <Button size="small" @click="toggleSplit">
          {{ splitMode ? '关闭分屏' : '分屏模式' }}
        </Button>
      </div>
      <div class="toolbar-right">
        <span class="word-count">字数: {{ wordCount }}</span>
      </div>
    </div>

    <div class="editor-container">
      <div ref="editorElement" class="editor-content"></div>
    </div>
  </div>
</template>

<script setup>
import Editor from '@toast-ui/editor';
import '@toast-ui/editor/dist/toastui-editor-viewer.css';
import '@toast-ui/editor/dist/toastui-editor.css';
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';

/* global FormData */

const props = defineProps({
  modelValue: {
    type: String,
    default: '',
  },
  height: {
    type: String,
    default: '400px',
  },
  placeholder: {
    type: String,
    default: '请输入 Markdown 内容...',
  },
});

const emit = defineEmits(['update:modelValue', 'upload-image']);

const editorElement = ref(null);
const editor = ref(null);
const showPreview = ref(false);
const splitMode = ref(true);

const wordCount = computed(() => {
  return editor.value ? editor.value.getMarkdown().length : 0;
});

onMounted(() => {
  initEditor();
});

onUnmounted(() => {
  if (editor.value) {
    editor.value.destroy();
  }
});

function initEditor() {
  if (!editorElement.value) return;

  editor.value = new Editor({
    el: editorElement.value,
    height: props.height,
    initialValue: props.modelValue,
    placeholder: props.placeholder,
    previewStyle: splitMode.value ? 'vertical' : 'tab',
    initialEditType: 'markdown',
    usageStatistics: false,
    toolbarItems: [
      ['heading', 'bold', 'italic', 'strike'],
      ['hr', 'quote'],
      ['ul', 'ol', 'task', 'indent', 'outdent'],
      ['table', 'image', 'link'],
      ['code', 'codeblock'],
      ['scrollSync'],
    ],
    events: {
      change: () => {
        const markdown = editor.value.getMarkdown();
        emit('update:modelValue', markdown);
      },
    },
    hooks: {
      addImageBlobHook: (blob, callback) => {
        // 处理图片上传
        handleImageUpload(blob, callback);
      },
    },
  });
}

function togglePreview() {
  showPreview.value = !showPreview.value;
  if (editor.value) {
    editor.value.changePreviewStyle(showPreview.value ? 'tab' : 'vertical');
  }
}

function toggleSplit() {
  splitMode.value = !splitMode.value;
  if (editor.value) {
    editor.value.changePreviewStyle(splitMode.value ? 'vertical' : 'tab');
  }
}

async function handleImageUpload(blob, callback) {
  try {
    // 创建 FormData
    const formData = new FormData();
    formData.append('file', blob, `image_${Date.now()}.${blob.type.split('/')[1]}`);

    // 调用父组件的上传方法
    emit('upload-image', formData, callback);
  } catch (error) {
    console.error('图片上传失败:', error);
    callback('上传失败');
  }
}

// 监听外部值变化
watch(
  () => props.modelValue,
  newValue => {
    if (editor.value && editor.value.getMarkdown() !== newValue) {
      editor.value.setMarkdown(newValue);
    }
  }
);
</script>

<style scoped>
.markdown-editor {
  border: 1px solid #d9d9d9;
  border-radius: 6px;
  overflow: hidden;
}

.editor-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #f8f9fa;
  border-bottom: 1px solid #d9d9d9;
}

.toolbar-left {
  display: flex;
  gap: 8px;
}

.toolbar-right {
  font-size: 12px;
  color: #666;
}

.editor-container {
  height: 400px;
}

.editor-content {
  height: 100%;
}
</style>
