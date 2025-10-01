<template>
  <div class="page-container">
    <Card class="mb-6">
      <template #title>
        <Icon type="ios-settings" />
        主页设置
      </template>
      <Form :model="form" label-position="left" :label-width="'auto'">
        <FormItem label="用户卡片 Banner 图">
          <div class="banner-upload-container">
            <div v-if="!form.banner_image_url" class="upload-area" @click="triggerFileInput">
              <Icon type="ios-cloud-upload" size="48" />
              <p>点击上传 Banner 图片</p>
              <p class="upload-tip">建议尺寸比例适合 120px 高度</p>
            </div>
            <div v-else class="banner-preview">
              <img :src="form.banner_image_url" alt="Banner Preview" class="banner-image" />
              <div class="banner-actions">
                <Button size="small" @click="triggerFileInput">重新上传</Button>
                <Button size="small" type="error" @click="removeBanner">删除</Button>
              </div>
            </div>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              @change="handleFileSelect"
              style="display: none"
            />
          </div>
        </FormItem>
        <FormItem label="博客全背景图">
          <div class="background-upload-container">
            <div
              v-if="!form.background_image_url"
              class="upload-area"
              @click="triggerBackgroundFileInput"
            >
              <Icon type="ios-cloud-upload" size="48" />
              <p>点击上传背景图片</p>
              <p class="upload-tip">要求：至少1080分辨率，文件大小不超过5MB</p>
            </div>
            <div v-else class="background-preview">
              <img
                :src="form.background_image_url"
                alt="Background Preview"
                class="background-image"
              />
              <div class="background-actions">
                <Button size="small" @click="triggerBackgroundFileInput">重新上传</Button>
                <Button size="small" type="error" @click="removeBackground">删除</Button>
              </div>
            </div>
            <input
              ref="backgroundFileInput"
              type="file"
              accept="image/*"
              @change="handleBackgroundFileSelect"
              style="display: none"
            />
          </div>
        </FormItem>
        <FormItem label="显示音乐模块">
          <Switch v-model="form.show_music_player" />
        </FormItem>
        <FormItem label="音乐地址 (URL)" v-if="form.show_music_player">
          <Input v-model="form.music_url" placeholder="https://.../song.mp3" />
        </FormItem>
        <FormItem label="显示 Live2D 看板娘">
          <Switch v-model="form.show_live2d" />
        </FormItem>
        <FormItem>
          <div class="button-group">
            <Button type="primary" :loading="saving" @click="save">保存设置</Button>
            <Button @click="load">重置</Button>
            <Button type="warning" @click="confirmResetToDefault">恢复默认</Button>
          </div>
        </FormItem>
      </Form>
    </Card>

    <Alert v-if="error" type="error" show-icon>{{ error }}</Alert>

    <!-- 图片裁剪模态框 -->
    <Modal v-model="showCropModal" title="裁剪 Banner 图片" width="800" :mask-closable="false">
      <div class="crop-container">
        <div class="crop-preview">
          <img ref="cropImage" :src="cropImageSrc" alt="Crop Preview" />
          <div class="crop-overlay" ref="cropOverlay">
            <div class="crop-box" ref="cropBox"></div>
          </div>
        </div>
        <div class="crop-info">
          <p>请拖拽选择要显示的图片区域</p>
          <p>目标尺寸比例: 适合 120px 高度</p>
        </div>
      </div>
      <template #footer>
        <Button @click="showCropModal = false">取消</Button>
        <Button type="primary" @click="confirmCrop">确认裁剪</Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { homepageApi } from '@/utils/apiService';
import { Message, Modal } from 'view-ui-plus';
import { nextTick, onMounted, ref } from 'vue';

const form = ref({
  banner_image_url: '',
  background_image_url: '',
  show_music_player: false,
  music_url: '',
  show_live2d: false,
});
const saving = ref(false);
const error = ref('');
const fileInput = ref(null);
const showCropModal = ref(false);
const cropImageSrc = ref('');
const cropImage = ref(null);
const cropOverlay = ref(null);
const cropBox = ref(null);
const selectedFile = ref(null);
const cropData = ref({ x: 0, y: 0, width: 0, height: 0 });
const backgroundFileInput = ref(null);

