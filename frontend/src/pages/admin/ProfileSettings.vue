<template>
  <div class="profile-settings">
    <div class="page-header">
      <h2>个人信息设置</h2>
      <p>管理您的个人资料和对外展示信息</p>
    </div>

    <div class="settings-container">
      <!-- 基本信息卡片 -->
      <div class="settings-card">
        <div class="card-header">
          <h3>基本信息</h3>
          <p>设置您的基本个人信息</p>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label for="nickname">昵称</label>
            <Input
              v-model="profileForm.nickname"
              placeholder="请输入您的昵称"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="email">邮箱</label>
            <Input
              v-model="profileForm.email"
              placeholder="请输入您的邮箱"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="bio">个人简介</label>
            <Input
              v-model="profileForm.bio"
              type="textarea"
              :rows="4"
              placeholder="介绍一下自己吧..."
              maxlength="200"
              show-word-limit
            />
          </div>
        </div>
      </div>

      <!-- 头像设置卡片 -->
      <div class="settings-card">
        <div class="card-header">
          <h3>头像设置</h3>
          <p>上传您的个人头像</p>
        </div>
        <div class="card-content">
          <div class="avatar-section">
            <div class="current-avatar">
              <img :src="getCurrentAvatar()" alt="当前头像" />
              <div class="avatar-overlay">
                <Icon type="ios-camera" size="24" />
                <span>点击更换</span>
              </div>
            </div>
            <div class="avatar-actions">
              <Upload
                ref="upload"
                :before-upload="handleAvatarUpload"
                :on-success="handleAvatarSuccess"
                :on-error="handleAvatarError"
                :show-upload-list="false"
                accept="image/*"
                :action="uploadAction"
                :headers="uploadHeaders"
              >
                <Button type="primary" icon="ios-cloud-upload-outline" class="avatar-btn">
                  选择头像
                </Button>
              </Upload>
              <Button @click="resetAvatar" class="avatar-btn"> 重置为默认 </Button>
            </div>
          </div>
        </div>
      </div>

      <!-- 社交信息卡片 -->
      <div class="settings-card">
        <div class="card-header">
          <h3>社交信息</h3>
          <p>设置您的社交媒体链接</p>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label for="github">
              <Icon type="logo-github" />
              GitHub
            </label>
            <Input
              v-model="profileForm.social.github"
              placeholder="https://github.com/yourusername"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="twitter">
              <Icon type="logo-twitter" />
              Twitter
            </label>
            <Input
              v-model="profileForm.social.twitter"
              placeholder="https://twitter.com/yourusername"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="weibo">
              <Icon type="ios-globe" />
              微博
            </label>
            <Input
              v-model="profileForm.social.weibo"
              placeholder="https://weibo.com/yourusername"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="website">
              <Icon type="ios-link" />
              个人网站
            </label>
            <Input
              v-model="profileForm.social.website"
              placeholder="https://yourwebsite.com"
              size="large"
              clearable
            />
          </div>
        </div>
      </div>

      <!-- 博客设置卡片 -->
      <div class="settings-card">
        <div class="card-header">
          <h3>博客设置</h3>
          <p>设置您的博客展示信息</p>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label for="blogTitle">博客标题</label>
            <Input
              v-model="profileForm.blogTitle"
              placeholder="请输入博客标题"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="blogSubtitle">博客副标题</label>
            <Input
              v-model="profileForm.blogSubtitle"
              placeholder="请输入博客副标题"
              size="large"
              clearable
            />
          </div>
          <div class="form-group">
            <label for="motto">个人格言</label>
            <Input
              v-model="profileForm.motto"
              placeholder="一句话介绍自己"
              size="large"
              clearable
            />
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <Button type="primary" size="large" :loading="saving" @click="saveProfile">
          {{ saving ? '保存中...' : '保存设置' }}
        </Button>
        <Button size="large" @click="resetForm" style="margin-left: 10px"> 重置 </Button>
      </div>
    </div>

    <!-- 重置头像确认对话框 -->
    <Modal v-model="showResetModal" title="确认重置头像" :mask-closable="false" :closable="false">
      <p>您确定要将头像重置为默认头像吗？</p>
      <p style="color: #999; font-size: 14px; margin-top: 10px">
        重置后，您的自定义头像将被清除，系统将使用默认头像。
      </p>
      <template #footer>
        <Button @click="showResetModal = false">取消</Button>
        <Button type="error" @click="confirmResetAvatar" :loading="resetting"> 确认重置 </Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { authApi, profileApi } from '@/utils/apiService';
