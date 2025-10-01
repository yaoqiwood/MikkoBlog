<template>
  <div class="blog-home">
    <!-- 头部导航 -->
    <header class="blog-header">
      <div class="header-container">
        <div class="blog-title">
          <h1>{{ userProfile.blog_title }}</h1>
        </div>
        <nav class="main-nav">
          <a href="#" class="nav-item">首页</a>
          <a href="#" class="nav-item">归档</a>
          <a href="#" class="nav-item">友情链接</a>
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
              <img
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

          <!-- 音乐播放器 -->
          <div class="music-player">
            <div class="player-header">
              <h3>🎵 音乐播放器</h3>
            </div>
            <div class="current-track">
              <div class="track-info">
                <div class="track-title">風の住む街 - 磯村由纪子</div>
                <div class="track-controls">
                  <button class="play-btn">▶️</button>
                  <div class="progress-bar">
                    <div class="progress"></div>
                  </div>
                  <div class="time">00:00 / 04:45</div>
                  <button class="volume-btn">🔊</button>
                </div>
              </div>
            </div>
            <div class="playlist">
              <div class="playlist-item">風の住む街</div>
              <div class="playlist-item">ヨスガノソラメインテーマ - 記</div>
              <div class="playlist-item">蝶恋</div>
              <div class="playlist-item">月光の雲海</div>
            </div>
          </div>

          <!-- 最受欢迎 -->
          <div class="popular-posts">
            <h3>🌟 最受欢迎</h3>
            <div class="popular-list">
              <div class="popular-item">
                <img src="https://via.placeholder.com/60x60/ff69b4/ffffff?text=1" alt="Popular 1" />
                <div class="popular-info">
                  <div class="popular-title">敏感词过滤已上线</div>
                  <div class="popular-stats">49 浏览</div>
                </div>
              </div>
              <div class="popular-item">
                <img src="https://via.placeholder.com/60x60/87ceeb/ffffff?text=2" alt="Popular 2" />
                <div class="popular-info">
                  <div class="popular-title">小林家的龙女仆</div>
                  <div class="popular-stats">56 浏览</div>
                </div>
              </div>
            </div>
          </div>
        </aside>

        <!-- 主内容区 -->
        <main class="main-area">
          <div class="content-nav">
            <a href="#" class="content-nav-item active">全部</a>
            <a href="#" class="content-nav-item">博客</a>
            <a href="#" class="content-nav-item">说说</a>
          </div>
          <div class="posts-wrapper">
            <!-- 错误提示 -->
            <div v-if="error" class="error-message">
              <div class="error-content">
                <i class="error-icon">⚠️</i>
                <span>{{ error }}</span>
                <button @click="reloadPosts" class="retry-btn">重新加载</button>
              </div>
            </div>

            <div class="posts-container" @scroll="handleScroll">
              <!-- 博客文章列表 -->
              <article class="blog-post" v-for="(post, index) in blogPosts" :key="post.id">
                <div class="post-header">
                  <div class="post-avatar">
                    <img
                      src="https://via.placeholder.com/40x40/87ceeb/ffffff?text=S"
                      alt="Author"
                    />
                  </div>
                  <div class="post-meta">
                    <div class="author-name">Suyeq</div>
                    <div class="post-time">{{ post.time }}</div>
                  </div>
                </div>
                <div class="post-content">
                  <h3 class="post-title">{{ post.title }}</h3>
                  <p>{{ post.content }}</p>
                  <div v-if="post.image" class="post-image">
                    <img :src="post.image" :alt="post.title" />
                  </div>
                </div>
                <div class="post-stats">
                  <div class="stat-item">
                    <i class="stat-icon">👁️</i>
                    <span>{{ post.views }}</span>
                  </div>
                  <div class="stat-item">
                    <i class="stat-icon">💬</i>
                    <span>{{ post.comments }}</span>
                  </div>
                  <div class="stat-item">
                    <i class="stat-icon">👍</i>
                    <span>{{ post.likes }}</span>
                  </div>
                </div>
                <div v-if="index < blogPosts.length - 1" class="post-divider"></div>
              </article>

              <!-- 空状态 -->
              <div v-if="!loading && blogPosts.length === 0 && !error" class="empty-state">
                <div class="empty-content">
                  <i class="empty-icon">📝</i>
                  <h3>暂无文章</h3>
                  <p>还没有发布任何文章，请稍后再来查看</p>
                </div>
              </div>

              <!-- 加载状态 -->
              <div v-if="loading" class="loading-indicator">
                <div class="loading-spinner"></div>
                <span>加载中...</span>
              </div>

              <!-- 没有更多数据提示 -->
              <div v-if="!hasMore && blogPosts.length > 0" class="no-more-data">
                <span>没有更多内容了</span>
              </div>
            </div>
          </div>
        </main>

        <!-- 右侧边栏 -->
        <aside class="right-sidebar">
          <!-- 博主专栏 -->
          <div class="blogger-column">
            <h3>📚 博主专栏</h3>
            <div class="column-list">
              <div class="column-item">
                <img src="https://via.placeholder.com/80x80/ffb6c1/ffffff?text=Redis" alt="Redis" />
                <div class="column-title">Redis源码分析</div>
              </div>
              <div class="column-item">
                <img src="https://via.placeholder.com/80x80/98fb98/ffffff?text=Java" alt="Java" />
                <div class="column-title">Java源码分析</div>
              </div>
              <div class="column-item">
                <img
                  src="https://via.placeholder.com/80x80/ffa07a/ffffff?text=Tomcat"
                  alt="Tomcat"
                />
                <div class="column-title">Tomcat源码</div>
              </div>
            </div>
          </div>

          <!-- 标签云 -->
          <div class="tag-cloud">
            <h3>🏷️ 标签云</h3>
            <div class="tags">
              <span class="tag large">都是时辰的错!</span>
              <span class="tag medium">生化危机</span>
              <span class="tag small">java</span>
              <span class="tag medium">惊悚恐怖</span>
              <span class="tag small">LO</span>
              <span class="tag large">蕾姆</span>
              <span class="tag medium">二次元</span>
              <span class="tag small">游戏</span>
              <span class="tag medium">Tomcat</span>
              <span class="tag small">Redis</span>
              <span class="tag medium">寂静</span>
              <span class="tag small">Mysql</span>
              <span class="tag medium">开发</span>
              <span class="tag small">生</span>
            </div>
            <div class="tag-decoration">
              <img src="https://via.placeholder.com/100x100/ffb6c1/ffffff?text=Rem" alt="Rem" />
            </div>
          </div>

          <!-- 分类 -->
          <div class="categories">
            <h3>📂 分类</h3>
            <div class="category-list">
              <div class="category-item">默认分类</div>
            </div>
          </div>
        </aside>
      </div>
    </div>

    <!-- 全屏提示 -->
    <div class="fullscreen-tip" v-if="showFullscreenTip">
      <div class="tip-content">按 F11 即可退出全屏模式</div>
    </div>
  </div>