async function load() {
  try {
    error.value = '';
    const data = await homepageApi.getSettings();
    form.value = {
      banner_image_url: data.banner_image_url || '',
      background_image_url: data.background_image_url || '',
      show_music_player: !!data.show_music_player,
      music_url: data.music_url || '',
      show_live2d: !!data.show_live2d,
    };
  } catch (err) {
    console.error('加载主页设置失败:', err);
    error.value = '加载主页设置失败';
  }
}

async function save() {
  try {
    saving.value = true;
    error.value = '';
    await homepageApi.updateSettings({ ...form.value });
    Message.success('保存成功');
    await load();
  } catch (err) {
    console.error('保存主页设置失败:', err);
    error.value = '保存主页设置失败';
    Message.error('保存主页设置失败');
  } finally {
    saving.value = false;
  }
}

// 触发文件选择
function triggerFileInput() {
  fileInput.value.click();
}

// 处理文件选择
function handleFileSelect(event) {
  const file = event.target.files[0];
  if (!file) return;

  if (!file.type.startsWith('image/')) {
    Message.error('请选择图片文件');
    return;
  }

  selectedFile.value = file;
  const reader = new window.FileReader();
  reader.onload = e => {
    cropImageSrc.value = e.target.result;
    showCropModal.value = true;
    nextTick(() => {
      initCropBox();
    });
  };
  reader.readAsDataURL(file);
}

// 初始化裁剪框
function initCropBox() {
  if (!cropImage.value || !cropOverlay.value || !cropBox.value) return;

  const img = cropImage.value;
  const overlay = cropOverlay.value;
  const box = cropBox.value;

  // 设置裁剪框初始位置和大小
  const imgRect = img.getBoundingClientRect();
  const overlayRect = overlay.getBoundingClientRect();

  // 计算适合120px高度的比例
  const targetHeight = 120;
  const aspectRatio = imgRect.width / imgRect.height;
  const targetWidth = targetHeight * aspectRatio;

  // 设置裁剪框大小（限制在图片范围内）
  const boxWidth = Math.min(targetWidth, imgRect.width * 0.8);
  const boxHeight = Math.min(targetHeight, imgRect.height * 0.8);

  box.style.width = `${boxWidth}px`;
  box.style.height = `${boxHeight}px`;
  box.style.left = `${(imgRect.width - boxWidth) / 2}px`;
  box.style.top = `${(imgRect.height - boxHeight) / 2}px`;

  // 添加拖拽功能
  let isDragging = false;
  let startX = 0;
  let startY = 0;
  let startLeft = 0;
  let startTop = 0;

  box.addEventListener('mousedown', e => {
    isDragging = true;
    startX = e.clientX;
    startY = e.clientY;
    startLeft = parseInt(box.style.left);
    startTop = parseInt(box.style.top);
    e.preventDefault();
  });

  document.addEventListener('mousemove', e => {
    if (!isDragging) return;

    const deltaX = e.clientX - startX;
    const deltaY = e.clientY - startY;

    let newLeft = startLeft + deltaX;
    let newTop = startTop + deltaY;

    // 限制在图片范围内
    newLeft = Math.max(0, Math.min(newLeft, imgRect.width - boxWidth));
    newTop = Math.max(0, Math.min(newTop, imgRect.height - boxHeight));

    box.style.left = `${newLeft}px`;
    box.style.top = `${newTop}px`;
  });

  document.addEventListener('mouseup', () => {
    isDragging = false;
  });
}