import { authCookie } from '@/utils/cookieUtils';
import { Message } from 'view-ui-plus';
import { computed, onMounted, reactive, ref } from 'vue';

// 响应式数据
const saving = ref(false);
const resetting = ref(false);
const showResetModal = ref(false);
const defaultAvatar = ref(
  'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTUwIiBoZWlnaHQ9IjE1MCIgdmlld0JveD0iMCAwIDE1MCAxNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxNTAiIGhlaWdodD0iMTUwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9Ijc1IiB5PSI4MCIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjI0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QXZhdGFyPC90ZXh0Pgo8L3N2Zz4K'
);

// 上传配置
const uploadAction = computed(() => {
  return 'http://localhost:8000/api/upload/avatar';
});

const uploadHeaders = computed(() => {
  const auth = authCookie.getAuth();
  return {
    Authorization: `Bearer ${auth.token}`,
  };
});

// 表单数据
const profileForm = reactive({
  nickname: '',
  email: '',
  bio: '',
  avatar: '',
  blogTitle: '',
  blogSubtitle: '',
  motto: '',
  social: {
    github: '',
    twitter: '',
    weibo: '',
    website: '',
  },
});

// 原始数据备份
const originalData = ref({});

// 头像上传处理
const handleAvatarUpload = file => {
  const isImage = file.type.startsWith('image/');
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isImage) {
    Message.error('只能上传图片文件!');
    return false;
  }
  if (!isLt2M) {
    Message.error('图片大小不能超过 2MB!');
    return false;
  }

  // 创建预览URL
  if (typeof window.FileReader !== 'undefined') {
    const reader = new window.FileReader();
    reader.onload = e => {
      profileForm.avatar = e.target.result;
    };
    reader.readAsDataURL(file);
  }

  return true;
};

// 头像上传成功
const handleAvatarSuccess = response => {
  if (response.success) {
    profileForm.avatar = response.data.url;
    Message.success('头像上传成功!');
  } else {
    Message.error(response.message || '头像上传失败!');
  }
};

// 头像上传失败
const handleAvatarError = error => {
  console.error('头像上传失败:', error);
  Message.error('头像上传失败，请重试!');
};

// 获取当前头像
const getCurrentAvatar = () => {
  // 如果个人信息表中有头像，使用个人信息表的头像
  if (profileForm.avatar && profileForm.avatar.trim() !== '') {
    return profileForm.avatar;
  }
  // 否则使用系统默认头像
  return defaultAvatar.value;
};

// 重置头像（显示确认对话框）
const resetAvatar = () => {
  showResetModal.value = true;
};

// 确认重置头像
const confirmResetAvatar = async () => {
  resetting.value = true;
  try {
    await authApi.resetAvatar();
    profileForm.avatar = '';
    showResetModal.value = false;
    // 重新加载用户头像以获取最新的默认头像
    await loadUserAvatar();
    Message.success('头像已重置为默认头像!');
  } catch (error) {
    console.error('重置头像失败:', error);
    Message.error('重置头像失败，请重试!');
  } finally {
    resetting.value = false;
  }
};

// 保存个人资料
const saveProfile = async () => {
  saving.value = true;

  try {
    // 提交到后端 user_profiles
    await profileApi.updateMyProfile({
      nickname: profileForm.nickname,
      email: profileForm.email,
      bio: profileForm.bio,
      avatar: profileForm.avatar,
      blog_title: profileForm.blogTitle,
      blog_subtitle: profileForm.blogSubtitle,
      motto: profileForm.motto,
      github_url: profileForm.social.github,
      twitter_url: profileForm.social.twitter,
      weibo_url: profileForm.social.weibo,
      website_url: profileForm.social.website,
    });

    // 更新原始数据
    originalData.value = JSON.parse(JSON.stringify(profileForm));

    Message.success('个人资料保存成功!');
  } catch (error) {
    console.error('保存失败:', error);
    Message.error('保存失败，请重试!');
  } finally {
    saving.value = false;
  }
};

