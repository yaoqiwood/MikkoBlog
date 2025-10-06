<template>
  <div class="blog-detail" :style="{ '--bg-image': backgroundImageUrl }">
    <!-- 头部导航 -->
    <header class="blog-header">
      <div class="header-container">
        <div class="blog-title">
          <h1>{{ homepageSettings.header_title || userProfile.blog_title || 'MikkoBlog' }}</h1>
        </div>
        <nav class="main-nav">
          <router-link to="/" class="nav-item">首页</router-link>
          <router-link to="/columns" class="nav-item">专栏</router-link>
          <a href="#" class="nav-item">关于我</a>
        </nav>
        <div class="search-box">
          <i class="search-icon">🔍</i>
        </div>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="main-content">
      <div class="content-container">
        <!-- 左侧边栏 -->
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
              <div v-if="profileLoading" class="profile-loading">
                <div class="loading-spinner"></div>
                <span>加载用户信息中...</span>
              </div>
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
                    <i class="contact-icon">✉️</i>
                    <span>{{ userProfile.email }}</span>
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
        </aside>

        <!-- 主内容区 -->
        <main class="main-area">
          <!-- 返回按钮 -->
          <div class="back-button">
            <Button @click="goBack" type="primary" ghost>
              <Icon type="ios-arrow-back" />
              返回首页
            </Button>
          </div>

          <!-- 博文详情内容 -->
          <div v-if="loading" class="loading-indicator">
            <div class="loading-spinner"></div>
            <span>加载中...</span>
          </div>

          <div v-else-if="error" class="error-message">
            <div class="error-content">
              <i class="error-icon">⚠️</i>
              <span>{{ error }}</span>
              <button @click="loadBlogDetail" class="retry-btn">重新加载</button>
            </div>
          </div>

          <article v-else-if="blogDetail" class="blog-detail-content">
            <!-- 博文头部 -->
            <header class="blog-header-info">
              <h1 class="blog-title">{{ blogDetail.title }}</h1>
              <div class="blog-meta">
                <div class="author-info">
                  <img
                    :src="getFullUrl(blogDetail.author_avatar)"
                    :alt="blogDetail.author_name"
                    class="author-avatar"
                  />
                  <div class="author-details">
                    <div class="author-name">{{ blogDetail.author_name }}</div>
                    <div class="publish-time">{{ formatTime(blogDetail.created_at) }}</div>
                  </div>
                </div>
                <div class="blog-stats">
                  <div class="stat-item">
                    <Icon type="ios-eye" />
                    <span>{{ blogDetail.view_count || 0 }}</span>
                  </div>
                  <div class="stat-item">
                    <Icon type="ios-chatbubbles" />
                    <span>{{ blogDetail.comment_count || 0 }}</span>
                  </div>
                  <div class="stat-item">
                    <Icon type="ios-heart" />
                    <span>{{ blogDetail.like_count || 0 }}</span>
                  </div>
                  <div class="stat-item">
                    <Icon type="ios-share" />
                    <span>{{ blogDetail.share_count || 0 }}</span>
                  </div>
                </div>
              </div>
            </header>

            <!-- 博文封面图 -->
            <div v-if="blogDetail.cover_image_url" class="blog-cover">
              <img :src="getFullUrl(blogDetail.cover_image_url)" :alt="blogDetail.title" />
            </div>

            <!-- 博文内容 -->
            <div class="blog-body">
              <div class="blog-content" v-html="blogDetail.content"></div>
            </div>

            <!-- 博文标签 -->
            <div v-if="blogDetail.tags && blogDetail.tags.length > 0" class="blog-tags">
              <h3>标签：</h3>
              <div class="tags-list">
                <span
                  v-for="tag in blogDetail.tags"
                  :key="tag.id"
                  class="tag"
                  :style="{ backgroundColor: tag.color }"
                >
                  {{ tag.name }}
                </span>
              </div>
            </div>

            <!-- 博文操作 -->
            <div class="blog-actions">
              <Button @click="likeBlog" :type="isLiked ? 'error' : 'default'" ghost>
                <Icon :type="isLiked ? 'ios-heart' : 'ios-heart-outline'" />
                {{ isLiked ? '已赞' : '点赞' }} ({{ blogDetail.like_count || 0 }})
              </Button>
              <Button @click="shareBlog" type="primary" ghost>
                <Icon type="ios-share" />
                分享
              </Button>
              <Button @click="collectBlog" :type="isCollected ? 'warning' : 'default'" ghost>
                <Icon :type="isCollected ? 'ios-star' : 'ios-star-outline'" />
                {{ isCollected ? '已收藏' : '收藏' }}
              </Button>
            </div>
          </article>
        </main>

        <!-- 右侧边栏 -->
        <aside class="right-sidebar">
          <!-- 目录 -->
          <div class="table-of-contents">
            <h3>📋 目录</h3>
            <div class="toc-content">
              <div class="toc-item" v-for="(heading, index) in tableOfContents" :key="index">
                <a :href="`#heading-${index}`" :class="`toc-level-${heading.level}`">
                  {{ heading.text }}
                </a>
              </div>
            </div>
          </div>

          <!-- 相关推荐 -->
          <div class="related-posts">
            <h3>📚 相关推荐</h3>
            <div v-if="relatedPostsLoading" class="related-loading">
              <div class="loading-spinner"></div>
              <span>加载中...</span>
            </div>
            <div v-else-if="relatedPosts.length === 0" class="empty-related">
              <p>暂无相关文章</p>
            </div>
            <div v-else class="related-list">
              <div
                v-for="post in relatedPosts"
                :key="post.id"
                class="related-item"
                @click="viewRelatedPost(post.id)"
              >
                <img
                  v-if="post.cover_image_url"
                  :src="getFullUrl(post.cover_image_url)"
                  :alt="post.title"
                />
                <div v-else class="default-cover">
                  <span>{{ post.title.charAt(0) }}</span>
                </div>
                <div class="related-info">
                  <h4 class="related-title">{{ post.title }}</h4>
                  <div class="related-stats">
                    <span class="stat-item">
                      <Icon type="ios-eye" />
                      {{ post.view_count || 0 }}
                    </span>
                    <span class="stat-item">
                      <Icon type="ios-chatbubbles" />
                      {{ post.comment_count || 0 }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </aside>
      </div>
    </div>
  </div>
</template>

<script setup>
import { authApi, homepageApi, postApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

// 响应式数据
const blogDetail = ref(null);
const loading = ref(false);
const error = ref('');
const isLiked = ref(false);
const isCollected = ref(false);
const tableOfContents = ref([]);
const relatedPosts = ref([]);
const relatedPostsLoading = ref(false);

// 用户资料数据
const userProfile = ref({
  nickname: '',
  email: '',
  bio: '',
  avatar: 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
  blog_title: '',
  blog_subtitle: '',
  motto: '',
  github_url: '',
  twitter_url: '',
  weibo_url: '',
  website_url: '',
});
const profileLoading = ref(false);

// 主页设置数据
const homepageSettings = ref({
  header_title: '',
  banner_image_url: '',
  background_image_url: '',
  show_music_player: false,
  music_url: '',
  show_live2d: false,
});

// 计算属性
const backgroundImageUrl = computed(() => {
  const url = homepageSettings.value.background_image_url;
  if (!url) return '';
  const fullUrl = getFullUrl(url);
  return `url(${fullUrl})`;
});

const bannerImageUrl = computed(() => {
  return getFullUrl(homepageSettings.value.banner_image_url);
});

// 工具方法
const getFullUrl = url => {
  if (!url) return '';
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }
  return url;
};

const formatTime = dateString => {
  const date = new Date(dateString);
  const now = new Date();
  const diffTime = Math.abs(now - date);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 1) return '1天前';
  if (diffDays < 7) return `${diffDays}天前`;
  if (diffDays < 30) return `${Math.ceil(diffDays / 7)}周前`;
  if (diffDays < 365) return `${Math.ceil(diffDays / 30)}个月前`;
  return `${Math.ceil(diffDays / 365)}年前`;
};