// 确认裁剪
async function confirmCrop() {
  if (!cropImage.value || !cropBox.value || !selectedFile.value) return;

  try {
    const img = cropImage.value;
    const box = cropBox.value;

    // 计算裁剪区域
    const imgRect = img.getBoundingClientRect();
    const boxRect = box.getBoundingClientRect();

    const scaleX = img.naturalWidth / imgRect.width;
    const scaleY = img.naturalHeight / imgRect.height;

    const cropX = (boxRect.left - imgRect.left) * scaleX;
    const cropY = (boxRect.top - imgRect.top) * scaleY;
    const cropWidth = boxRect.width * scaleX;
    const cropHeight = boxRect.height * scaleY;

    // 创建canvas进行裁剪
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    canvas.width = cropWidth;
    canvas.height = cropHeight;

    ctx.drawImage(img, cropX, cropY, cropWidth, cropHeight, 0, 0, cropWidth, cropHeight);

    // 转换为blob并上传
    canvas.toBlob(
      async blob => {
        try {
          const formData = new window.FormData();
          formData.append('file', blob, 'banner.jpg');

          const response = await window.fetch('/api/upload/image', {
            method: 'POST',
            body: formData,
          });

          if (!response.ok) throw new Error('上传失败');

          const result = await response.json();
          form.value.banner_image_url = result.url;
          showCropModal.value = false;
          Message.success('Banner 图片上传成功');
        } catch (err) {
          console.error('上传失败:', err);
          Message.error('上传失败');
        }
      },
      'image/jpeg',
      0.9
    );
  } catch (err) {
    console.error('裁剪失败:', err);
    Message.error('裁剪失败');
  }
}

// 删除banner
function removeBanner() {
  form.value.banner_image_url = '';
}

// 触发背景图文件选择
function triggerBackgroundFileInput() {
  backgroundFileInput.value?.click();
}

// 处理背景图文件选择
function handleBackgroundFileSelect(event) {
  const file = event.target.files[0];
  if (!file) return;

  // 检查文件大小（5MB限制）
  const maxSize = 5 * 1024 * 1024; // 5MB
  if (file.size > maxSize) {
    Message.error('文件大小不能超过5MB');
    return;
  }

  // 检查图片分辨率
  const img = new window.Image();
  img.onload = function () {
    if (img.width < 1080 || img.height < 1080) {
      Message.error('图片分辨率至少需要1080x1080像素');
      return;
    }

    // 分辨率符合要求，直接上传
    uploadBackgroundImage(file);
  };
  img.onerror = function () {
    Message.error('图片格式不正确');
  };
  img.src = window.URL.createObjectURL(file);
}

// 上传背景图
async function uploadBackgroundImage(file) {
  try {
    const formData = new window.FormData();
    formData.append('file', file);

    const response = await window.fetch('/api/upload/image', {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      throw new Error('上传失败');
    }

    const result = await response.json();
    form.value.background_image_url = result.url;
    Message.success('背景图上传成功');
  } catch (err) {
    console.error('上传失败:', err);
    Message.error('背景图上传失败');
  }
}

// 删除背景图
function removeBackground() {
  form.value.background_image_url = '';
}

// 确认恢复默认设置
function confirmResetToDefault() {
  Modal.confirm({
    title: '确认恢复默认设置',
    content: '确定要恢复所有主页设置为默认值吗？此操作将覆盖当前的所有设置。',
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      resetToDefault();
    },
  });
}

// 恢复默认设置
async function resetToDefault() {
  try {
    // 从系统默认设置API获取默认值
    const response = await window.fetch('/api/system/defaults/category/homepage');
    if (!response.ok) {
      throw new Error('获取默认设置失败');
    }

    const defaults = await response.json();

    // 构建默认表单数据
    const defaultForm = {
      banner_image_url: '',
      background_image_url: '',
      show_music_player: false,
      music_url: '',
      show_live2d: false,
    };

    // 从API响应中提取默认值
    defaults.forEach(defaultItem => {
      if (defaultItem.key_name === 'default_banner_image') {
        defaultForm.banner_image_url = defaultItem.key_value || '';
      } else if (defaultItem.key_name === 'default_background_image') {
        defaultForm.background_image_url = defaultItem.key_value || '';
      } else if (defaultItem.key_name === 'default_show_music_player') {
        defaultForm.show_music_player = defaultItem.key_value === 'true';
      } else if (defaultItem.key_name === 'default_music_url') {
        defaultForm.music_url = defaultItem.key_value || '';
      } else if (defaultItem.key_name === 'default_show_live2d') {
        defaultForm.show_live2d = defaultItem.key_value === 'true';
      }
    });

    // 更新表单数据
    form.value = defaultForm;

    // 自动保存设置
    await save();

    Message.success('已恢复默认设置并保存');
  } catch (err) {
    console.error('恢复默认设置失败:', err);
    Message.error('恢复默认设置失败');
  }
}

