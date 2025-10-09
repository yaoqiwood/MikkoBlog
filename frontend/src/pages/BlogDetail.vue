<template>
  <div class="blog-detail-page" :style="{ '--bg-image': backgroundImageUrl }">
    <!-- 头部导航 - 与首页保持一致 -->
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

    <!-- 主要内容区域 -->
    <main class="main-content">
      <div class="content-layout">
        <!-- 左侧内容区域 -->
        <div class="content-wrapper">
          <!-- 返回按钮 -->
          <div class="back-section">
            <Button @click="goBack" type="text" class="back-btn">
              <Icon type="ios-arrow-back" />
              {{ backButtonText }}
            </Button>
          </div>

          <!-- 文章内容 -->
          <article v-if="loading" class="loading-container">
            <div class="loading-spinner"></div>
            <span>加载中...</span>
          </article>

          <article v-else-if="error" class="error-container">
            <div class="error-content">
              <Icon type="ios-warning" size="24" />
              <span>{{ error }}</span>
              <Button @click="loadBlogDetail" type="primary" size="small">重新加载</Button>
            </div>
          </article>

          <article v-else-if="blogDetail" class="article-content">
            <!-- 文章头部信息 -->
            <header class="article-header">
              <h1 class="article-title">{{ blogDetail.title }}</h1>
              <div class="article-meta">
                <div class="author-section">
                  <img
                    :src="getAuthorAvatar(blogDetail.user_avatar)"
                    :alt="blogDetail.user_nickname"
                    class="author-avatar"
                    @error="handleAvatarError"
                  />
                  <div class="author-info">
                    <div class="author-name">{{ getAuthorName(blogDetail.user_nickname) }}</div>
                    <div class="publish-info">
                      <span class="publish-time">{{ formatTime(blogDetail.created_at) }}</span>
                      <span class="read-time">阅读 {{ blogDetail.view_count || 0 }}</span>
                    </div>
                  </div>
                </div>
                <div class="article-actions">
                  <Button
                    @click="likeBlog"
                    :type="isLiked ? 'error' : 'default'"
                    size="small"
                    ghost
                  >
                    <Icon :type="isLiked ? 'ios-heart' : 'ios-heart-outline'" />
                    {{ blogDetail.like_count || 0 }}
                  </Button>
                  <Button @click="shareBlog" type="primary" size="small" ghost>
                    <Icon type="ios-share" />
                    分享
                  </Button>
                </div>
              </div>
            </header>

            <!-- 文章封面 -->
            <div v-if="blogDetail.cover_image_url" class="article-cover">
              <img :src="getFullUrl(blogDetail.cover_image_url)" :alt="blogDetail.title" />
            </div>

            <!-- 文章正文 -->
            <div class="article-body">
              <div class="article-text" v-html="parseMarkdown(blogDetail.content)"></div>
            </div>

            <!-- 文章标签 -->
            <div v-if="blogDetail.tags && blogDetail.tags.length > 0" class="article-tags">
              <span class="tags-label">标签：</span>
              <div class="tags-list">
                <span
                  v-for="tag in blogDetail.tags"
                  :key="tag.id"
                  class="tag-item"
                  :style="{ backgroundColor: tag.color }"
                >
                  {{ tag.name }}
                </span>
              </div>
            </div>

            <!-- 文章底部操作 -->
            <footer class="article-footer">
              <div class="footer-actions">
                <Button @click="likeBlog" :type="isLiked ? 'error' : 'default'" size="large">
                  <Icon :type="isLiked ? 'ios-heart' : 'ios-heart-outline'" />
                  {{ isLiked ? '已赞' : '点赞' }} ({{ blogDetail.like_count || 0 }})
                </Button>
                <Button @click="shareBlog" type="primary" size="large">
                  <Icon type="ios-share" />
                  分享文章
                </Button>
                <Button
                  @click="collectBlog"
                  :type="isCollected ? 'warning' : 'default'"
                  size="large"
                >
                  <Icon :type="isCollected ? 'ios-star' : 'ios-star-outline'" />
                  {{ isCollected ? '已收藏' : '收藏' }}
                </Button>
              </div>
            </footer>
          </article>
        </div>

        <!-- 右侧边栏 -->
        <aside class="sidebar">
          <div class="sidebar-content">
            <h3 class="sidebar-title">相关博文</h3>
            <div v-if="relatedPostsLoading" class="related-loading">
              <div class="loading-spinner"></div>
              <span>加载中...</span>
            </div>
            <div v-else-if="relatedPosts.length === 0" class="no-posts">
              <div class="no-posts-content">
                <Icon type="ios-book-outline" size="32" />
                <p>博主很懒，还未更新博客</p>
              </div>
            </div>
            <div v-else class="related-posts">
              <div
                v-for="post in relatedPosts"
                :key="post.id"
                class="related-post-item"
                @click="viewBlogDetail(post.id)"
              >
                <div v-if="post.cover_image_url" class="post-cover">
                  <img :src="getFullUrl(post.cover_image_url)" :alt="post.title" />
                </div>
                <div class="post-info">
                  <h4 class="post-title">{{ post.title }}</h4>
                  <p v-if="post.summary" class="post-summary">{{ post.summary }}</p>
                  <div class="post-meta">
                    <span class="post-time">{{ formatTime(post.created_at) }}</span>
                    <span class="post-views">{{ post.view_count || 0 }} 阅读</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </aside>
      </div>
    </main>
  </div>