// 加载博文详情
const loadBlogDetail = async () => {
  const blogId = route.params.id;
  if (!blogId) {
    error.value = '博文ID不存在';
    return;
  }

  loading.value = true;
  error.value = '';

  try {
    const post = await postApi.getPostById(blogId);
    blogDetail.value = post;

    // 生成目录
    generateTableOfContents();

    // 加载相关文章
    loadRelatedPosts();
  } catch (err) {
    console.error('加载博文详情失败:', err);
    error.value = '加载博文详情失败，请稍后重试';
    Message.error('加载博文详情失败');
  } finally {
    loading.value = false;
  }
};

// 生成目录
const generateTableOfContents = () => {
  if (!blogDetail.value || !blogDetail.value.content) return;

  const parser = new DOMParser();
  const doc = parser.parseFromString(blogDetail.value.content, 'text/html');
  const headings = doc.querySelectorAll('h1, h2, h3, h4, h5, h6');

  tableOfContents.value = Array.from(headings).map((heading, index) => {
    const level = parseInt(heading.tagName.charAt(1));
    const text = heading.textContent.trim();
    heading.id = `heading-${index}`;
    return { level, text, index };
  });
};

// 加载相关文章
const loadRelatedPosts = async () => {
  if (!blogDetail.value) return;

  relatedPostsLoading.value = true;
  try {
    const posts = await postApi.getPosts({
      limit: 5,
      is_visible: true,
      is_deleted: false,
    });

    // 过滤掉当前文章
    relatedPosts.value = posts.filter(post => post.id !== blogDetail.value.id).slice(0, 4);
  } catch (err) {
    console.error('加载相关文章失败:', err);
  } finally {
    relatedPostsLoading.value = false;
  }
};

