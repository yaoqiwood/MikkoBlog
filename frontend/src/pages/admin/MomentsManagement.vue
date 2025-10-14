<template>
  <div class="moments-management">
    <Card>
      <template #title>
        <Icon type="ios-chatbubbles" />
        说说管理
      </template>
      <template #extra>
        <Button
          type="primary"
          @click="showCreateModal = true"
          size="large"
          class="add-moment-button"
        >
          <Icon type="ios-add-circle" />
          发布说说
        </Button>
      </template>

      <!-- 筛选条件 -->
      <div class="filter-bar">
        <div class="filter-controls">
          <div class="filter-item">
            <label>可见性</label>
            <Select v-model="filters.is_visible" style="width: 120px" @change="loadMoments">
              <Option value="">全部</Option>
              <Option value="true">可见</Option>
              <Option value="false">隐藏</Option>
            </Select>
          </div>
          <div class="filter-item">
            <label>用户</label>
            <Input
              v-model="filters.user_id"
              placeholder="用户ID"
              style="width: 120px"
              @on-enter="loadMoments"
            />
          </div>
          <div class="filter-buttons">
            <Button @click="loadMoments">搜索</Button>
            <Button @click="resetFilters" style="margin-left: 8px">重置</Button>
          </div>
        </div>
      </div>

      <!-- 说说列表 -->
      <div class="moments-list">
        <div v-if="loading" class="loading-container">
          <Spin size="large" />
        </div>
        <div v-else-if="moments.length === 0" class="empty-container">
          <Empty description="暂无说说数据" />
        </div>
        <div v-else>
          <div v-for="moment in moments" :key="moment.id" class="moment-item">
            <div class="moment-header">
              <div class="user-info">
                <Avatar :src="moment.user_avatar" size="small" />
                <span class="username">{{ moment.user_nickname || '未知用户' }}</span>
                <span class="user-id">(ID: {{ moment.user_id }})</span>
              </div>
              <div class="moment-actions">
                <Button size="small" @click="editMoment(moment)">编辑</Button>
                <Button
                  size="small"
                  :type="moment.is_visible ? 'warning' : 'success'"
                  @click="toggleVisibility(moment)"
                >
                  {{ moment.is_visible ? '隐藏' : '显示' }}
                </Button>
                <Button size="small" type="error" @click="deleteMoment(moment)">删除</Button>
              </div>
            </div>
            <div class="moment-content">
              <p>{{ moment.content }}</p>
            </div>
            <!-- 朋友圈式图片展示 -->
            <div v-if="moment.images && moment.images.length > 0" class="moment-images">
              <div :class="getImageGridClass(moment.images.length)">
                <div
                  v-for="(image, index) in moment.images"
                  :key="image.id"
                  class="image-item"
                  @click="previewImage(moment.images, index)"
                >
                  <img :src="getFullImageUrl(image.url)" :alt="image.filename" />
                </div>
              </div>
            </div>
            <div class="moment-meta">
              <span class="time">{{ formatTime(moment.created_at) }}</span>
              <Tag v-if="!moment.is_visible" color="orange">隐藏</Tag>
            </div>
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div class="pagination-container">
        <Page
          :current="currentPage"
          :total="total"
          :page-size="pageSize"
          @on-change="handlePageChange"
          show-total
          show-sizer
          @on-page-size-change="handlePageSizeChange"
        />
      </div>
    </Card>

    <!-- 创建/编辑说说模态框 -->
    <Modal
      v-model="showCreateModal"
      :title="editingMoment ? '编辑说说' : '发布说说'"
      width="650"
      class-name="moments-modal"
      :mask-closable="false"
    >
      <div class="moments-form">
        <!-- 用户头像和输入区域 -->
        <div class="form-header">
          <Avatar size="large" icon="ios-person" />
          <div class="form-main">
            <div class="textarea-container">
              <Input
                v-model="momentForm.content"
                type="textarea"
                :rows="4"
                :maxlength="150"
                show-word-limit
                placeholder="分享你的想法..."
                class="moments-textarea"
              />
            </div>

            <!-- 图片上传区域 -->
            <div class="image-upload-section">
              <div class="uploaded-images-grid">
                <div
                  v-for="(image, index) in momentForm.images"
                  :key="image.id"
                  class="uploaded-image-item"
                >
                  <img :src="image.url" :alt="image.filename" />
                  <div class="image-remove" @click="removeImage(index)">
                    <Icon type="ios-close" />
                  </div>
                </div>

                <!-- 添加图片按钮 -->
                <div
                  v-if="momentForm.images.length < 9"
                  class="add-image-btn"
                  @click="triggerUpload"
                >
                  <Icon type="ios-add" size="32" />
                </div>
              </div>

              <input
                ref="fileInput"
                type="file"
                multiple
                accept="image/*"
                style="display: none"
                @change="handleImageUpload"
              />
            </div>

            <!-- 底部工具栏 -->
            <div class="form-toolbar">
              <div class="toolbar-left">
                <Button
                  type="text"
                  @click="triggerUpload"
                  :disabled="momentForm.images.length >= 9"
                >
                  <Icon type="ios-images" />
                  图片 ({{ momentForm.images.length }}/9)
                </Button>
              </div>
              <div class="toolbar-right">
                <div class="visibility-switch">
                  <span>可见性：</span>
                  <Switch v-model="momentForm.is_visible" size="small">
                    <template #open>
                      <span>公开</span>
                    </template>
                    <template #close>
                      <span>隐藏</span>
                    </template>
                  </Switch>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="modal-footer">
          <Button @click="resetForm">取消</Button>
          <Button type="primary" @click="saveMoment" :loading="saving">
            {{ editingMoment ? '更新' : '发布' }}
          </Button>
        </div>
      </template>
    </Modal>

    <!-- 图片预览 -->
    <Modal
      v-model="showImagePreview"
      width="90%"
      class-name="image-preview-modal"
      :mask-closable="true"
      :closable="true"
    >
      <template #header>
        <div class="preview-header">
          <span>图片预览 ({{ previewIndex + 1 }} / {{ previewImages.length }})</span>
          <div class="preview-actions">
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
      <div class="image-preview-container">
        <img :src="previewImageUrl" alt="预览图片" @click="closeImagePreview" />
        <div class="preview-tip">点击图片关闭预览 | 使用 ← → 键切换图片 | ESC 键关闭</div>
      </div>
      <template #footer>
        <div class="preview-footer">
          <Button @click="closeImagePreview">关闭</Button>
        </div>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { momentsApi } from '@/utils/apiService';