</template>

<script setup>
import { authApi, postApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';

// 响应式数据
const showFullscreenTip = ref(false);
const blogPosts = ref([]);
const loading = ref(false);
const hasMore = ref(true);
const currentPage = ref(1);
const pageSize = 10;
const error = ref('');

// 用户资料数据
const userProfile = ref({
  nickname: 'Suyeq',
  email: 'suyeq@example.com',
  bio: '',
  avatar: 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
  blog_title: '阑珊处',
  blog_subtitle: '一杯敬明天,一杯敬过往',
  motto: '一杯敬明天,一杯敬过往',
  github_url: '',
  twitter_url: '',
  weibo_url: '',
  website_url: '',
});
const profileLoading = ref(false);
const profileError = ref('');

// 格式化时间显示
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

// 从后端API加载博文
const loadPosts = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    // 调用后端API获取文章列表
    const posts = await postApi.getPosts({
      page: currentPage.value,
      limit: pageSize,
      is_visible: true, // 只获取可见的文章
      is_deleted: false, // 只获取未删除的文章
    });

    if (posts && posts.length > 0) {
      // 转换数据格式以适配前端显示
      const formattedPosts = posts.map(post => ({
        id: post.id,
        title: post.title,
        content: post.summary || post.content.substring(0, 200) + '...',
        time: formatTime(post.created_at),
        views: Math.floor(Math.random() * 100) + 10, // 临时使用随机数，后续可以从后端获取真实数据
        comments: post.comments?.length || 0,
        likes: Math.floor(Math.random() * 50) + 5, // 临时使用随机数，后续可以从后端获取真实数据
        image: post.cover_image_url,
        created_at: post.created_at,
        updated_at: post.updated_at,
      }));

      blogPosts.value.push(...formattedPosts);
      currentPage.value++;

      // 如果返回的文章数量少于页面大小，说明没有更多数据了
      if (posts.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载文章失败:', err);

    // 根据错误类型显示不同的错误信息
    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载文章失败，请稍后重试';
      Message.error('加载文章失败，请稍后重试');
    }

    hasMore.value = false;
  } finally {
    loading.value = false;
  }
};