</template>

<script setup>
import { authApi, homepageApi, postApi, postStatsApi } from '@/utils/apiService';
import { marked } from 'marked';
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

// 返回按钮相关
const backUrl = ref('/');
const backButtonText = ref('返回首页');

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

// 工具方法
const getFullUrl = url => {
  if (!url) return '';
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }
  return url;
};

// 获取作者头像
const getAuthorAvatar = avatarUrl => {
  if (!avatarUrl) {
    // 如果没有头像，尝试使用用户资料中的头像
    const fallbackAvatar = userProfile.value.avatar;
    if (fallbackAvatar) {
      return getFullUrl(fallbackAvatar);
    }
    return 'https://via.placeholder.com/40x40/87ceeb/ffffff?text=A';
  }
  return getFullUrl(avatarUrl);
};

// 获取作者名称
const getAuthorName = nickname => {
  if (!nickname) {
    // 如果没有昵称，尝试使用用户资料中的昵称
    const fallbackName = userProfile.value.nickname;
    if (fallbackName) {
      return fallbackName;
    }
    return '匿名用户';
  }
  return nickname;
};

// 处理头像加载错误
const handleAvatarError = event => {
  event.target.src = 'https://via.placeholder.com/40x40/87ceeb/ffffff?text=A';
};

// 解析Markdown内容
const parseMarkdown = content => {
  if (!content) return '';

  try {
    // 配置marked选项
    marked.setOptions({
      breaks: true, // 支持换行
      gfm: true, // 支持GitHub风格的Markdown
    });

    return marked(content);
  } catch (error) {
    console.error('Markdown解析失败:', error);
    return content; // 如果解析失败，返回原始内容
  }
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

    // 增加浏览量
    try {
      await postStatsApi.incrementViewCount(blogId);
      console.log('浏览量已增加');
    } catch (viewErr) {
      console.warn('增加浏览量失败:', viewErr);
      // 不影响主要功能，只记录警告
    }
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

  try {
    const parser = new window.DOMParser();
    const doc = parser.parseFromString(blogDetail.value.content, 'text/html');
    const headings = doc.querySelectorAll('h1, h2, h3, h4, h5, h6');

    tableOfContents.value = Array.from(headings).map((heading, index) => {
      const level = parseInt(heading.tagName.charAt(1));
      const text = heading.textContent.trim();
      heading.id = `heading-${index}`;
      return { level, text, index };
    });
  } catch (error) {
    console.warn('生成目录失败:', error);
    tableOfContents.value = [];
  }
};