import { Message, Modal } from 'view-ui-plus';
import { onMounted, onUnmounted, reactive, ref } from 'vue';

// 响应式数据
const moments = ref([]);
const loading = ref(false);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 筛选条件
const filters = reactive({
  is_visible: '',
  user_id: '',
});

// 创建/编辑表单
const showCreateModal = ref(false);
const editingMoment = ref(null);
const saving = ref(false);
const momentForm = reactive({
  content: '',
  images: [],
  is_visible: true,
});

// const momentRules = {
//   content: [
//     { required: true, message: '请输入说说内容', trigger: 'blur' },
//     { max: 150, message: '内容不能超过150字', trigger: 'blur' },
//   ],
// };

// 图片预览
const showImagePreview = ref(false);
const previewImages = ref([]);
const previewIndex = ref(0);
const previewImageUrl = ref('');

// 文件上传
const fileInput = ref(null);

// 加载说说列表
const loadMoments = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      limit: pageSize.value,
    };

    if (filters.is_visible !== '') {
      params.is_visible = filters.is_visible === 'true';
    }
    if (filters.user_id) {
      params.user_id = parseInt(filters.user_id);
    }

    const data = await momentsApi.getMoments(params);
    // 后端返回的是 MomentsListResponse 格式
    moments.value = data.items || [];
    total.value = data.total || 0;
  } catch (error) {
    console.error('加载说说失败:', error);
    Message.error('加载说说失败');
  } finally {
    loading.value = false;
  }
};

// 重置筛选条件
const resetFilters = () => {
  filters.is_visible = '';
  filters.user_id = '';
  currentPage.value = 1;
  loadMoments();
};

// 分页处理
const handlePageChange = page => {
  currentPage.value = page;
  loadMoments();
};

const handlePageSizeChange = size => {
  pageSize.value = size;
  currentPage.value = 1;
  loadMoments();
};

// 编辑说说
const editMoment = moment => {
  editingMoment.value = moment;
  momentForm.content = moment.content;
  // 将后端图片数据转换为前端需要的格式
  momentForm.images = (moment.images || []).map(img => ({
    id: img.id,
    url: getFullImageUrl(img.url),
    filename: img.filename,
  }));
  momentForm.is_visible = moment.is_visible;
  showCreateModal.value = true;
};

