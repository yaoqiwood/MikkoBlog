<template>
  <aside class="left-sidebar">
    <!-- 用户信息卡片 -->
    <div class="user-card">
      <div class="profile-banner">
        <img v-if="bannerImageUrl" :src="bannerImageUrl" alt="Profile Banner" />
        <img
          v-else
          src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjEyMCIgdmlld0JveD0iMCAwIDMwMCAxMjAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMTIwIiBmaWxsPSIjZmZiNmMxIi8+Cjx0ZXh0IHg9IjE1MCIgeT0iNjUiIGZvbnQtZmFtaWx5PSJBcmlhbCwgc2Fucy1zZXJpZiIgZm9udC1zaXplPSIxOCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkFuaW1lIEdpcmw8L3RleHQ+Cjwvc3ZnPgo="
          alt="Profile Banner"
        />
      </div>
      <div class="profile-info">
        <!-- 加载状态 -->
        <div v-if="profileLoading" class="profile-loading">
          <div class="loading-spinner"></div>
          <span>加载用户信息中...</span>
        </div>

        <!-- 用户信息内容 -->
        <div v-else>
          <div class="avatar">
            <img :src="userProfile.avatar" :alt="userProfile.nickname" />
          </div>
          <div class="username">@{{ userProfile.nickname }}</div>
          <div class="stats">
            <span class="stat-item">{{ userStats.blogCount }} 博客</span>
            <span class="stat-item">{{ userStats.shareCount }} 分享</span>
            <button class="share-btn" @click="showShareModal = true">分享</button>
          </div>
          <div class="contact-info">
            <div v-if="userProfile.email" class="contact-item">
              <span>E-mail: {{ userProfile.email }}</span>
            </div>
            <div v-if="userProfile.github_url" class="contact-item">
              <i class="contact-icon">🐙</i>
              <span>{{ userProfile.github_url }}</span>
            </div>
            <div v-if="userProfile.twitter_url" class="contact-item">
              <i class="contact-icon">🐦</i>
              <span>{{ userProfile.twitter_url }}</span>
            </div>
            <div v-if="userProfile.weibo_url" class="contact-item">
              <i class="contact-icon">🔴</i>
              <span>{{ userProfile.weibo_url }}</span>
            </div>
            <div v-if="userProfile.website_url" class="contact-item">
              <i class="contact-icon">🌐</i>
              <span>{{ userProfile.website_url }}</span>
            </div>
          </div>
          <div class="motto">
            <p>{{ userProfile.motto }}</p>
          </div>
        </div>
      </div>
    </div>
    <!-- 音乐播放器 -->
    <MusicPlayer ref="musicPlayerRef" />
    <!-- 最受欢迎 -->
    <div class="popular-posts">
      <h3>🌟 最受欢迎</h3>
      <div v-if="popularPostsLoading" class="popular-loading">
        <div class="loading-spinner"></div>
        <span>加载中...</span>
      </div>
      <div v-else class="popular-list">
        <div
          v-for="post in popularPostsList"
          :key="post.id"
          class="popular-item"
          @click="$emit('viewBlogDetail', post.id)"
        >
          <div class="popular-info">
            <div class="popular-title">{{ post.title }}</div>
            <div class="popular-stats">{{ post.view_count || 0 }} 浏览</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分享模态框 -->
    <Modal v-model="showShareModal" title="分享博客" width="400">
      <div class="share-modal-content">
        <div class="share-title">分享 {{ userProfile.nickname }} 的博客</div>
        <div class="share-url">
          <Input v-model="shareUrl" readonly>
            <template #append>
              <Button @click="copyToClipboard">复制</Button>
            </template>
          </Input>
        </div>
        <div class="share-platforms">
          <div class="platform-title">分享到：</div>
          <div class="platform-buttons">
            <button class="platform-btn wechat" @click="shareToWeChat">
              <i>💬</i>
              <span>微信</span>
            </button>
            <button class="platform-btn weibo" @click="shareToWeibo">
              <i>🔴</i>
              <span>微博</span>
            </button>
            <button class="platform-btn qq" @click="shareToQQ">
              <i>🐧</i>
              <span>QQ</span>
            </button>
            <button class="platform-btn twitter" @click="shareToTwitter">
              <i>🐦</i>
              <span>Twitter</span>
            </button>
            <button class="platform-btn facebook" @click="shareToFacebook">
              <i>📘</i>
              <span>Facebook</span>
            </button>
            <button class="platform-btn copy" @click="copyToClipboard">
              <i>📋</i>
              <span>复制链接</span>
            </button>
          </div>
        </div>
      </div>
    </Modal>
  </aside>
</template>

<script setup>
import MusicPlayer from '@/components/MusicPlayer.vue';
import { Button, Input, Message, Modal } from 'view-ui-plus';
import { computed, ref } from 'vue';

defineProps({
  userProfile: {
    type: Object,
    required: true,
  },
  profileLoading: {
    type: Boolean,
    default: false,
  },
  bannerImageUrl: {
    type: String,
    default: '',
  },
  popularPostsList: {
    type: Array,
    default: () => [],
  },
  popularPostsLoading: {
    type: Boolean,
    default: false,
  },
  userStats: {
    type: Object,
    default: () => ({
      blogCount: 0,
      shareCount: 0,
    }),
  },
  statsLoading: {
    type: Boolean,
    default: false,
  },
});

