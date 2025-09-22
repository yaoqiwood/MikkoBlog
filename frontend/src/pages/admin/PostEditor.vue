<template>
  <div class="post-editor">
    <div class="page-header">
      <h1 class="page-title">{{ isEdit ? '编辑文章' : '添加文章' }}</h1>
      <div class="page-actions">
        <Button @click="goBack">返回列表</Button>
        <Button type="primary" @click="savePost" :loading="saving">
          {{ isEdit ? '更新文章' : '发布文章' }}
        </Button>
      </div>
    </div>

    <!-- 错误提示 -->
    <Alert v-if="error" type="error" show-icon class="error-alert">
      {{ error }}
    </Alert>

    <!-- 文章编辑表单 -->
    <Card class="editor-card">
      <template #title>
        <div class="card-title">
          <Icon type="ios-document" />
          文章编辑
        </div>
      </template>

      <Form ref="postForm" :model="postData" :rules="postRules" label-position="top">
        <!-- 基本信息区域 -->
        <div class="basic-info-section">
          <Row :gutter="16">
            <Col :span="8">
              <FormItem label="文章标题" prop="title">
                <Input v-model="postData.title" placeholder="请输入文章标题" />
              </FormItem>
            </Col>
            <Col :span="8">
              <FormItem label="文章摘要">
                <Input
                  v-model="postData.summary"
                  type="textarea"
                  :rows="2"
                  placeholder="请输入文章摘要（可选）"
                />
              </FormItem>
            </Col>
            <Col :span="8">
              <FormItem label="封面图片">
                <div class="image-upload-container">
                  <Input
                    v-model="postData.cover_image_url"
                    placeholder="图片URL"
                    style="margin-bottom: 8px"
                  />
                  <Upload
                    :action="uploadAction"
                    :headers="uploadHeaders"
                    :on-success="handleImageUploadSuccess"
                    :on-error="handleImageUploadError"
                    :show-upload-list="false"
                    accept="image/*"
                  >
                    <Button size="small" icon="ios-cloud-upload">上传图片</Button>
                  </Upload>
                </div>
              </FormItem>
            </Col>
          </Row>

          <Row :gutter="16">
            <Col :span="24">
              <div class="publish-status">
                <Switch v-model="postData.is_published" />
                <span class="switch-label">{{ postData.is_published ? '已发布' : '草稿' }}</span>
              </div>
            </Col>
          </Row>
        </div>

        <!-- 分隔线 -->
        <Divider />

        <!-- 文章内容区域 -->
        <div class="content-section">
          <div class="editor-container">
            <label class="editor-label">Markdown 内容</label>
            <MarkdownEditor
              v-model="postData.content"
              height="calc(100vh - 300px)"
              placeholder="请输入文章内容..."
              @upload-image="handleImageUpload"
            />
          </div>
        </div>
      </Form>
    </Card>
  </div>
</template>

<script setup>
import MarkdownEditor from '@/components/MarkdownEditor.vue';
import { postApi, uploadApi } from '@/utils/apiService';
import { authCookie } from '@/utils/cookieUtils';
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const router = useRouter();
const route = useRoute();

// 页面状态
const isEdit = ref(false);
const saving = ref(false);
const error = ref('');

// 图片上传配置
const uploadAction = 'http://localhost:8000/api/upload/image';
const uploadHeaders = {
  Authorization: `Bearer ${authCookie.getAuth().token}`,
};

// 文章数据
const postData = ref({
  id: null,
  title: '',
  content: '',
  cover_image_url: '',
  summary: '',
  is_published: false,
});

// 表单验证规则
const postRules = {
  title: [
    { required: true, message: '请输入文章标题', trigger: 'blur' },
    { min: 2, message: '标题长度不能少于2位', trigger: 'blur' },
  ],
  content: [
    { required: true, message: '请输入文章内容', trigger: 'blur' },
    { min: 10, message: '内容长度不能少于10位', trigger: 'blur' },
  ],
};