// 滚动加载更多
const handleScroll = event => {
  const { scrollTop, scrollHeight, clientHeight } = event.target;
  const threshold = 100; // 距离底部100px时开始加载

  if (scrollHeight - scrollTop - clientHeight < threshold && hasMore.value && !loading.value) {
    loadPosts();
  }
};

// 加载用户资料
const loadUserProfile = async () => {
  try {
    profileLoading.value = true;
    profileError.value = '';

    // 假设用户ID为1，实际项目中可能需要从路由参数或其他方式获取
    const userId = 1;
    const profile = await authApi.getPublicProfile(userId);

    // 更新用户资料数据
    userProfile.value = {
      nickname: profile.nickname || 'Suyeq',
      email: profile.email || 'suyeq@example.com',
      bio: profile.bio || '',
      avatar: profile.avatar || 'https://via.placeholder.com/80x80/87ceeb/ffffff?text=Avatar',
      blog_title: profile.blog_title || '阑珊处',
      blog_subtitle: profile.blog_subtitle || '一杯敬明天,一杯敬过往',
      motto: profile.motto || '一杯敬明天,一杯敬过往',
      github_url: profile.github_url || '',
      twitter_url: profile.twitter_url || '',
      weibo_url: profile.weibo_url || '',
      website_url: profile.website_url || '',
    };
  } catch (err) {
    console.error('加载用户资料失败:', err);

    // 根据错误类型显示不同的错误信息
    if (err.type === 'NETWORK_ERROR') {
      profileError.value = '服务器连接失败，无法加载用户资料';
    } else {
      profileError.value = '加载用户资料失败，使用默认信息';
    }

    // 使用默认数据，不显示错误提示
    console.log('使用默认用户资料数据');
  } finally {
    profileLoading.value = false;
  }
};

// 重新加载数据
const reloadPosts = async () => {
  blogPosts.value = [];
  currentPage.value = 1;
  hasMore.value = true;
  await loadPosts();
};

// 生命周期
onMounted(() => {
  // 检查是否全屏模式
  if (document.fullscreenElement) {
    showFullscreenTip.value = true;
  }

  // 初始加载
  loadUserProfile();
  loadPosts();
});
</script>

