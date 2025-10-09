<template>
  <aside class="left-sidebar">
    <!-- 用户信息卡片 -->
    <div class="user-card">
      <div class="profile-banner">
        <img v-if="bannerImageUrl" :src="bannerImageUrl" alt="Profile Banner" />
        <img
          v-else
          src="https://via.placeholder.com/300x120/ffb6c1/ffffff?text=Anime+Girl"
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
            <span class="stat-item">14 博客</span>
            <span class="stat-item">37 分享</span>
            <button class="share-btn">分享</button>
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
  </aside>
</template>

<script setup>
import MusicPlayer from '@/components/MusicPlayer.vue';

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
});

defineEmits(['viewBlogDetail']);
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
</style>