defineEmits(['viewBlogDetail']);

// 分享相关数据
const showShareModal = ref(false);
const shareUrl = computed(() => window.location.href);

// 分享功能
const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(shareUrl.value);
    Message.success('链接已复制到剪贴板');
  } catch (err) {
    // 备用方案
    const textArea = document.createElement('textarea');
    textArea.value = shareUrl.value;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    Message.success('链接已复制到剪贴板');
  }
};

const shareToWeChat = () => {
  // 微信分享需要特殊处理，这里提供基础实现
  const url = encodeURIComponent(shareUrl.value);
  const title = encodeURIComponent(`${userProfile.value.nickname} 的博客`);
  const desc = encodeURIComponent('来看看我的精彩博客内容！');

  // 微信分享链接格式
  const wechatUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${url}`;
  window.open(wechatUrl, '_blank');
  Message.info('请使用微信扫描二维码分享');
};

const shareToWeibo = () => {
  const url = encodeURIComponent(shareUrl.value);
  const title = encodeURIComponent(`${userProfile.value.nickname} 的博客`);
  const weiboUrl = `https://service.weibo.com/share/share.php?url=${url}&title=${title}`;
  window.open(weiboUrl, '_blank', 'width=600,height=400');
};

const shareToQQ = () => {
  const url = encodeURIComponent(shareUrl.value);
  const title = encodeURIComponent(`${userProfile.value.nickname} 的博客`);
  const qqUrl = `https://connect.qq.com/widget/shareqq/index.html?url=${url}&title=${title}`;
  window.open(qqUrl, '_blank', 'width=600,height=400');
};

const shareToTwitter = () => {
  const url = encodeURIComponent(shareUrl.value);
  const text = encodeURIComponent(`来看看 ${userProfile.value.nickname} 的精彩博客！`);
  const twitterUrl = `https://twitter.com/intent/tweet?url=${url}&text=${text}`;
  window.open(twitterUrl, '_blank', 'width=600,height=400');
};

const shareToFacebook = () => {
  const url = encodeURIComponent(shareUrl.value);
  const facebookUrl = `https://www.facebook.com/sharer/sharer.php?u=${url}`;
  window.open(facebookUrl, '_blank', 'width=600,height=400');
};
</script>

<style scoped>
/* 左侧边栏 */
.left-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.user-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.user-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}

.profile-banner img {
  width: 100%;
  height: 120px;
  object-fit: cover;
}

.profile-info {
  padding: 20px;
  text-align: center;
}

.avatar {
  margin: -40px auto 15px;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 4px solid white;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.username {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.stats {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-bottom: 15px;
}

.stat-item {
  font-size: 14px;
  color: #666;
}

.share-btn {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  border: none;
  padding: 5px 15px;
  border-radius: 15px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.share-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.contact-info {
  margin-bottom: 15px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.contact-icon {
  font-size: 16px;
}

.motto p {
  font-style: italic;
  color: #888;
  font-size: 14px;
  margin: 0;
}

/* 最受欢迎 */
.popular-posts {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  /* height: 328px; */
}

.popular-posts h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.popular-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.popular-item {
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.popular-item:hover {
  background: rgba(255, 107, 107, 0.05);
  transform: translateX(5px);
}

.popular-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 5px;
}

.popular-stats {
  font-size: 12px;
  color: #666;
}

/* 最受欢迎加载状态 */
.popular-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
}

.popular-loading .loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 8px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 用户资料加载状态 */
.profile-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #666;
}

.profile-loading .loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 10px;
}

.profile-loading span {
  font-size: 14px;
  color: #999;
}

/* 分享模态框样式 */
.share-modal-content {
  padding: 10px 0;
}

.share-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 15px;
  text-align: center;
}

.share-url {
  margin-bottom: 20px;
}

.share-platforms {
  margin-top: 20px;
}

.platform-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 15px;
  font-weight: 500;
}

.platform-buttons {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.platform-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: 12px 8px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 12px;
  color: #666;
}

.platform-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #ff6b6b;
}

.platform-btn i {
  font-size: 20px;
}

.platform-btn.wechat:hover {
  background: #07c160;
  color: white;
  border-color: #07c160;
}

.platform-btn.weibo:hover {
  background: #e6162d;
  color: white;
  border-color: #e6162d;
}

.platform-btn.qq:hover {
  background: #12b7f5;
  color: white;
  border-color: #12b7f5;
}

.platform-btn.twitter:hover {
  background: #1da1f2;
  color: white;
  border-color: #1da1f2;
}

.platform-btn.facebook:hover {
  background: #1877f2;
  color: white;
  border-color: #1877f2;
}

.platform-btn.copy:hover {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

/* 响应式设计 */
@media (max-width: 480px) {
  .platform-buttons {
    grid-template-columns: repeat(2, 1fr);
  }

  .platform-btn {
    padding: 10px 6px;
    font-size: 11px;
  }

  .platform-btn i {
    font-size: 18px;
  }
}
</style>