onMounted(load);
</script>

<style scoped>
.page-container {
  max-width: 860px;
  margin: 0 auto;
  padding: 20px;
}
.mb-6 {
  margin-bottom: 1.5rem;
}
.ml-2 {
  margin-left: 0.5rem;
}

/* 表单水平布局优化 */
:deep(.ivu-form-item) {
  margin-bottom: 16px;
  display: flex;
  align-items: flex-start;
}

:deep(.ivu-form-item-label) {
  font-weight: 500;
  color: #333;
  text-align: right;
  padding-right: 10px;
  line-height: 32px;
  padding-top: 0;
  margin-top: 0;
  width: 140px !important;
  min-width: 140px !important;
  max-width: 140px !important;
  white-space: nowrap;
  overflow: visible;
}

:deep(.ivu-form-item-content) {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: flex-start;
  margin-left: 0;
  padding-left: 10px;
}

/* 输入框样式 */
:deep(.ivu-input) {
  border-radius: 6px;
  border: 1px solid #d7dde4;
  transition: all 0.3s ease;
}

:deep(.ivu-input:focus) {
  border-color: #2d8cf0;
  box-shadow: 0 0 0 2px rgba(45, 140, 240, 0.1);
}

/* Switch 组件对齐 */
:deep(.ivu-switch) {
  margin-top: 6px;
}

/* 按钮组特殊处理 */
:deep(.ivu-form-item:last-child) {
  margin-bottom: 0;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}

:deep(.ivu-form-item:last-child .ivu-form-item-content) {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 按钮组样式 */
.button-group {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
}

/* Banner 上传样式 */
.banner-upload-container {
  border: 2px dashed #d7dde4;
  border-radius: 6px;
  padding: 12px;
  text-align: center;
  background: #fafafa;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 0;
  padding-top: 12px;
  width: 100%;
}

/* 背景图上传样式 */
.background-upload-container {
  border: 2px dashed #d7dde4;
  border-radius: 6px;
  padding: 12px;
  text-align: center;
  background: #fafafa;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 0;
  padding-top: 12px;
  width: 100%;
}

.upload-area {
  cursor: pointer;
  padding: 8px;
  color: #657180;
  width: 100%;
}

.upload-area:hover {
  background: #f5f7fa;
  border-radius: 4px;
}

.upload-tip {
  font-size: 12px;
  color: #999;
  margin-top: 8px;
}

.banner-preview {
  position: relative;
  display: inline-block;
}

.banner-image {
  max-width: 100%;
  max-height: 200px;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.banner-actions {
  margin-top: 10px;
}

.banner-actions .ivu-btn {
  margin: 0 5px;
}

.background-preview {
  position: relative;
  display: inline-block;
}

.background-image {
  max-width: 100%;
  max-height: 200px;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.background-actions {
  margin-top: 10px;
}

.background-actions .ivu-btn {
  margin: 0 5px;
}

/* 裁剪模态框样式 */
.crop-container {
  text-align: center;
}

.crop-preview {
  position: relative;
  display: inline-block;
  margin-bottom: 20px;
}

.crop-preview img {
  max-width: 100%;
  max-height: 400px;
  border-radius: 4px;
}

.crop-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  cursor: crosshair;
}

.crop-box {
  position: absolute;
  border: 2px solid #2d8cf0;
  background: rgba(45, 140, 240, 0.1);
  cursor: move;
}

.crop-box::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border: 1px dashed rgba(255, 255, 255, 0.8);
}

.crop-info {
  color: #657180;
  font-size: 14px;
}

.crop-info p {
  margin: 5px 0;
}
</style>
