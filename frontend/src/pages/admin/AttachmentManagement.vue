<template>
  <div class="attachment-management">
    <div class="page-header">
      <h2>附件管理</h2>
      <p>管理系统中的图片、文档等附件文件</p>
    </div>

    <div class="management-container">
      <!-- 筛选和操作区域 -->
      <div class="filter-section">
        <div class="filter-controls">
          <Select
            v-model="filters.file_category"
            placeholder="文件分类"
            clearable
            style="width: 150px; margin-right: 10px"
            @on-change="loadAttachments"
          >
            <Option value="">全部分类</Option>
            <Option value="image">图片</Option>
            <Option value="document">文档</Option>
            <Option value="video">视频</Option>
            <Option value="audio">音频</Option>
            <Option value="other">其他</Option>
          </Select>

          <Select
            v-model="filters.status"
            placeholder="文件状态"
            clearable
            style="width: 120px; margin-right: 10px"
            @on-change="loadAttachments"
          >
            <Option value="">全部状态</Option>
            <Option value="active">正常</Option>
            <Option value="hidden">隐藏</Option>
            <Option value="deleted">已删除</Option>
          </Select>

          <Input
            v-model="filters.search"
            placeholder="搜索文件名、标题..."
            style="width: 200px; margin-right: 10px"
            @on-enter="loadAttachments"
          />

          <Button type="primary" @click="loadAttachments">搜索</Button>
          <Button @click="resetFilters" style="margin-left: 10px">重置</Button>
          <Button type="success" @click="showUploadModal = true" style="margin-left: 10px">
            上传文件
          </Button>
        </div>
      </div>

      <!-- 统计信息 -->
      <div class="stats-section" v-if="stats">
        <div class="stat-card">
          <div class="stat-number">{{ stats.total_count || 0 }}</div>
          <div class="stat-label">总文件数</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">{{ formatFileSize(stats.total_size || 0) }}</div>
          <div class="stat-label">总大小</div>
        </div>
        <div class="stat-card" v-for="(count, category) in stats.category_stats" :key="category">
          <div class="stat-number">{{ count }}</div>
          <div class="stat-label">{{ getCategoryLabel(category) }}</div>
        </div>
      </div>

      <!-- 附件列表 -->
      <div class="table-section">
        <Table :columns="columns" :data="attachments" :loading="loading" stripe border height="600">
          <template #file_preview="{ row }">
            <div class="file-preview">
              <img
                v-if="row.file_category === 'image'"
                :src="row.file_url"
                :alt="row.alt_text"
                class="preview-image"
                @click="previewImage(row)"
              />
              <div v-else class="file-icon">
                <Icon :type="getFileIcon(row.file_category)" size="24" />
              </div>
            </div>
          </template>

          <template #file_info="{ row }">
            <div class="file-info">
              <div class="file-name" :title="row.original_name">{{ row.original_name }}</div>
              <div class="file-meta">
                {{ formatFileSize(row.file_size) }} • {{ row.file_type }}
                <span v-if="row.width && row.height"> • {{ row.width }}×{{ row.height }}</span>
              </div>
            </div>
          </template>

          <template #file_url="{ row }">
            <div class="file-url" style="display: flex; align-items: center; gap: 8px">
              <Input
                :model-value="getFullUrl(row.file_url)"
                readonly
                size="small"
                placeholder="URL不可用"
                style="flex: 1; min-width: 0; background-color: #f5f5f5"
              />
              <Button
                type="text"
                size="small"
                @click="copyUrl(getFullUrl(row.file_url))"
                style="flex-shrink: 0"
              >
                复制
              </Button>
            </div>
          </template>

          <template #status="{ row }">
            <Tag :color="getStatusColor(row.status)">
              {{ getStatusLabel(row.status) }}
            </Tag>
          </template>

          <template #action="{ row }">
            <div class="action-buttons">
              <Button type="primary" size="small" @click="editAttachment(row)"> 编辑 </Button>
              <Button
                v-if="row.status === 'deleted'"
                type="success"
                size="small"
                @click="restoreAttachment(row)"
                style="margin-left: 5px"
              >
                恢复
              </Button>
              <Button
                v-else
                type="error"
                size="small"
                @click="deleteAttachment(row)"
                style="margin-left: 5px"
              >
                删除
              </Button>
            </div>
          </template>
        </Table>
      </div>

      <!-- 分页 -->
      <div class="pagination-section">
        <Page
          :total="total"
          :current="currentPage"
          :page-size="pageSize"
          show-total
          show-sizer
          show-elevator
          @on-change="handlePageChange"
          @on-page-size-change="handlePageSizeChange"
        />
      </div>
    </div>

    <!-- 上传模态框 -->
    <Modal v-model="showUploadModal" title="上传文件" width="600" @on-cancel="resetUploadForm">
      <Form :model="uploadForm" :rules="uploadRules" ref="uploadFormRef" :label-width="100">
        <FormItem label="选择文件" prop="file">
          <Upload
            ref="upload"
            :before-upload="handleFileSelect"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :show-upload-list="false"
            accept="*/*"
            action="/api/attachments/upload"
          >
            <Button type="primary" icon="ios-cloud-upload-outline">选择文件</Button>
          </Upload>
          <div v-if="selectedFile" class="selected-file">
            已选择: {{ selectedFile.name }} ({{ formatFileSize(selectedFile.size) }})
          </div>
        </FormItem>
        <FormItem label="文件标题" prop="title">
          <Input v-model="uploadForm.title" placeholder="请输入文件标题" />
        </FormItem>
        <FormItem label="文件描述" prop="description">
          <Input
            v-model="uploadForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入文件描述"
          />
        </FormItem>
        <FormItem label="标签" prop="tags">
          <Input v-model="uploadForm.tags" placeholder="请输入标签，用逗号分隔" />
        </FormItem>
        <FormItem label="是否公开">
          <Switch v-model="uploadForm.is_public" />
        </FormItem>
        <FormItem label="是否精选">
          <Switch v-model="uploadForm.is_featured" />
        </FormItem>
      </Form>
      <template #footer>
        <Button @click="resetUploadForm">取消</Button>
        <Button type="primary" :loading="uploading" @click="uploadFile">
          {{ uploading ? '上传中...' : '上传' }}
        </Button>
      </template>
    </Modal>

    <!-- 编辑模态框 -->
    <Modal v-model="showEditModal" title="编辑附件信息" width="600" @on-cancel="cancelEdit">
      <Form :model="editForm" :rules="editRules" ref="editFormRef" :label-width="100">
        <FormItem label="文件标题" prop="title">
          <Input v-model="editForm.title" placeholder="请输入文件标题" />
        </FormItem>
        <FormItem label="文件描述" prop="description">
          <Input
            v-model="editForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入文件描述"
          />
        </FormItem>
        <FormItem label="替代文本" prop="alt_text">
          <Input v-model="editForm.alt_text" placeholder="请输入替代文本" />
        </FormItem>
        <FormItem label="标签" prop="tags">
          <Input v-model="editForm.tags" placeholder="请输入标签，用逗号分隔" />
        </FormItem>
        <FormItem label="是否公开">
          <Switch v-model="editForm.is_public" />
        </FormItem>
        <FormItem label="是否精选">
          <Switch v-model="editForm.is_featured" />
        </FormItem>
      </Form>
      <template #footer>
        <Button @click="cancelEdit">取消</Button>
        <Button type="primary" :loading="saving" @click="saveAttachment">
          {{ saving ? '保存中...' : '保存' }}
        </Button>
      </template>
    </Modal>

    <!-- 图片预览模态框 -->
    <Modal
      v-model="showPreviewModal"
      title="图片预览"
      :width="previewModalWidth"
      :footer-hide="true"
      :mask-closable="true"
      class="image-preview-modal"
    >
      <div class="image-preview-container">
        <div class="image-preview-wrapper" :class="{ fullscreen: isFullscreen }">
          <img
            :src="previewImageUrl"
            alt="预览图片"
            class="preview-image-large"
            @load="onImageLoad"
            @error="onImageError"
          />
          <div class="preview-controls">
            <Button type="primary" size="small" @click="toggleFullscreen" class="fullscreen-btn">
              {{ isFullscreen ? '退出全屏' : '全屏显示' }}
            </Button>
            <Button type="default" size="small" @click="downloadImage" class="download-btn">
              下载图片
            </Button>
          </div>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { attachmentApi } from '@/utils/apiService';