// 切换可见性
const toggleVisibility = async moment => {
  try {
    await momentsApi.toggleMomentVisibility(moment.id);
    Message.success('更新成功');
    loadMoments();
  } catch (error) {
    console.error('更新失败:', error);
    Message.error('更新失败');
  }
};

// 删除说说
const deleteMoment = moment => {
  Modal.confirm({
    title: '确认删除',
    content: '确定要删除这条说说吗？此操作不可恢复。',
    onOk: async () => {
      try {
        await momentsApi.deleteMoment(moment.id);
        Message.success('删除成功');
        loadMoments();
      } catch (error) {
        console.error('删除失败:', error);
        Message.error('删除失败');
      }
    },
  });
};

// 发布/更新说说
const saveMoment = async () => {
  // 验证内容
  if (!momentForm.content.trim()) {
    Message.error('请输入说说内容');
    return;
  }

  if (momentForm.content.length > 150) {
    Message.error('说说内容不能超过150字');
    return;
  }

  saving.value = true;
  try {
    const imageIds = momentForm.images.map(img => img.id).filter(id => id);
    const data = {
      content: momentForm.content.trim(),
      is_visible: momentForm.is_visible,
      image_ids: imageIds,
    };

    if (editingMoment.value) {
      await momentsApi.updateMoment(editingMoment.value.id, data);
      Message.success('更新成功');
    } else {
      await momentsApi.createMoment(data);
      Message.success('发布成功');
    }

    showCreateModal.value = false;
    resetForm();
    loadMoments();
  } catch (error) {
    console.error('操作失败:', error);
    const errorMsg = error.response?.data?.detail || error.message || '操作失败';
    Message.error(errorMsg);
  } finally {
    saving.value = false;
  }
};

// 重置表单
const resetForm = () => {
  showCreateModal.value = false;
  editingMoment.value = null;
  momentForm.content = '';
  momentForm.images = [];
  momentForm.is_visible = true;
  saving.value = false;
};

// 触发文件上传
const triggerUpload = () => {
  fileInput.value.click();
};

// 处理图片上传
const handleImageUpload = async event => {
  const files = Array.from(event.target.files);
  if (files.length === 0) return;

  // 检查图片数量限制
  if (momentForm.images.length + files.length > 9) {
    Message.warning('最多只能上传9张图片');
    return;
  }

  for (const file of files) {
    try {
      const formData = new window.FormData();
      formData.append('file', file);

      // 使用附件上传API而不是简单的图片上传API
      const { authCookie } = await import('@/utils/cookieUtils');
      const token = authCookie.getAuth().token;

      const result = await window.fetch('/api/attachments/upload', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (!result.ok) {
        const errorData = await result.json();
        throw new Error(errorData.detail || '上传失败');
      }

      const attachment = await result.json();
      momentForm.images.push({
        id: attachment.id,
        url: getFullImageUrl(attachment.file_url),
        filename: attachment.original_name,
      });
    } catch (error) {
      console.error('上传失败:', error);
      Message.error(`上传 ${file.name} 失败`);
    }
  }

  // 清空文件输入
  event.target.value = '';
};

// 移除图片
const removeImage = index => {
  momentForm.images.splice(index, 1);
};

// 获取图片网格样式类
const getImageGridClass = count => {
  if (count === 1) return 'images-grid-1';
  if (count === 2) return 'images-grid-2';
  if (count === 3) return 'images-grid-3';
  if (count === 4) return 'images-grid-4';
  return 'images-grid-9';
};

// 获取完整的图片URL
const getFullImageUrl = url => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return url; // 使用相对路径，让Nginx代理处理
};

// 预览图片
const previewImage = (images, index) => {
  previewImages.value = images;
  previewIndex.value = index;
  previewImageUrl.value = getFullImageUrl(images[index].url);
  showImagePreview.value = true;

  // 添加键盘事件监听
  document.addEventListener('keydown', handleKeydown);
};

// 键盘导航
const handleKeydown = event => {
  if (!showImagePreview.value) return;

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
  }
};

// 关闭图片预览
const closeImagePreview = () => {
  showImagePreview.value = false;
  document.removeEventListener('keydown', handleKeydown);
};