// 重置表单
const resetForm = () => {
  Object.assign(profileForm, originalData.value);
  Message.success('表单已重置!');
};

// 加载用户头像（智能获取）
const loadUserAvatar = async () => {
  try {
    const response = await authApi.getAvatar();
    if (response && response.avatar_url) {
      defaultAvatar.value = response.avatar_url;
    }
  } catch (error) {
    console.error('加载用户头像失败:', error);
    // 保持使用默认的占位符头像
  }
};

// 加载个人资料
const loadProfile = async () => {
  try {
    const response = await profileApi.getMyProfile();
    const data = response.data || response; // 兼容不同的响应格式
    const mapped = {
      nickname: data.nickname || '',
      email: data.email || '',
      bio: data.bio || '',
      avatar: data.avatar || '',
      blogTitle: data.blog_title || '',
      blogSubtitle: data.blog_subtitle || '',
      motto: data.motto || '',
      social: {
        github: data.github_url || '',
        twitter: data.twitter_url || '',
        weibo: data.weibo_url || '',
        website: data.website_url || '',
      },
    };
    Object.assign(profileForm, mapped);
    originalData.value = JSON.parse(JSON.stringify(mapped));
  } catch (error) {
    console.error('加载个人资料失败:', error);
    Message.error('加载个人资料失败!');
  }
};

// 生命周期
onMounted(async () => {
  await loadUserAvatar();
  await loadProfile();
});
</script>

<style scoped>
.profile-settings {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
  text-align: center;
}

.page-header h2 {
  font-size: 28px;
  color: #333;
  margin-bottom: 8px;
}

.page-header p {
  color: #666;
  font-size: 16px;
}

.settings-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.settings-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: all 0.3s ease;
}

.settings-card:hover {
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.card-header {
  padding: 20px 24px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 1px solid #e9ecef;
}

.card-header h3 {
  font-size: 18px;
  color: #333;
  margin: 0 0 4px 0;
  font-weight: 600;
}

.card-header p {
  color: #666;
  font-size: 14px;
  margin: 0;
}

.card-content {
  padding: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
  font-size: 14px;
}

/* 头像设置样式 */
.avatar-section {
  display: flex;
  align-items: center;
  gap: 24px;
}

.current-avatar {
  position: relative;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.current-avatar:hover {
  transform: scale(1.05);
}

.current-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  opacity: 0;
  transition: all 0.3s ease;
}

.current-avatar:hover .avatar-overlay {
  opacity: 1;
}

.avatar-overlay span {
  font-size: 12px;
  margin-top: 4px;
}

.avatar-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.avatar-btn {
  width: 120px;
  height: 36px;
  font-size: 14px;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: center;
  margin-top: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .profile-settings {
    padding: 15px;
  }

  .avatar-section {
    flex-direction: column;
    text-align: center;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .ivu-btn {
    margin-left: 0 !important;
    margin-top: 10px;
  }
}

/* 输入框样式增强 */
:deep(.ivu-input) {
  border-radius: 8px;
  border: 1px solid #d9d9d9;
  transition: all 0.3s ease;
}

:deep(.ivu-input:focus) {
  border-color: #ff6b6b;
  box-shadow: 0 0 0 2px rgba(255, 107, 107, 0.2);
}

:deep(.ivu-textarea) {
  border-radius: 8px;
  border: 1px solid #d9d9d9;
  transition: all 0.3s ease;
}

:deep(.ivu-textarea:focus) {
  border-color: #ff6b6b;
  box-shadow: 0 0 0 2px rgba(255, 107, 107, 0.2);
}

/* 按钮样式增强 */
:deep(.ivu-btn-primary) {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border: none;
  border-radius: 8px;
  transition: all 0.3s ease;
}

:deep(.ivu-btn-primary:hover) {
  background: linear-gradient(45deg, #ff5252, #26a69a);
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

:deep(.ivu-btn) {
  border-radius: 8px;
  transition: all 0.3s ease;
}

:deep(.ivu-btn:hover) {
  transform: translateY(-1px);
}
</style>