import httpClient from '@/utils/httpClient';
import { Message } from 'view-ui-plus';
import { onMounted, reactive, ref } from 'vue';

// 响应式数据
const loading = ref(false);
const uploading = ref(false);
const saving = ref(false);
const attachments = ref([]);
const stats = ref(null);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(20);
const showUploadModal = ref(false);
const showEditModal = ref(false);
const showPreviewModal = ref(false);
const previewImageUrl = ref('');
const isFullscreen = ref(false);
const imageDimensions = ref({ width: 0, height: 0 });
const previewModalWidth = ref('80%');
const selectedFile = ref(null);
const editingAttachment = ref(null);
const editFormRef = ref(null);
const uploadFormRef = ref(null);

// 筛选条件
const filters = reactive({
  file_category: '',
  status: '',
  search: '',
});

// 上传表单
const uploadForm = reactive({
  title: '',
  description: '',
  tags: '',
  is_public: true,
  is_featured: false,
});

// 编辑表单
const editForm = reactive({
  title: '',
  description: '',
  alt_text: '',
  tags: '',
  is_public: true,
  is_featured: false,
});

// 表单验证规则
const uploadRules = {
  title: [{ required: true, message: '请输入文件标题', trigger: 'change' }],
};

const editRules = {
  title: [{ required: true, message: '请输入文件标题', trigger: 'change' }],
};