// 上一张图片
const prevImage = () => {
  if (previewIndex.value > 0) {
    previewIndex.value--;
    previewImageUrl.value = getFullImageUrl(previewImages.value[previewIndex.value].url);
  }
};

// 下一张图片
const nextImage = () => {
  if (previewIndex.value < previewImages.value.length - 1) {
    previewIndex.value++;
    previewImageUrl.value = getFullImageUrl(previewImages.value[previewIndex.value].url);
  }
};

// 格式化时间
const formatTime = dateString => {
  const date = new Date(dateString);
  const now = new Date();
  const diff = now - date;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return '刚刚';
  if (minutes < 60) return `${minutes}分钟前`;
  if (hours < 24) return `${hours}小时前`;
  if (days < 7) return `${days}天前`;
  return date.toLocaleDateString();
};

// 生命周期
onMounted(() => {
  loadMoments();
});

onUnmounted(() => {
  // 清理键盘事件监听器
  document.removeEventListener('keydown', handleKeydown);
});
</script>

<style scoped>
.moments-management {
  padding: 20px;
}

.filter-bar {
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 6px;
}

.filter-controls {
  display: flex;
  align-items: flex-end;
  gap: 16px;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-item label {
  font-size: 14px;
  color: #515a6e;
  margin-bottom: 4px;
}

.filter-buttons {
  display: flex;
  gap: 8px;
}

.moments-list {
  min-height: 400px;
}

.loading-container,
.empty-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
}

.moment-item {
  border: 1px solid #e8eaec;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  background: white;
}

.moment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.username {
  font-weight: 500;
}

.user-id {
  color: #999;
  font-size: 12px;
}

.moment-actions {
  display: flex;
  gap: 8px;
}

.moment-content {
  margin-bottom: 12px;
  line-height: 1.6;
}

.moment-images {
  margin-bottom: 12px;
}

/* 管理页面小尺寸图片网格布局 */
.images-grid-1 {
  display: grid;
  grid-template-columns: 1fr;
  gap: 3px;
  max-width: 60px;
}

.images-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3px;
  max-width: 120px;
}

.images-grid-3 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 3px;
  max-width: 180px;
}

.images-grid-4 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3px;
  max-width: 120px;
}

.images-grid-9 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 3px;
  max-width: 180px;
}

.image-item {
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  border: 1px solid #e8eaec;
}

.image-item:hover {
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border-color: #1890ff;
}

.image-item::after {
  content: '🔍';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.6);
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  opacity: 0;
  transition: opacity 0.2s;
}

.image-item:hover::after {
  opacity: 1;
}

.image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.moment-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #999;
  font-size: 12px;
}

.pagination-container {
  margin-top: 20px;
  text-align: center;
}

/* 朋友圈式发布表单样式 */
.moments-form {
  padding: 0;
}

.form-header {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.form-main {
  flex: 1;
}

.textarea-container {
  margin-bottom: 16px;
}

.moments-textarea {
  border: none;
  box-shadow: none;
  resize: none;
}

:deep(.moments-textarea .ivu-input) {
  border: none;
  box-shadow: none;
  padding: 0;
  font-size: 16px;
  line-height: 1.5;
  background: transparent;
}

:deep(.moments-textarea .ivu-input:focus) {
  border: none;
  box-shadow: none;
}

/* 图片上传网格 */
.image-upload-section {
  margin-bottom: 16px;
}

.uploaded-images-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  max-width: 240px;
}

.uploaded-image-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f5f5;
}

.uploaded-image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-remove {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 20px;
  height: 20px;
  background: rgba(0, 0, 0, 0.6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.2s;
}

.uploaded-image-item:hover .image-remove {
  opacity: 1;
}

.add-image-btn {
  aspect-ratio: 1;
  border: 2px dashed #d9d9d9;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #999;
  transition: all 0.2s;
  background: #fafafa;
}

.add-image-btn:hover {
  border-color: #1890ff;
  color: #1890ff;
  background: #f0f8ff;
}

/* 工具栏 */
.form-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.toolbar-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.visibility-switch {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #666;
}

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
  margin-right: 20px; /* 向左移动按钮 */
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
}

.image-preview-container img {
  max-width: 100%;
  max-height: 50vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  transition: transform 0.2s ease;
}

.image-preview-container img:hover {
  transform: scale(1.02);
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

.add-moment-button {
  position: relative;
  top: 3px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
