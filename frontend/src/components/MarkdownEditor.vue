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
import { onMounted, onUnmounted, ref, watch } from 'vue';

/* global FormData, requestAnimationFrame */

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
let editor = null; // 非响应式编辑器实例
const showPreview = ref(false);
const splitMode = ref(true);
const isUpdating = ref(false);
const wordCount = ref(0); // 改为响应式变量

// 更新字数统计
function updateWordCount() {
  if (editor) {
    try {
      const markdown = editor.getMarkdown();
      // 计算字数：去除Markdown语法，只计算实际文本内容
      const textContent = markdown
        .replace(/```[\s\S]*?```/g, '') // 移除代码块
        .replace(/`[^`]*`/g, '') // 移除行内代码
        .replace(/!\[.*?\]\(.*?\)/g, '') // 移除图片
        .replace(/\[.*?\]\(.*?\)/g, '') // 移除链接
        .replace(/[#*\-+>|`~]/g, '') // 移除Markdown语法字符
        .replace(/\s+/g, ' ') // 合并多个空格
        .trim();

      wordCount.value = textContent.length;
    } catch (error) {
      console.warn('更新字数统计时出错:', error);
      wordCount.value = 0;
    }
  }
}

onMounted(() => {
  initEditor();
});

onUnmounted(() => {
  try {
    if (editor) {
      editor.destroy();
      editor = null;
    }
  } catch (error) {
    console.warn('销毁编辑器时出错:', error);
  }
});

function initEditor() {
  if (!editorElement.value) return;

  try {
    editor = new Editor({
      el: editorElement.value,
      height: props.height,
      initialValue: props.modelValue || '',
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
          try {
            if (editor && !isUpdating.value) {
              const markdown = editor.getMarkdown();
              emit('update:modelValue', markdown);
              updateWordCount(); // 更新字数统计
            }
          } catch (error) {
            console.warn('获取 Markdown 内容时出错:', error);
          }
        },
      },
      hooks: {
        addImageBlobHook: (blob, callback) => {
          // 处理图片上传
          handleImageUpload(blob, callback);
        },
      },
    });

    // 初始化字数统计
    updateWordCount();
  } catch (error) {
    console.error('初始化编辑器失败:', error);
  }
}

function togglePreview() {
  showPreview.value = !showPreview.value;
  if (editor) {
    editor.changePreviewStyle(showPreview.value ? 'tab' : 'vertical');
  }
}

function toggleSplit() {
  splitMode.value = !splitMode.value;
  if (editor) {
    editor.changePreviewStyle(splitMode.value ? 'vertical' : 'tab');
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
    if (editor && !isUpdating.value) {
      try {
        const currentMarkdown = editor.getMarkdown();
        if (currentMarkdown !== newValue) {
          isUpdating.value = true;
          // 使用 requestAnimationFrame 确保在下一个渲染周期更新
          requestAnimationFrame(() => {
            try {
              if (editor) {
                const currentMarkdown = editor.getMarkdown();
                if (currentMarkdown !== newValue) {
                  editor.setMarkdown(newValue || '');
                  updateWordCount(); // 更新字数统计
                }
              }
            } catch (error) {
              console.warn('设置 Markdown 内容时出错:', error);
            } finally {
              isUpdating.value = false;
            }
          });
        }
      } catch (error) {
        console.warn('获取当前 Markdown 内容时出错:', error);
        isUpdating.value = false;
      }
    }
  },
  { flush: 'post' }
);
</script>

<style scoped>
.markdown-editor {
  border: 1px solid #d9d9d9;
  border-radius: 6px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.editor-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #f8f9fa;
  border-bottom: 1px solid #d9d9d9;
  flex-shrink: 0;
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
  flex: 1;
  overflow: hidden;
  min-height: 0;
}

.editor-content {
  height: 100%;
}
</style>