// 表格列配置
const columns = [
  {
    title: '预览',
    key: 'file_preview',
    width: 80,
    slot: 'file_preview',
  },
  {
    title: '文件信息',
    key: 'file_info',
    minWidth: 200,
    slot: 'file_info',
  },
  {
    title: 'URL',
    key: 'file_url',
    width: 200,
    slot: 'file_url',
  },
  {
    title: '分类',
    key: 'file_category',
    width: 100,
    render: (h, params) => {
      return h(
        'Tag',
        {
          color: getCategoryColor(params.row.file_category),
        },
        getCategoryLabel(params.row.file_category)
      );
    },
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    slot: 'status',
  },
  {
    title: '查看次数',
    key: 'view_count',
    width: 100,
  },
  {
    title: '上传时间',
    key: 'created_at',
    width: 150,
    render: (h, params) => {
      return h('span', new Date(params.row.created_at).toLocaleString());
    },
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    slot: 'action',
    fixed: 'right',
  },
];

// 工具函数
const formatFileSize = bytes => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const getCategoryLabel = category => {
  const labels = {
    image: '图片',
    document: '文档',
    video: '视频',
    audio: '音频',
    other: '其他',
  };
  return labels[category] || category;
};

const getCategoryColor = category => {
  const colors = {
    image: 'blue',
    document: 'green',
    video: 'red',
    audio: 'orange',
    other: 'default',
  };
  return colors[category] || 'default';
};

const getFileIcon = category => {
  const icons = {
    image: 'ios-image',
    document: 'ios-document',
    video: 'ios-videocam',
    audio: 'ios-musical-notes',
    other: 'ios-folder',
  };
  return icons[category] || 'ios-folder';
};

const getStatusLabel = status => {
  const labels = {
    active: '正常',
    hidden: '隐藏',
    deleted: '已删除',
  };
  return labels[status] || status;
};

const getStatusColor = status => {
  const colors = {
    active: 'green',
    hidden: 'orange',
    deleted: 'red',
  };
  return colors[status] || 'default';
};

// 加载附件列表
const loadAttachments = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      page_size: pageSize.value,
      ...filters,
    };

    const response = await attachmentApi.getAttachments(params);
    attachments.value = response.data || response;
    total.value = response.total || attachments.value.length;
  } catch (error) {
    console.error('加载附件失败:', error);
    Message.error('加载附件失败!');
  } finally {
    loading.value = false;
  }
};

// 加载统计信息
const loadStats = async () => {
  try {
    const response = await attachmentApi.getAttachmentStats();
    stats.value = response.data || response;
  } catch (error) {
    console.error('加载统计信息失败:', error);
  }
};

// 文件选择处理
const handleFileSelect = file => {
  selectedFile.value = file;
  uploadForm.title = file.name.split('.')[0];
  return false; // 阻止自动上传
};

