<template>
  <div class="moments-management">
    <Card>
      <template #title>
        <Icon type="ios-chatbubbles" />
        说说管理
      </template>
      <template #extra>
        <Button type="primary" @click="showCreateModal = true">
          <Icon type="ios-add" />
          发布说说
        </Button>
      </template>

      <!-- 筛选条件 -->
      <div class="filter-bar">
        <Form inline>
          <FormItem label="可见性">
            <Select v-model="filters.is_visible" style="width: 120px" @change="loadMoments">
              <Option value="">全部</Option>
              <Option :value="true">可见</Option>
              <Option :value="false">隐藏</Option>
            </Select>
          </FormItem>
          <FormItem label="用户">
            <Input
              v-model="filters.user_id"
              placeholder="用户ID"
              style="width: 120px"
              @on-enter="loadMoments"
            />
          </FormItem>
          <FormItem>
            <Button @click="loadMoments">搜索</Button>
            <Button @click="resetFilters" style="margin-left: 8px">重置</Button>
          </FormItem>
        </Form>
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
                <span class="username">{{ moment.user_nickname }}</span>
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
                  <img :src="image.url" :alt="image.filename" />
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
      width="600"
      @on-ok="saveMoment"
      @on-cancel="resetForm"
    >
      <Form ref="momentForm" :model="momentForm" :rules="momentRules" label-position="top">
        <FormItem label="说说内容" prop="content">
          <Input
            v-model="momentForm.content"
            type="textarea"
            :rows="4"
            :maxlength="150"
            show-word-limit
            placeholder="分享你的想法..."
          />
        </FormItem>
        <FormItem label="图片">
          <div class="image-upload-area">
            <div class="uploaded-images">
              <div
                v-for="(image, index) in momentForm.images"
                :key="image.id"
                class="uploaded-image"
              >
                <img :src="image.url" :alt="image.filename" />
                <div class="image-overlay">
                  <Button size="small" type="error" @click="removeImage(index)">删除</Button>
                </div>
              </div>
            </div>
            <div v-if="momentForm.images.length < 9" class="upload-trigger" @click="triggerUpload">
              <Icon type="ios-camera" size="24" />
              <p>添加图片</p>
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
        </FormItem>
        <FormItem label="可见性">
          <Switch v-model="momentForm.is_visible">
            <span slot="open">可见</span>
            <span slot="close">隐藏</span>
          </Switch>
        </FormItem>
      </Form>
    </Modal>

    <!-- 图片预览 -->
    <Modal v-model="showImagePreview" width="80%" class-name="image-preview-modal">
      <div class="image-preview-container">
        <img :src="previewImageUrl" alt="预览图片" />
      </div>
      <template #footer>
        <div class="preview-controls">
          <Button @click="prevImage" :disabled="previewIndex === 0">上一张</Button>
          <span>{{ previewIndex + 1 }} / {{ previewImages.length }}</span>
          <Button @click="nextImage" :disabled="previewIndex === previewImages.length - 1">
            下一张
          </Button>
        </div>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { Message, Modal } from 'view-ui-plus';
import { onMounted, reactive, ref } from 'vue';

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
const momentForm = reactive({
  content: '',
  images: [],
  is_visible: true,
});

const momentRules = {
  content: [
    { required: true, message: '请输入说说内容', trigger: 'blur' },
    { max: 150, message: '内容不能超过150字', trigger: 'blur' },
  ],
};

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
    const params = new URLSearchParams({
      page: currentPage.value.toString(),
      limit: pageSize.value.toString(),
    });

    if (filters.is_visible !== '') {
      params.append('is_visible', filters.is_visible.toString());
    }
    if (filters.user_id) {
      params.append('user_id', filters.user_id);
    }

    const response = await fetch(`/api/moments?${params}`);
    if (!response.ok) throw new Error('获取说说列表失败');

    const data = await response.json();
    moments.value = data.items;
    total.value = data.total;
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
  momentForm.images = moment.images || [];
  momentForm.is_visible = moment.is_visible;
  showCreateModal.value = true;
};

// 切换可见性
const toggleVisibility = async moment => {
  try {
    const response = await fetch(`/api/moments/${moment.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_visible: !moment.is_visible }),
    });

    if (!response.ok) throw new Error('更新失败');

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
        const response = await fetch(`/api/moments/${moment.id}`, {
          method: 'DELETE',
        });

        if (!response.ok) throw new Error('删除失败');

        Message.success('删除成功');
        loadMoments();
      } catch (error) {
        console.error('删除失败:', error);
        Message.error('删除失败');
      }
    },
  });
};

// 保存说说
const saveMoment = async () => {
  try {
    const imageIds = momentForm.images.map(img => img.id);
    const data = {
      content: momentForm.content,
      is_visible: momentForm.is_visible,
      image_ids: imageIds,
    };

    const url = editingMoment.value ? `/api/moments/${editingMoment.value.id}` : '/api/moments';
    const method = editingMoment.value ? 'PUT' : 'POST';

    const response = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    if (!response.ok) throw new Error('保存失败');

    Message.success(editingMoment.value ? '更新成功' : '发布成功');
    showCreateModal.value = false;
    resetForm();
    loadMoments();
  } catch (error) {
    console.error('保存失败:', error);
    Message.error('保存失败');
  }
};

// 重置表单
const resetForm = () => {
  editingMoment.value = null;
  momentForm.content = '';
  momentForm.images = [];
  momentForm.is_visible = true;
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
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch('/api/upload/image', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) throw new Error('上传失败');

      const result = await response.json();
      momentForm.images.push({
        id: result.id,
        url: result.url,
        filename: result.filename,
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

// 预览图片
const previewImage = (images, index) => {
  previewImages.value = images;
  previewIndex.value = index;
  previewImageUrl.value = images[index].url;
  showImagePreview.value = true;
};

// 上一张图片
const prevImage = () => {
  if (previewIndex.value > 0) {
    previewIndex.value--;
    previewImageUrl.value = previewImages.value[previewIndex.value].url;
  }
};

// 下一张图片
const nextImage = () => {
  if (previewIndex.value < previewImages.value.length - 1) {
    previewIndex.value++;
    previewImageUrl.value = previewImages.value[previewIndex.value].url;
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

/* 朋友圈式图片网格布局 */
.images-grid-1 {
  display: grid;
  grid-template-columns: 1fr;
  gap: 4px;
  max-width: 200px;
}

.images-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  max-width: 300px;
}

.images-grid-3 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 4px;
  max-width: 300px;
}

.images-grid-4 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  max-width: 300px;
}

.images-grid-9 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 4px;
  max-width: 300px;
}

.image-item {
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s;
}

.image-item:hover {
  transform: scale(1.02);
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

/* 创建/编辑表单样式 */
.image-upload-area {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.uploaded-images {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.uploaded-image {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 4px;
  overflow: hidden;
}

.uploaded-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}

.uploaded-image:hover .image-overlay {
  opacity: 1;
}

.upload-trigger {
  width: 80px;
  height: 80px;
  border: 2px dashed #d7dde4;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #999;
  transition: all 0.2s;
}

.upload-trigger:hover {
  border-color: #2d8cf0;
  color: #2d8cf0;
}

.upload-trigger p {
  margin: 4px 0 0 0;
  font-size: 12px;
}

/* 图片预览样式 */
.image-preview-container {
  text-align: center;
}

.image-preview-container img {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
}

.preview-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
}

:deep(.image-preview-modal .ivu-modal-body) {
  padding: 0;
}
</style>