// 加载相关文章
const loadRelatedPosts = async () => {
  if (!blogDetail.value) return;

  relatedPostsLoading.value = true;
  try {
    const posts = await postApi.getRelatedPosts(blogDetail.value.id, { limit: 5 });
    relatedPosts.value = posts;
  } catch (err) {
    console.error('加载相关文章失败:', err);
    relatedPosts.value = [];
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

// 返回上一页
const goBack = () => {
  // 如果有记录的返回URL，使用它；否则使用浏览器历史记录
  if (backUrl.value && backUrl.value !== '/') {
    router.push(backUrl.value);
  } else {
    // 使用浏览器历史记录返回
    router.go(-1);
  }
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

// 解析返回URL和按钮文本
const parseBackInfo = () => {
  const from = route.query.from;

  if (from) {
    // 从查询参数中获取来源页面
    backUrl.value = decodeURIComponent(from);

    // 根据来源页面设置按钮文本
    if (from.includes('/articles')) {
      backButtonText.value = '返回文章列表';
    } else if (from.includes('/blog') && from.includes('view=columns')) {
      backButtonText.value = '返回专栏';
    } else if (from.includes('/blog')) {
      backButtonText.value = '返回首页';
    } else {
      backButtonText.value = '返回上一页';
    }
  } else {
    // 如果没有来源信息，检查浏览器历史记录
    if (document.referrer) {
      try {
        const referrer = new window.URL(document.referrer);
        if (referrer.pathname.includes('/articles')) {
          backButtonText.value = '返回文章列表';
          backUrl.value = '/articles';
        } else if (referrer.pathname.includes('/blog')) {
          backButtonText.value = '返回首页';
          backUrl.value = '/blog';
        } else {
          backButtonText.value = '返回上一页';
          backUrl.value = '/';
        }
      } catch {
        // 如果URL解析失败，使用默认值
        backButtonText.value = '返回首页';
        backUrl.value = '/';
      }
    } else {
      // 默认返回首页
      backButtonText.value = '返回首页';
      backUrl.value = '/';
    }
  }
};

// 生命周期
onMounted(() => {
  parseBackInfo();
  loadUserProfile();
  loadHomepageSettings();
});
</script>

<style scoped>
.blog-detail-page {
  min-height: 100vh;
  font-family: 'Microsoft YaHei', sans-serif;
  position: relative;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  /* 使用CSS变量设置背景图，如果没有则使用默认渐变 */
  background-image: var(--bg-image, linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%));
}

/* 头部样式 - 与首页保持一致 */
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

.nav-item::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  transition: width 0.3s ease;
}

.nav-item:hover::after {
  width: 100%;
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

/* 主要内容区域 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}

.content-layout {
  display: flex;
  gap: 16px;
  align-items: flex-start;
}

.content-wrapper {
  flex: 1;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* 返回按钮 */
.back-section {
  padding: 16px 24px;
  border-bottom: 1px solid #e1e4e8;
  background: #f6f8fa;
}

.back-btn {
  color: #586069;
  font-size: 14px;
  padding: 0;
}

.back-btn:hover {
  color: #0366d6;
}

/* 加载和错误状态 */
.loading-container,
.error-container {
  padding: 60px 24px;
  text-align: center;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #e1e4e8;
  border-top: 2px solid #0366d6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.error-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  color: #d73a49;
}

/* 文章内容 */
.article-content {
  padding: 0;
}

/* 文章头部 */
.article-header {
  padding: 32px 24px 24px;
  border-bottom: 1px solid #e1e4e8;
}

.article-title {
  font-size: 32px;
  font-weight: 600;
  color: #24292e;
  line-height: 1.25;
  margin: 0 0 16px 0;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.author-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.author-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid #e1e4e8;
}

.author-info {
  display: flex;
  flex-direction: column;
}

.author-name {
  font-weight: 600;
  color: #24292e;
  font-size: 14px;
}

.publish-info {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #586069;
  margin-top: 2px;
}

.article-actions {
  display: flex;
  gap: 8px;
}

/* 文章封面 */
.article-cover {
  margin: 0;
}

.article-cover img {
  width: 100%;
  max-height: 400px;
  object-fit: cover;
  display: block;
}

/* 文章正文 */
.article-body {
  padding: 24px;
}

.article-text {
  line-height: 1.6;
  color: #24292e;
  font-size: 16px;
}

/* Markdown 内容样式 */
.article-text :deep(h1),
.article-text :deep(h2),
.article-text :deep(h3),
.article-text :deep(h4),
.article-text :deep(h5),
.article-text :deep(h6) {
  margin: 24px 0 16px 0;
  color: #24292e;
  font-weight: 600;
  line-height: 1.25;
}

.article-text :deep(h1) {
  font-size: 24px;
}
.article-text :deep(h2) {
  font-size: 20px;
}
.article-text :deep(h3) {
  font-size: 18px;
}
.article-text :deep(h4) {
  font-size: 16px;
}
.article-text :deep(h5) {
  font-size: 14px;
}
.article-text :deep(h6) {
  font-size: 12px;
}

.article-text :deep(p) {
  margin: 16px 0;
}

.article-text :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 6px;
  margin: 16px 0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.article-text :deep(blockquote) {
  border-left: 4px solid #0366d6;
  padding: 0 16px;
  margin: 16px 0;
  background: #f6f8fa;
  color: #586069;
  font-style: italic;
}

.article-text :deep(code) {
  background: #f6f8fa;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 85%;
  color: #d73a49;
}

.article-text :deep(pre) {
  background: #f6f8fa;
  padding: 16px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 16px 0;
  border: 1px solid #e1e4e8;
}

.article-text :deep(pre code) {
  background: transparent;
  padding: 0;
  color: #24292e;
}

.article-text :deep(ul),
.article-text :deep(ol) {
  margin: 16px 0;
  padding-left: 24px;
}

.article-text :deep(li) {
  margin: 4px 0;
}

.article-text :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0;
}

.article-text :deep(th),
.article-text :deep(td) {
  border: 1px solid #e1e4e8;
  padding: 8px 12px;
  text-align: left;
}

.article-text :deep(th) {
  background: #f6f8fa;
  font-weight: 600;
}

/* 文章标签 */
.article-tags {
  padding: 16px 24px;
  border-top: 1px solid #e1e4e8;
  background: #f6f8fa;
}

.tags-label {
  font-size: 14px;
  color: #586069;
  margin-right: 8px;
}

.tags-list {
  display: inline-flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-item {
  padding: 4px 8px;
  border-radius: 12px;
  color: white;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.tag-item:hover {
  transform: translateY(-1px);
}

/* 文章底部操作 */
.article-footer {
  padding: 24px;
  border-top: 1px solid #e1e4e8;
  background: #f6f8fa;
}

.footer-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

/* 右侧边栏 */
.sidebar {
  width: 300px;
  flex-shrink: 0;
}

.sidebar-content {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 20px;
  position: fixed;
  top: 84px; /* 头部高度 + padding */
  right: 100px; /* 减少与右侧边缘的距离 */
  width: 300px;
  max-height: calc(100vh - 84px - 48px); /* 视口高度 - 顶部 - 底部padding */
  overflow-y: auto;
}

.sidebar-title {
  font-size: 18px;
  font-weight: 600;
  color: #24292e;
  margin: 0 0 16px 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #f6f8fa;
}

/* 相关博文加载状态 */
.related-loading {
  text-align: center;
  padding: 20px 0;
  color: #586069;
}

.related-loading .loading-spinner {
  width: 20px;
  height: 20px;
  margin: 0 auto 8px;
}

/* 无博文状态 */
.no-posts {
  text-align: center;
  padding: 40px 20px;
  color: #586069;
}

.no-posts-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.no-posts-content p {
  margin: 0;
  font-size: 14px;
  color: #8b949e;
}

/* 相关博文列表 */
.related-posts {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.related-post-item {
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid #e1e4e8;
}

.related-post-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #0366d6;
}

.post-cover {
  width: 100%;
  height: 120px;
  overflow: hidden;
}

.post-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.related-post-item:hover .post-cover img {
  transform: scale(1.05);
}

.post-info {
  padding: 12px;
}

.post-title {
  font-size: 14px;
  font-weight: 600;
  color: #24292e;
  margin: 0 0 8px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-summary {
  font-size: 12px;
  color: #586069;
  margin: 0 0 8px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 11px;
  color: #8b949e;
}

.post-time {
  flex: 1;
}

.post-views {
  color: #0366d6;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .sidebar {
    width: 280px;
  }
}

@media (max-width: 768px) {
  .content-layout {
    flex-direction: column;
    gap: 12px;
  }

  .sidebar {
    width: 100%;
    order: -1; /* 在移动端将侧边栏放在顶部 */
  }

  .sidebar-content {
    position: static;
    padding: 16px;
    width: auto;
    max-height: none;
    right: auto;
    top: auto;
  }

  .main-content {
    padding: 16px;
  }

  .article-header {
    padding: 24px 16px 16px;
  }

  .article-title {
    font-size: 24px;
  }

  .article-meta {
    flex-direction: column;
    align-items: flex-start;
  }

  .article-body {
    padding: 16px;
  }

  .article-text {
    font-size: 15px;
  }

  .article-tags {
    padding: 12px 16px;
  }

  .article-footer {
    padding: 16px;
  }

  .footer-actions {
    flex-direction: column;
  }

  .related-posts {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 12px;
  }

  .related-post-item {
    margin-bottom: 0;
  }
}

@media (max-width: 480px) {
  .main-content {
    padding: 12px;
  }

  .article-title {
    font-size: 20px;
  }

  .article-body {
    padding: 12px;
  }

  .article-text {
    font-size: 14px;
  }
}
</style>