// 文件上传
const uploadFile = async () => {
  if (!selectedFile.value) {
    Message.warning('请选择文件!');
    return;
  }

  try {
    await uploadFormRef.value.validate();

    uploading.value = true;

    // eslint-disable-next-line no-undef
    const formData = new FormData();
    formData.append('file', selectedFile.value);
    formData.append('title', uploadForm.title);
    formData.append('description', uploadForm.description);
    formData.append('tags', uploadForm.tags);
    formData.append('is_public', uploadForm.is_public.toString());
    formData.append('is_featured', uploadForm.is_featured.toString());

    // 直接使用httpClient发送FormData
    await httpClient.post('/api/attachments/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    Message.success('文件上传成功!');
    showUploadModal.value = false;
    resetUploadForm();
    loadAttachments();
    loadStats();
  } catch (error) {
    console.error('上传失败:', error);
    Message.error('上传失败!');
  } finally {
    uploading.value = false;
  }
};

// 编辑附件
const editAttachment = attachment => {
  editingAttachment.value = attachment;
  Object.assign(editForm, {
    title: attachment.title || '',
    description: attachment.description || '',
    alt_text: attachment.alt_text || '',
    tags: attachment.tags || '',
    is_public: attachment.is_public,
    is_featured: attachment.is_featured,
  });
  showEditModal.value = true;
};

// 保存附件信息
const saveAttachment = async () => {
  try {
    await editFormRef.value.validate();

    saving.value = true;

    await attachmentApi.updateAttachment(editingAttachment.value.id, editForm);

    Message.success('保存成功!');
    showEditModal.value = false;
    resetEditForm();
    loadAttachments();
  } catch (error) {
    console.error('保存失败:', error);
    Message.error('保存失败!');
  } finally {
    saving.value = false;
  }
};

// 删除附件
const deleteAttachment = async attachment => {
  try {
    await attachmentApi.deleteAttachment(attachment.id);
    Message.success('删除成功!');
    loadAttachments();
    loadStats();
  } catch (error) {
    console.error('删除失败:', error);
    Message.error('删除失败!');
  }
};

// 恢复附件
const restoreAttachment = async attachment => {
  try {
    await attachmentApi.restoreAttachment(attachment.id);
    Message.success('恢复成功!');
    loadAttachments();
    loadStats();
  } catch (error) {
    console.error('恢复失败:', error);
    Message.error('恢复失败!');
  }
};

// 预览图片
const previewImage = attachment => {
  previewImageUrl.value = attachment.file_url;
  isFullscreen.value = false;
  showPreviewModal.value = true;
};

// 图片加载完成
const onImageLoad = event => {
  const img = event.target;
  imageDimensions.value = {
    width: img.naturalWidth,
    height: img.naturalHeight,
  };
  calculateModalSize();
};

// 图片加载错误
const onImageError = () => {
  Message.error('图片加载失败');
};

// 计算模态框大小
const calculateModalSize = () => {
  const { width, height } = imageDimensions.value;
  if (width === 0 || height === 0) return;

  const maxWidth = window.innerWidth * 0.9;
  const maxHeight = window.innerHeight * 0.8;

  let modalWidth = Math.min(width + 100, maxWidth);
  let modalHeight = Math.min(height + 100, maxHeight);

  // 保持宽高比
  if (width > height) {
    modalHeight = (height / width) * modalWidth;
  } else {
    modalWidth = (width / height) * modalHeight;
  }

  previewModalWidth.value = `${Math.max(modalWidth, 400)}px`;
};

// 切换全屏
const toggleFullscreen = () => {
  isFullscreen.value = !isFullscreen.value;
  if (isFullscreen.value) {
    previewModalWidth.value = '100vw';
  } else {
    calculateModalSize();
  }
};

// 下载图片
const downloadImage = () => {
  const link = document.createElement('a');
  link.href = previewImageUrl.value;
  link.download = previewImageUrl.value.split('/').pop();
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  Message.success('图片下载已开始');
};

// 分页处理
const handlePageChange = page => {
  currentPage.value = page;
  loadAttachments();
};

const handlePageSizeChange = size => {
  pageSize.value = size;
  currentPage.value = 1;
  loadAttachments();
};

// 重置筛选条件
const resetFilters = () => {
  Object.assign(filters, {
    file_category: '',
    status: '',
    search: '',
  });
  currentPage.value = 1;
  loadAttachments();
};

// 重置上传表单
const resetUploadForm = () => {
  Object.assign(uploadForm, {
    title: '',
    description: '',
    tags: '',
    is_public: true,
    is_featured: false,
  });
  selectedFile.value = null;
  uploadFormRef.value?.resetFields();
};

// 取消编辑（只关闭对话框，不清空表单）
const cancelEdit = () => {
  showEditModal.value = false;
};

// 重置编辑表单
const resetEditForm = () => {
  Object.assign(editForm, {
    title: '',
    description: '',
    alt_text: '',
    tags: '',
    is_public: true,
    is_featured: false,
  });
  editingAttachment.value = null;
  editFormRef.value?.resetFields();
};

// 上传成功处理
const handleUploadSuccess = () => {
  Message.success('文件上传成功！');
  showUploadModal.value = false;
  resetUploadForm();
  loadAttachments();
  loadStats();
};

// 上传失败处理
const handleUploadError = error => {
  console.error('上传失败:', error);
  Message.error('文件上传失败，请重试！');
};

// 获取完整URL
const getFullUrl = fileUrl => {
  if (!fileUrl || fileUrl === '') {
    return '';
  }

  if (typeof window !== 'undefined' && window.location) {
    return `${window.location.origin}${fileUrl}`;
  }
  // 如果window不可用，使用默认的localhost地址
  return `http://localhost:8000${fileUrl}`;
};

// 复制URL
const copyUrl = async url => {
  try {
    await navigator.clipboard.writeText(url);
    Message.success('URL已复制到剪贴板！');
  } catch (error) {
    console.error('复制失败:', error);
    Message.error('复制失败，请手动复制！');
  }
};

// 生命周期
onMounted(() => {
  loadAttachments();
  loadStats();
});
</script>

<style scoped>
.attachment-management {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
  text-align: center;
}

.page-header h2 {
  font-size: 24px;
  color: #333;
  margin-bottom: 8px;
}

.page-header p {
  color: #666;
  font-size: 14px;
}

.management-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.filter-section {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
}

.filter-controls {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.stats-section {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #f8f9fa;
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.stat-card {
  text-align: center;
  min-width: 100px;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #1890ff;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #666;
}

.table-section {
  padding: 20px;
}

.file-preview {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
}

.preview-image {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s;
}

.preview-image:hover {
  transform: scale(1.1);
}

.file-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  border-radius: 4px;
  color: #999;
}

.file-info {
  min-width: 180px;
}

.file-name {
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.file-meta {
  font-size: 12px;
  color: #666;
}

.action-buttons {
  display: flex;
  gap: 5px;
}

.pagination-section {
  padding: 20px;
  text-align: center;
  border-top: 1px solid #f0f0f0;
}

.selected-file {
  margin-top: 8px;
  padding: 8px;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 4px;
  font-size: 12px;
  color: #0369a1;
}

/* 图片预览模态框样式 */
.image-preview-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
  max-height: 80vh;
  overflow: auto;
}

.image-preview-wrapper {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  max-width: 100%;
  max-height: 100%;
}

.image-preview-wrapper.fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.9);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-image-large {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  transition: transform 0.3s ease;
}

.preview-image-large:hover {
  transform: scale(1.02);
}

.preview-controls {
  position: absolute;
  top: 10px;
  right: 10px;
  display: flex;
  gap: 8px;
  z-index: 10;
}

.fullscreen-btn,
.download-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid #d1d5db;
  color: #374151;
  font-weight: 500;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.fullscreen-btn:hover,
.download-btn:hover {
  background: rgba(255, 255, 255, 1);
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .image-preview-container {
    max-height: 70vh;
  }

  .preview-image-large {
    max-height: 60vh;
  }

  .preview-controls {
    position: static;
    margin-top: 10px;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .preview-image-large {
    max-height: 50vh;
  }
}

/* 修复下拉框滚动条样式，不受系统主题影响 */
:deep(.ivu-select-dropdown-list) {
  scrollbar-width: thin !important;
  scrollbar-color: #c1c1c1 #ffffff !important;
}

:deep(.ivu-select-dropdown-list::-webkit-scrollbar) {
  width: 6px !important;
  height: 6px !important;
}

:deep(.ivu-select-dropdown-list::-webkit-scrollbar-track) {
  background: #ffffff !important;
  border-radius: 3px !important;
}

:deep(.ivu-select-dropdown-list::-webkit-scrollbar-thumb) {
  background: #c1c1c1 !important;
  border-radius: 3px !important;
}

:deep(.ivu-select-dropdown-list::-webkit-scrollbar-thumb:hover) {
  background: #a8a8a8 !important;
}

/* 全局修复所有下拉框滚动条 */
.ivu-select-dropdown-list {
  scrollbar-width: thin !important;
  scrollbar-color: #c1c1c1 #ffffff !important;
}

.ivu-select-dropdown-list::-webkit-scrollbar {
  width: 6px !important;
  height: 6px !important;
}

.ivu-select-dropdown-list::-webkit-scrollbar-track {
  background: #ffffff !important;
  border-radius: 3px !important;
}

.ivu-select-dropdown-list::-webkit-scrollbar-thumb {
  background: #c1c1c1 !important;
  border-radius: 3px !important;
}

.ivu-select-dropdown-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8 !important;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .attachment-management {
    padding: 10px;
  }

  .filter-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-section {
    flex-direction: column;
    align-items: center;
  }

  .action-buttons {
    flex-direction: column;
  }
}
</style>