// 加载用户资料
const loadUserProfile = async () => {
  try {
    profileLoading.value = true;
    const userId = 1;
    const profile = await authApi.getPublicProfile(userId);
    userProfile.value = {
      nickname: profile.nickname || '',
      email: profile.email || '',
      bio: profile.bio || '',
      avatar: profile.avatar || 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
      blog_title: profile.blog_title || '',
      blog_subtitle: profile.blog_subtitle || '',
      motto: profile.motto || '',
      github_url: profile.github_url || '',
      twitter_url: profile.twitter_url || '',
      weibo_url: profile.weibo_url || '',
      website_url: profile.website_url || '',
    };
  } catch (err) {
    console.error('加载用户资料失败:', err);
  } finally {
    profileLoading.value = false;
  }
};

// 加载主页设置
const loadHomepageSettings = async () => {
  try {
    const settings = await homepageApi.getSettings();
    homepageSettings.value = {
      header_title: settings.header_title || '',
      banner_image_url: settings.banner_image_url || '',
      background_image_url: settings.background_image_url || '',
      show_music_player: !!settings.show_music_player,
      music_url: settings.music_url || '',
      show_live2d: !!settings.show_live2d,
    };
  } catch (err) {
    console.error('加载主页设置失败:', err);
  }
};

// 博文操作
const likeBlog = () => {
  isLiked.value = !isLiked.value;
  if (isLiked.value) {
    blogDetail.value.like_count = (blogDetail.value.like_count || 0) + 1;
    Message.success('点赞成功');
  } else {
    blogDetail.value.like_count = Math.max((blogDetail.value.like_count || 0) - 1, 0);
    Message.info('取消点赞');
  }
};

const shareBlog = () => {
  if (navigator.share) {
    navigator.share({
      title: blogDetail.value.title,
      text: blogDetail.value.summary || blogDetail.value.content.substring(0, 100),
      url: window.location.href,
    });
  } else {
    // 复制链接到剪贴板
    navigator.clipboard.writeText(window.location.href).then(() => {
      Message.success('链接已复制到剪贴板');
    });
  }
};

const collectBlog = () => {
  isCollected.value = !isCollected.value;
  Message.success(isCollected.value ? '收藏成功' : '取消收藏');
};

// 查看相关文章
const viewRelatedPost = postId => {
  router.push(`/blog/${postId}`);
};

// 返回首页
const goBack = () => {
  router.push('/');
};

// 监听路由变化
watch(
  () => route.params.id,
  newId => {
    if (newId) {
      loadBlogDetail();
    }
  },
  { immediate: true }
);

// 生命周期
onMounted(() => {
  loadUserProfile();
  loadHomepageSettings();
});
</script>

<style scoped>
.blog-detail {
  min-height: 100vh;
  font-family: 'Microsoft YaHei', sans-serif;
  position: relative;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-image: var(--bg-image, linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%));
}

/* 头部样式 */
.blog-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60px;
  position: relative;
}

.blog-title {
  position: absolute;
  left: 20px;
}

.blog-title h1 {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
}

.main-nav {
  display: flex;
  gap: 30px;
}

.nav-item {
  text-decoration: none;
  color: #333;
  font-weight: 500;
  transition: all 0.3s ease;
  position: relative;
}

.nav-item:hover {
  color: #ff6b6b;
  transform: translateY(-2px);
}

.search-box {
  position: absolute;
  right: 20px;
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.search-box:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.05);
}

/* 主内容区域 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.content-container {
  display: grid;
  grid-template-columns: 280px 1fr 280px;
  gap: 20px;
  align-items: start;
}

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

/* 主内容区 */
.main-area {
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  padding: 30px;
}

.back-button {
  margin-bottom: 20px;
}

/* 博文详情内容 */
.blog-detail-content {
  max-width: none;
}

.blog-header-info {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.blog-title {
  font-size: 32px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  line-height: 1.4;
}

.blog-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.author-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.author-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
}

.author-details {
  display: flex;
  flex-direction: column;
}

.author-name {
  font-weight: bold;
  color: #333;
  font-size: 16px;
}

.publish-time {
  color: #666;
  font-size: 14px;
}

.blog-stats {
  display: flex;
  gap: 20px;
}

.blog-stats .stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #666;
  font-size: 14px;
}

.blog-cover {
  margin: 30px 0;
  text-align: center;
}