<style scoped>
.blog-home {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  font-family: 'Microsoft YaHei', sans-serif;
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
  justify-content: space-between;
  height: 60px;
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

/* 音乐播放器 */
.music-player {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.player-header h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.track-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 10px;
}

.track-controls {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.play-btn {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-btn:hover {
  transform: scale(1.2);
}

.progress-bar {
  flex: 1;
  height: 4px;
  background: #eee;
  border-radius: 2px;
  overflow: hidden;
}

.progress {
  width: 30%;
  height: 100%;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 2px;
}

.time {
  font-size: 12px;
  color: #666;
}

.volume-btn {
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
}

.playlist {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.playlist-item {
  font-size: 12px;
  color: #666;
  padding: 5px 10px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.playlist-item:hover {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
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
  display: flex;
  gap: 10px;
  align-items: center;
}

.popular-item img {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
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

/* 主内容区 */
.main-area {
  background: transparent;
  border-radius: 15px;
  padding: 0;
}

/* 内容导航 */
.content-nav {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 10px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.content-nav-item {
  text-decoration: none;
  color: #666;
  font-size: 14px;
  padding: 8px 16px;
  border-radius: 20px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.content-nav-item.active,
.content-nav-item:hover {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.posts-wrapper {
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.posts-container {
  padding: 20px;
  padding-top: 5px;
  max-height: 910px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: #ff6b6b #f0f0f0;
}

.posts-container::-webkit-scrollbar {
  width: 6px;
}

.posts-container::-webkit-scrollbar-track {
  background: transparent;
  margin: 15px 0;
}

.posts-container::-webkit-scrollbar-thumb {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  border-radius: 3px;
  border: 1px solid white;
}

.posts-container::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(45deg, #ff5252, #26a69a);
}

.blog-post {
  padding: 20px 0;
  transition: all 0.3s ease;
}

.blog-post:hover {
  background: rgba(255, 107, 107, 0.02);
  border-radius: 10px;
  padding: 20px;
  margin: 0 -20px;
}

.blog-post:last-child {
  padding-bottom: 0;
}

.post-divider {
  height: 1px;
  background: linear-gradient(90deg, transparent, #eee, transparent);
  margin: 20px 0;
}

/* 加载状态 */
.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 20px;
  color: #666;
  font-size: 14px;
}

.loading-spinner {
  width: 20px;
  height: 20px;
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
  margin-bottom: 20px;
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

/* 空状态 */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-content {
  color: #666;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 15px;
  display: block;
}

.empty-content h3 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 18px;
}

.empty-content p {
  margin: 0;
  font-size: 14px;
  color: #666;
}

/* 文章标题样式 */
.post-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin: 0 0 10px 0;
  line-height: 1.4;
}

/* 没有更多数据提示 */
.no-more-data {
  text-align: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
  border-top: 1px solid #eee;
  margin-top: 10px;
}

.post-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.post-avatar img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.author-name {
  font-weight: bold;
  color: #333;
}

.post-time {
  font-size: 12px;
  color: #666;
}

.post-content {
  margin-bottom: 15px;
}

.post-content p {
  color: #333;
  line-height: 1.6;
  margin: 0 0 10px 0;
}

.post-image img {
  width: 100%;
  max-width: 400px;
  border-radius: 10px;
  margin-top: 10px;
}

.post-stats {
  display: flex;
  gap: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
}

.stat-item:hover {
  color: #ff6b6b;
  transform: translateY(-1px);
}

/* 右侧边栏 */
.right-sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.blogger-column,
.tag-cloud,
.categories {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.blogger-column h3,
.tag-cloud h3,
.categories h3 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.column-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.column-item {
  text-align: center;
}

.column-item img {
  width: 80px;
  height: 80px;
  border-radius: 10px;
  object-fit: cover;
  margin-bottom: 8px;
}

.column-title {
  font-size: 14px;
  color: #333;
}

/* 标签云 */
.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 15px;
}

.tag {
  padding: 5px 10px;
  border-radius: 15px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tag:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.tag.small {
  font-size: 11px;
  padding: 3px 8px;
}

.tag.medium {
  font-size: 13px;
  padding: 6px 12px;
}

.tag.large {
  font-size: 15px;
  padding: 8px 15px;
}

.tag-decoration {
  text-align: center;
}

.tag-decoration img {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  opacity: 0.8;
}

/* 分类 */
.category-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.category-item {
  padding: 10px 15px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  color: #333;
}

.category-item:hover {
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  color: white;
  transform: translateX(5px);
}

/* 全屏提示 */
.fullscreen-tip {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 15px 30px;
  border-radius: 10px;
  z-index: 9999;
  animation: fadeInOut 3s ease-in-out;
}

@keyframes fadeInOut {
  0%,
  100% {
    opacity: 0;
  }
  20%,
  80% {
    opacity: 1;
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
}
</style>