// 处理图片上传
async function handleImageUpload(formData, callback) {
  try {
    console.log('开始上传图片...');
    const result = await uploadApi.uploadImage(formData);
    console.log('图片上传成功:', result);

    if (result.success && result.url) {
      // 将相对路径转换为完整URL
      const fullUrl = result.url.startsWith('http')
        ? result.url
        : `http://localhost:8000${result.url}`;
      // 调用回调函数，将图片URL插入到编辑器中
      callback(fullUrl);
      Message.success('图片上传成功');
    } else {
      callback('上传失败');
      Message.error('图片上传失败');
    }
  } catch (error) {
    console.error('图片上传失败:', error);
    callback('上传失败');
    Message.error('图片上传失败，请稍后重试');
  }
}

// 处理封面图片上传成功
function handleImageUploadSuccess(response, file) {
  console.log('封面图片上传成功:', response);
  if (response.success && response.url) {
    const fullUrl = response.url.startsWith('http')
      ? response.url
      : `http://localhost:8000${response.url}`;
    postData.value.cover_image_url = fullUrl;
    Message.success('封面图片上传成功');
  } else {
    Message.error('封面图片上传失败');
  }
}

// 处理封面图片上传失败
function handleImageUploadError(error, file) {
  console.error('封面图片上传失败:', error);
  Message.error('封面图片上传失败，请稍后重试');
}

// 保存文章
async function savePost() {
  try {
    saving.value = true;
    error.value = '';

    const data = {
      title: postData.value.title,
      content: postData.value.content,
      cover_image_url: postData.value.cover_image_url,
      summary: postData.value.summary,
      is_published: postData.value.is_published,
    };

    console.log('保存文章数据:', data);

    if (isEdit.value) {
      // 更新文章
      const result = await postApi.updatePost(postData.value.id, data);
      console.log('文章更新成功:', result);
      Message.success('文章更新成功');
    } else {
      // 创建文章
      const result = await postApi.createPost(data);
      console.log('文章创建成功:', result);
      Message.success('文章创建成功');
    }

    // 返回文章列表
    goBack();
  } catch (error) {
    console.error('保存文章失败:', error);
    console.error('错误详情:', error.response?.data);
    console.error('错误状态码:', error.response?.status);

    // 根据错误类型显示不同的提示
    if (error.response?.status === 400) {
      error.value = error.response.data.detail || '保存失败';
      Message.error(error.value);
    } else if (error.response?.status === 401) {
      error.value = '权限不足，请重新登录';
      Message.error(error.value);
      authCookie.clearAuth();
      routerUtils.navigateTo(router, ROUTES.LOGIN);
    } else if (error.response?.status === 404) {
      error.value = '文章不存在';
      Message.error(error.value);
    } else {
      error.value = '保存失败，请稍后重试';
      Message.error(error.value);
    }
  } finally {
    saving.value = false;
  }
}

// 返回文章列表
function goBack() {
  routerUtils.navigateTo(router, ROUTES.ADMIN_POSTS);
}

// 加载文章数据（编辑模式）
async function loadPost(postId) {
  try {
    console.log('加载文章数据:', postId);
    const result = await postApi.getPostById(postId);
    console.log('文章数据:', result);

    postData.value = {
      id: result.id,
      title: result.title,
      content: result.content,
      cover_image_url: result.cover_image_url || '',
      summary: result.summary || '',
      is_published: result.is_published,
    };
  } catch (error) {
    console.error('加载文章失败:', error);
    Message.error('加载文章失败');
    goBack();
  }
}

onMounted(() => {
  // 检查是否是编辑模式
  const postId = route.params.id;
  if (postId) {
    isEdit.value = true;
    loadPost(postId);
  }
});
</script>

<style scoped>
.post-editor {
  margin: 0 auto;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.page-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2d3748;
  margin: 0;
}

.page-actions {
  display: flex;
  gap: 0.75rem;
}

.error-alert {
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.editor-card {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.editor-card :deep(.ivu-card-body) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.basic-info-section {
  flex-shrink: 0;
  margin-bottom: 16px;
}

.content-section {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.image-upload-container {
  display: flex;
  flex-direction: column;
}

.publish-status {
  display: flex;
  align-items: center;
  padding: 8px 0;
}

.switch-label {
  margin-left: 8px;
  color: #666;
  font-size: 14px;
}

.editor-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.editor-label {
  font-size: 14px;
  color: #515a6e;
  margin-bottom: 8px;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .page-actions {
    justify-content: center;
  }

  .basic-info-section .ivu-col {
    margin-bottom: 16px;
  }
}
</style>