.blog-cover img {
  max-width: 100%;
  max-height: 400px;
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.blog-body {
  margin: 30px 0;
}

.blog-content {
  line-height: 1.8;
  color: #333;
  font-size: 16px;
}

.blog-content :deep(h1),
.blog-content :deep(h2),
.blog-content :deep(h3),
.blog-content :deep(h4),
.blog-content :deep(h5),
.blog-content :deep(h6) {
  margin: 30px 0 15px 0;
  color: #333;
  font-weight: bold;
}

.blog-content :deep(h1) {
  font-size: 28px;
}
.blog-content :deep(h2) {
  font-size: 24px;
}
.blog-content :deep(h3) {
  font-size: 20px;
}
.blog-content :deep(h4) {
  font-size: 18px;
}
.blog-content :deep(h5) {
  font-size: 16px;
}
.blog-content :deep(h6) {
  font-size: 14px;
}

.blog-content :deep(p) {
  margin: 15px 0;
}

.blog-content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 15px 0;
}

.blog-content :deep(blockquote) {
  border-left: 4px solid #ff6b6b;
  padding-left: 20px;
  margin: 20px 0;
  background: #f8f9fa;
  padding: 15px 20px;
  border-radius: 0 8px 8px 0;
}

.blog-content :deep(code) {
  background: #f1f3f4;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 14px;
}

.blog-content :deep(pre) {
  background: #2d3748;
  color: #e2e8f0;
  padding: 20px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 20px 0;
}

.blog-content :deep(pre code) {
  background: transparent;
  padding: 0;
  color: inherit;
}

.blog-tags {
  margin: 30px 0;
  padding: 20px 0;
  border-top: 1px solid #eee;
}

.blog-tags h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.tag {
  padding: 6px 12px;
  border-radius: 20px;
  color: white;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tag:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.blog-actions {
  display: flex;
  gap: 15px;
  margin: 30px 0;
  padding: 20px 0;
  border-top: 1px solid #eee;
}

/* 右侧边栏 */
.right-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.table-of-contents,
.related-posts {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.table-of-contents h3,
.related-posts h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.toc-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.toc-item a {
  display: block;
  padding: 8px 12px;
  color: #666;
  text-decoration: none;
  border-radius: 6px;
  transition: all 0.3s ease;
  font-size: 14px;
}

.toc-item a:hover {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
}

.toc-level-1 {
  padding-left: 0;
}
.toc-level-2 {
  padding-left: 16px;
}
.toc-level-3 {
  padding-left: 32px;
}
.toc-level-4 {
  padding-left: 48px;
}
.toc-level-5 {
  padding-left: 64px;
}
.toc-level-6 {
  padding-left: 80px;
}

.related-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.related-item {
  display: flex;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 10px;
  border-radius: 8px;
}

.related-item:hover {
  background: rgba(255, 107, 107, 0.05);
  transform: translateX(5px);
}

.related-item img {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.default-cover {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  font-weight: bold;
}

.related-info {
  flex: 1;
}

.related-title {
  font-size: 14px;
  color: #333;
  margin: 0 0 8px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.related-stats {
  display: flex;
  gap: 10px;
}

.related-stats .stat-item {
  display: flex;
  align-items: center;
  gap: 3px;
  color: #999;
  font-size: 12px;
}

.related-loading,
.empty-related {
  text-align: center;
  padding: 20px;
  color: #999;
}

.empty-related p {
  margin: 0;
  font-size: 14px;
}

/* 加载状态 */
.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 60px 20px;
  color: #666;
  font-size: 16px;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #f0f0f0;
  border-top: 2px solid #ff6b6b;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 错误提示 */
.error-message {
  margin: 20px 0;
}

.error-content {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px 20px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 10px;
  color: #dc2626;
}

.error-icon {
  font-size: 18px;
}

.retry-btn {
  background: #dc2626;
  color: white;
  border: none;
  padding: 5px 15px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.3s ease;
}

.retry-btn:hover {
  background: #b91c1c;
  transform: translateY(-1px);
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

/* 响应式设计 */
@media (max-width: 1024px) {
  .content-container {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .left-sidebar,
  .right-sidebar {
    order: 2;
  }

  .main-area {
    order: 1;
  }
}

@media (max-width: 768px) {
  .header-container {
    flex-direction: column;
    height: auto;
    padding: 15px 20px;
  }

  .main-nav {
    margin: 10px 0;
  }

  .content-container {
    padding: 10px;
  }

  .main-area {
    padding: 20px;
  }

  .blog-title {
    font-size: 24px;
  }

  .blog-meta {
    flex-direction: column;
    align-items: flex-start;
  }

  .blog-actions {
    flex-direction: column;
  }
}
</style>
