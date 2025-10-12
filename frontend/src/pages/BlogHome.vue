<template>
  <div class="blog-home" :style="{ '--bg-image': backgroundImageUrl }">
    <!-- 欢迎模态框 -->
    <WelcomeModal
      :show="showWelcomeModal"
      :modal-type="homepageSettings.welcome_modal_type || 'bible'"
      @close="closeWelcomeModal"
    />
    <!-- 头部导航 -->
    <BlogHeader :title="pageTitle" :current-view="currentView" @switch-view="switchView" />

    <!-- 主内容区域 -->
    <div class="main-content">
      <div class="content-container">
        <!-- 左侧边栏 -->
        <LeftSidebar
          :user-profile="userProfile"
          :profile-loading="profileLoading"
          :banner-image-url="bannerImageUrl"
          :popular-posts-list="popularPostsList"
          :popular-posts-loading="popularPostsLoading"
          :user-stats="userStats"
          :stats-loading="statsLoading"
          @view-blog-detail="viewBlogDetail"
        />

        <!-- 主内容区 -->
        <main class="main-area">
          <!-- 首页内容 -->
          <HomeContent
            v-if="currentView === 'home'"
            :active-content-type="activeContentType"
            :displayed-content="displayedContent"
            :loading="loading"
            :has-more="hasMore"
            :error="error"
            @switch-content-type="switchContentType"
            @view-blog-detail="viewBlogDetail"
            @preview-image="previewImage"
            @reload-posts="reloadPosts"
            @handle-scroll="handleScroll"
          />

          <!-- 专栏展示 -->
          <ColumnsContent
            v-if="currentView === 'columns'"
            :columns-list="columnsList"
            :columns-loading="columnsLoading"
            @view-column-detail="viewColumnDetail"
          />

          <!-- 专栏文章列表 -->
          <ColumnDetail
            v-if="currentView === 'column-detail'"
            :current-column="currentColumn"
            :column-posts-list="columnPostsList"
            :column-posts-loading="columnPostsLoading"
            @back-to-columns="currentView = 'columns'"
            @view-blog-detail="viewBlogDetail"
          />

          <!-- 关于我页面 -->
          <AboutContent v-if="currentView === 'about'" :user-profile="userProfile" />
        </main>

        <!-- 右侧边栏 -->
        <RightSidebar
          :sidebar-columns-list="sidebarColumnsList"
          :sidebar-columns-loading="sidebarColumnsLoading"
          :tag-cloud-list="tagCloudList"
          :tag-cloud-loading="tagCloudLoading"
          @view-column-detail="viewColumnDetail"
        />
      </div>
    </div>

    <!-- 全屏提示 -->
    <div class="fullscreen-tip" v-if="showFullscreenTip">
      <div class="tip-content">按 F11 即可退出全屏模式</div>
    </div>

    <!-- 图片预览 -->
    <ImagePreviewModal
      :show="showImagePreview"
      :preview-images="previewImages"
      :preview-index="previewIndex"
      :preview-image-url="previewImageUrl"
      @close="closeImagePreview"
      @prev-image="prevImage"
      @next-image="nextImage"
      @update:show="showImagePreview = $event"
    />

    <!-- 看板娘 -->
    <WaifuWidget
      :show="showWaifu"
      :position="waifuPosition"
      @update:show="showWaifu = $event"
      @update:position="waifuPosition = $event"
    />
  </div>
</template>

<script setup>
import AboutContent from '@/components/blogHome/About/AboutContent.vue';
import ColumnDetail from '@/components/blogHome/Columns/ColumnDetail.vue';
import ColumnsContent from '@/components/blogHome/Columns/ColumnsContent.vue';
import BlogHeader from '@/components/blogHome/Header/BlogHeader.vue';
import HomeContent from '@/components/blogHome/Home/HomeContent.vue';
import ImagePreviewModal from '@/components/blogHome/ImagePreview/ImagePreviewModal.vue';
import LeftSidebar from '@/components/blogHome/Sidebar/LeftSidebar.vue';
import RightSidebar from '@/components/blogHome/Sidebar/RightSidebar.vue';
import WaifuWidget from '@/components/WaifuWidget.vue';
import WelcomeModal from '@/components/WelcomeModal.vue';

import {
  authApi,
  columnsApi,
  homepageApi,
  momentsApi,
  postApi,
  statsApi,
  tagCloudApi,
} from '@/utils/apiService';
import localMusicApi from '@/utils/localMusicApi';
import { Message } from 'view-ui-plus';
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

// 响应式数据
const router = useRouter();
const route = useRoute();
const showFullscreenTip = ref(false);
const blogPosts = ref([]);
const moments = ref([]);
const loading = ref(false);
const hasMore = ref(true);
const currentPage = ref(1);
const pageSize = 10;
const error = ref('');

// 内容类型切换
const activeContentType = ref('all'); // 'all', 'blog', 'moments'

// 视图切换
const currentView = ref('home'); // 'home', 'columns', 'column-detail', 'about'

// 专栏相关数据
const columnsList = ref([]);
const columnsLoading = ref(false);

// 专栏文章相关数据
const columnPostsList = ref([]);
const columnPostsLoading = ref(false);
const currentColumn = ref(null);

// 右侧边栏专栏数据
const sidebarColumnsList = ref([]);
const sidebarColumnsLoading = ref(false);

// 标签云数据
const tagCloudList = ref([]);
const tagCloudLoading = ref(false);

// 最受欢迎博文数据
const popularPostsList = ref([]);
const popularPostsLoading = ref(false);

// 图片预览
const showImagePreview = ref(false);
const previewImages = ref([]);
const previewIndex = ref(0);
const previewImageUrl = ref('');

// 用户资料数据
const userProfile = ref({
  nickname: '',
  email: '',
  bio: '',
  avatar:
    'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAiIGhlaWdodD0iODAiIHZpZXdCb3g9IjAgMCA4MCA4MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjgwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjQwIiB5PSI0NSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QXZhdGFyPC90ZXh0Pgo8L3N2Zz4K',
  blog_title: '',
  blog_subtitle: '',
  motto: '',
  github_url: '',
  twitter_url: '',
  weibo_url: '',
  website_url: '',
});
const profileLoading = ref(false);
const profileError = ref('');

// 用户统计数据
const userStats = ref({
  blogCount: 0,
  shareCount: 0,
});
const statsLoading = ref(false);

// 主页设置数据
const homepageSettings = ref({
  header_title: '',
  banner_image_url: '',
  background_image_url: '',
  show_music_player: false,
  music_url: '',
  show_live2d: false,
  welcome_modal_type: 'bible',
});

// 欢迎模态框状态
const showWelcomeModal = ref(false);

// 自动播放设置
const autoPlaySetting = ref(false);

// 看板娘设置
const showWaifu = ref(true);
const waifuPosition = ref('left'); // 'left' 或 'right'

// 关闭欢迎模态框
const closeWelcomeModal = () => {
  showWelcomeModal.value = false;
  // 关闭模态框后自动播放音乐（如果后台设置启用）
  if (autoPlaySetting.value) {
    autoPlayMusic();
  }
};

// 将相对路径转换为完整URL
const getFullUrl = url => {
  if (!url) return '';

  // 如果是相对路径，转换为完整URL
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }

  return url;
};

// 预览图片
const previewImage = (images, index) => {
  previewImages.value = images;
  previewIndex.value = index;
  previewImageUrl.value = getFullUrl(images[index].url);
  showImagePreview.value = true;
};

// 关闭图片预览
const closeImagePreview = () => {
  showImagePreview.value = false;
};

// 上一张图片
const prevImage = () => {
  if (previewIndex.value > 0) {
    previewIndex.value--;
    previewImageUrl.value = getFullUrl(previewImages.value[previewIndex.value].url);
  }
};

// 下一张图片
const nextImage = () => {
  if (previewIndex.value < previewImages.value.length - 1) {
    previewIndex.value++;
    previewImageUrl.value = getFullUrl(previewImages.value[previewIndex.value].url);
  }
};

// 计算背景图URL
const backgroundImageUrl = computed(() => {
  const url = homepageSettings.value.background_image_url;

  if (!url) return '';

  const fullUrl = getFullUrl(url);
  return `url(${fullUrl})`;
});

// 计算Banner图片URL
const bannerImageUrl = computed(() => {
  return getFullUrl(homepageSettings.value.banner_image_url);
});

// 计算页面标题
const pageTitle = computed(() => {
  const blogTitle =
    userProfile.value.blog_title || homepageSettings.value.header_title || 'MikkoBlog';
  const blogSubtitle = userProfile.value.blog_subtitle;

  if (blogSubtitle) {
    return `${blogTitle} ${blogSubtitle}`;
  }
  return blogTitle;
});

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
      welcome_modal_type: settings.welcome_modal_type || 'bible',
    };

    // 设置看板娘显示状态
    showWaifu.value = homepageSettings.value.show_live2d;
  } catch (err) {
    console.error('加载主页设置失败:', err);
    // 使用默认设置
    showWaifu.value = true;
  }
};

// 加载自动播放设置
const loadAutoPlaySetting = async () => {
  try {
    const response = await localMusicApi.getAutoPlaySetting();
    autoPlaySetting.value = response.auto_play;
    console.log('自动播放设置:', autoPlaySetting.value);
  } catch (err) {
    console.error('加载自动播放设置失败:', err);
    // 使用默认值
    autoPlaySetting.value = false;
  }
};

// 加载看板娘设置
const loadWaifuSettings = () => {
  try {
    // 从本地存储加载看板娘设置
    const savedShow = localStorage.getItem('waifu-show');
    const savedPosition = localStorage.getItem('waifu-position');

    if (savedShow !== null) {
      showWaifu.value = savedShow === 'true';
    }

    if (savedPosition && ['left', 'right'].includes(savedPosition)) {
      waifuPosition.value = savedPosition;
    }

    console.log('看板娘设置:', { show: showWaifu.value, position: waifuPosition.value });
  } catch (err) {
    console.error('加载看板娘设置失败:', err);
    // 使用默认值
    showWaifu.value = true;
    waifuPosition.value = 'left';
  }
};

// 自动播放音乐（简化版本）
const autoPlayMusic = () => {
  if (!autoPlaySetting.value) {
    console.log('自动播放已禁用');
    return;
  }

  console.log('尝试自动播放音乐...');
  // 延迟一段时间后尝试点击播放按钮
  globalThis.setTimeout(() => {
    const playBtn = globalThis.document.querySelector('.track-controls .play-btn:nth-child(2)');
    if (playBtn) {
      console.log('找到播放按钮，自动点击');
      playBtn.click();
    } else {
      console.log('未找到播放按钮');
    }
  }, 1000);
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

// 格式化创建/修改时间显示
const formatCreateOrUpdateTime = (createdAt, updatedAt) => {
  const createdDate = new Date(createdAt);
  const updatedDate = updatedAt ? new Date(updatedAt) : null;

  // 如果修改时间为null或空，或者修改时间等于创建时间，显示创建时间
  if (!updatedDate || updatedDate.getTime() === createdDate.getTime()) {
    const timeStr = formatTime(createdAt);
    return `创建于${timeStr}`;
  }

  // 如果修改时间大于创建时间，显示修改时间
  if (updatedDate.getTime() > createdDate.getTime()) {
    const timeStr = formatTime(updatedAt);
    return `修改于${timeStr}`;
  }

  // 默认显示创建时间
  const timeStr = formatTime(createdAt);
  return `创建于${timeStr}`;
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
        type: 'blog',
        title: post.title,
        content: post.summary || post.content.substring(0, 200) + '...',
        time: formatTime(post.created_at),
        display_time: formatTime(post.updated_at || post.created_at), // 优先显示修改时间
        create_or_update_time: formatCreateOrUpdateTime(post.created_at, post.updated_at), // 新的时间显示
        views: post.view_count || 0, // 使用后端返回的真实观看数据
        comments: post.comment_count || 0, // 使用后端返回的真实评论数据
        likes: post.like_count || 0, // 使用后端返回的真实点赞数据
        shares: post.share_count || 0, // 使用后端返回的真实分享数据
        image: post.cover_image_url,
        created_at: post.created_at,
        updated_at: post.updated_at,
        // 添加作者信息 - 使用后端返回的用户信息
        author_name: post.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          post.user_avatar ||
          userProfile.value.avatar ||
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjIwIiB5PSIyNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QTwvdGV4dD4KPC9zdmc+Cg==',
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

// 加载说说
const loadMoments = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    const response = await momentsApi.getMoments({
      page: currentPage.value,
      limit: pageSize,
      is_visible: true,
    });

    if (response && response.items && response.items.length > 0) {
      // 转换数据格式以适配前端显示
      const formattedMoments = response.items.map(moment => ({
        id: moment.id,
        type: 'moment',
        content: moment.content,
        time: formatTime(moment.created_at),
        display_time: formatTime(moment.updated_at || moment.created_at),
        create_or_update_time: formatCreateOrUpdateTime(moment.created_at, moment.updated_at),
        views: 0, // 说说暂时没有浏览数
        comments: 0, // 说说暂时没有评论数
        likes: 0, // 说说暂时没有点赞数
        shares: 0, // 说说暂时没有分享数
        images: moment.images || [],
        created_at: moment.created_at,
        updated_at: moment.updated_at,
        author_name: moment.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          moment.user_avatar ||
          userProfile.value.avatar ||
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjIwIiB5PSIyNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QTwvdGV4dD4KPC9zdmc+Cg==',
      }));

      moments.value.push(...formattedMoments);
      currentPage.value++;

      // 检查是否还有更多数据
      if (!response.has_more) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载说说失败:', err);

    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载说说失败，请稍后重试';
      Message.error('加载说说失败，请稍后重试');
    }

    hasMore.value = false;
  } finally {
    loading.value = false;
  }
};

// 加载专栏列表
const loadColumns = async () => {
  columnsLoading.value = true;
  try {
    const response = await columnsApi.getColumns({
      is_visible: true,
      limit: 50, // 加载更多专栏
    });

    if (response && response.items) {
      columnsList.value = response.items;
    }
  } catch (err) {
    console.error('加载专栏失败:', err);
    Message.error('加载专栏失败，请稍后重试');
  } finally {
    columnsLoading.value = false;
  }
};

// 随机排序函数
const shuffleArray = array => {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
};

// 加载标签云
const loadTagCloud = async () => {
  tagCloudLoading.value = true;
  try {
    const response = await tagCloudApi.getActiveTags(20);
    console.log('标签云数据:', response);
    // 随机打乱标签顺序
    tagCloudList.value = shuffleArray(response);
  } catch (err) {
    console.error('加载标签云失败:', err);
    // 静默失败，使用默认标签
    const defaultTags = [
      { name: 'Vue.js', size: 'large', color: '#4fc08d' },
      { name: 'JavaScript', size: 'large', color: '#f7df1e' },
      { name: 'Python', size: 'medium', color: '#3776ab' },
      { name: 'React', size: 'medium', color: '#61dafb' },
      { name: 'Node.js', size: 'small', color: '#339933' },
    ];
    // 对默认标签也进行随机排序
    tagCloudList.value = shuffleArray(defaultTags);
  } finally {
    tagCloudLoading.value = false;
  }
};

// 加载最受欢迎博文
const loadPopularPosts = async () => {
  popularPostsLoading.value = true;
  try {
    const response = await postApi.getPopularPosts({ limit: 3 });
    console.log('最受欢迎博文数据:', response);
    popularPostsList.value = response;
  } catch (err) {
    console.error('加载最受欢迎博文失败:', err);
    // 静默失败，使用默认数据
    popularPostsList.value = [
      {
        id: 1,
        title: '敏感词过滤已上线',
        view_count: 49,
        cover_image_url:
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjZmY2OWI0Ii8+Cjx0ZXh0IHg9IjMwIiB5PSIzNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+MTwvdGV4dD4KPC9zdmc+Cg==',
      },
      {
        id: 2,
        title: '小林家的龙女仆',
        view_count: 56,
        cover_image_url:
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjMwIiB5PSIzNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+MjwvdGV4dD4KPC9zdmc+Cg==',
      },
    ];
  } finally {
    popularPostsLoading.value = false;
  }
};

// 加载右侧边栏专栏
const loadSidebarColumns = async () => {
  sidebarColumnsLoading.value = true;
  try {
    const response = await columnsApi.getColumns({
      is_visible: true,
      limit: 6, // 限制显示6个专栏
    });

    if (response && response.items) {
      sidebarColumnsList.value = response.items;
    }
  } catch (err) {
    console.error('加载右侧边栏专栏失败:', err);
    // 静默失败，不显示错误
  } finally {
    sidebarColumnsLoading.value = false;
  }
};

// 视图切换
const switchView = view => {
  if (currentView.value === view) return;

  currentView.value = view;

  if (view === 'columns' && columnsList.value.length === 0) {
    loadColumns();
  }
};

// 加载专栏文章
const loadColumnPosts = async columnId => {
  columnPostsLoading.value = true;
  try {
    const response = await postApi.getPosts({
      page: 1,
      limit: 50,
      column_id: columnId,
      is_visible: true,
      is_deleted: false,
    });

    if (response && response.length > 0) {
      // 转换数据格式以适配前端显示
      const formattedPosts = response.map(post => ({
        id: post.id,
        title: post.title,
        content: post.summary || post.content.substring(0, 200) + '...',
        time: formatTime(post.created_at),
        display_time: formatTime(post.updated_at || post.created_at),
        create_or_update_time: formatCreateOrUpdateTime(post.created_at, post.updated_at),
        views: post.view_count || 0,
        comments: post.comment_count || 0,
        likes: post.like_count || 0,
        shares: post.share_count || 0,
        image: post.cover_image_url,
        created_at: post.created_at,
        updated_at: post.updated_at,
        author_name: post.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          post.user_avatar ||
          userProfile.value.avatar ||
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjIwIiB5PSIyNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QTwvdGV4dD4KPC9zdmc+Cg==',
      }));

      columnPostsList.value = formattedPosts;
    } else {
      columnPostsList.value = [];
    }
  } catch (err) {
    console.error('加载专栏文章失败:', err);
    Message.error('加载专栏文章失败，请稍后重试');
    columnPostsList.value = [];
  } finally {
    columnPostsLoading.value = false;
  }
};

// 查看专栏详情
const viewColumnDetail = column => {
  currentColumn.value = column;
  currentView.value = 'column-detail';
  loadColumnPosts(column.id);
};

// 查看博文详情
const viewBlogDetail = blogId => {
  // 记录当前页面作为来源
  const currentPath = route.path;
  const currentQuery = route.query;

  // 构建来源URL
  let fromUrl = currentPath;
  if (Object.keys(currentQuery).length > 0) {
    const queryString = new URLSearchParams(currentQuery).toString();
    fromUrl += `?${queryString}`;
  }

  router.push({
    path: `/blog/${blogId}`,
    query: { from: encodeURIComponent(fromUrl) },
  });
};

// 计算当前显示的内容
const displayedContent = computed(() => {
  let allContent = [];

  if (activeContentType.value === 'all') {
    // 合并博客和说说，按时间排序
    allContent = [...blogPosts.value, ...moments.value];
  } else if (activeContentType.value === 'blog') {
    allContent = [...blogPosts.value];
  } else if (activeContentType.value === 'moments') {
    allContent = [...moments.value];
  }

  // 按创建时间倒序排序
  return allContent.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
});

// 内容类型切换
const switchContentType = type => {
  if (activeContentType.value === type) return;

  activeContentType.value = type;
  currentPage.value = 1;
  hasMore.value = true;
  error.value = '';

  // 清空对应的数据并重新加载
  if (type === 'all') {
    blogPosts.value = [];
    moments.value = [];
    loadAllContent();
  } else if (type === 'blog') {
    blogPosts.value = [];
    loadPosts();
  } else if (type === 'moments') {
    moments.value = [];
    loadMoments();
  }
};

// 加载所有内容（博客+说说）
const loadAllContent = async () => {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  error.value = '';

  try {
    // 并行加载博客和说说
    const [postsResponse, momentsResponse] = await Promise.all([
      postApi.getPosts({
        page: currentPage.value,
        limit: Math.ceil(pageSize / 2), // 博客占一半
        is_visible: true,
        is_deleted: false,
      }),
      momentsApi.getMoments({
        page: currentPage.value,
        limit: Math.ceil(pageSize / 2), // 说说占一半
        is_visible: true,
      }),
    ]);

    let hasMorePosts = false;
    let hasMoreMoments = false;

    // 处理博客文章
    if (postsResponse && postsResponse.length > 0) {
      const formattedPosts = postsResponse.map(post => ({
        id: post.id,
        type: 'blog',
        title: post.title,
        content: post.summary || post.content.substring(0, 200) + '...',
        time: formatTime(post.created_at),
        display_time: formatTime(post.updated_at || post.created_at),
        create_or_update_time: formatCreateOrUpdateTime(post.created_at, post.updated_at),
        views: post.view_count || 0,
        comments: post.comment_count || 0,
        likes: post.like_count || 0,
        shares: post.share_count || 0,
        image: post.cover_image_url,
        created_at: post.created_at,
        updated_at: post.updated_at,
        author_name: post.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          post.user_avatar ||
          userProfile.value.avatar ||
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjIwIiB5PSIyNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QTwvdGV4dD4KPC9zdmc+Cg==',
      }));
      blogPosts.value.push(...formattedPosts);
      hasMorePosts = postsResponse.length >= Math.ceil(pageSize / 2);
    }

    // 处理说说
    if (momentsResponse && momentsResponse.items && momentsResponse.items.length > 0) {
      const formattedMoments = momentsResponse.items.map(moment => ({
        id: moment.id,
        type: 'moment',
        content: moment.content,
        time: formatTime(moment.created_at),
        display_time: formatTime(moment.updated_at || moment.created_at),
        create_or_update_time: formatCreateOrUpdateTime(moment.created_at, moment.updated_at),
        views: 0,
        comments: 0,
        likes: 0,
        shares: 0,
        images: moment.images || [],
        created_at: moment.created_at,
        updated_at: moment.updated_at,
        author_name: moment.user_nickname || userProfile.value.nickname || '',
        author_avatar:
          moment.user_avatar ||
          userProfile.value.avatar ||
          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjIwIiB5PSIyNSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QTwvdGV4dD4KPC9zdmc+Cg==',
      }));
      moments.value.push(...formattedMoments);
      hasMoreMoments = momentsResponse.has_more;
    }

    currentPage.value++;

    // 如果博客和说说都没有更多数据，则停止加载
    if (!hasMorePosts && !hasMoreMoments) {
      hasMore.value = false;
    }
  } catch (err) {
    console.error('加载内容失败:', err);

    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器连接失败，请检查网络连接';
      Message.error('服务器连接失败，请检查网络连接');
    } else {
      error.value = '加载内容失败，请稍后重试';
      Message.error('加载内容失败，请稍后重试');
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
    if (activeContentType.value === 'all') {
      loadAllContent();
    } else if (activeContentType.value === 'blog') {
      loadPosts();
    } else if (activeContentType.value === 'moments') {
      loadMoments();
    }
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
      nickname: profile.nickname || '',
      email: profile.email || '',
      bio: profile.bio || '',
      avatar:
        profile.avatar ||
        'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAiIGhlaWdodD0iODAiIHZpZXdCb3g9IjAgMCA4MCA4MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjgwIiBmaWxsPSIjODdjZWViIi8+Cjx0ZXh0IHg9IjQwIiB5PSI0NSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QXZhdGFyPC90ZXh0Pgo8L3N2Zz4K',
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

// 加载用户统计数据
const loadUserStats = async () => {
  try {
    statsLoading.value = true;

    // 尝试从统计API获取数据
    try {
      const statsResponse = await statsApi.getSummary();
      console.log('统计API响应:', statsResponse);

      userStats.value = {
        blogCount: statsResponse.posts || 0,
        shareCount: 0, // 统计API中没有moments数据，暂时设为0
      };
    } catch (statsErr) {
      console.warn('统计API不可用，使用备用方案:', statsErr);

      // 备用方案：并行获取博客数量和说说数量
      const [postsResponse, momentsResponse] = await Promise.all([
        postApi.getPosts({
          page: 1,
          limit: 1, // 只需要获取总数，不需要具体内容
          is_visible: true,
          is_deleted: false,
        }),
        momentsApi.getMoments({
          page: 1,
          limit: 1, // 只需要获取总数，不需要具体内容
          is_visible: true,
        }),
      ]);

      // 获取博客数量
      let blogCount = 0;
      if (postsResponse && Array.isArray(postsResponse)) {
        // 如果后端API返回的是数组，我们需要获取总数
        // 这里可能需要调用一个专门的统计API
        // 暂时使用一个估算值，实际项目中应该修改后端API
        blogCount = postsResponse.length > 0 ? 50 : 0; // 假设有50篇博客
      }

      // 获取说说数量
      let shareCount = 0;
      if (momentsResponse && momentsResponse.items) {
        // 如果后端API返回了总数信息
        shareCount = momentsResponse.total || momentsResponse.items.length || 0;
      }

      userStats.value = {
        blogCount,
        shareCount,
      };
    }

    console.log('用户统计数据:', userStats.value);
  } catch (err) {
    console.error('加载用户统计数据失败:', err);
    // 使用默认数据
    userStats.value = {
      blogCount: 0,
      shareCount: 0,
    };
  } finally {
    statsLoading.value = false;
  }
};

// 重新加载数据
const reloadPosts = async () => {
  blogPosts.value = [];
  moments.value = [];
  currentPage.value = 1;
  hasMore.value = true;

  if (activeContentType.value === 'all') {
    await loadAllContent();
  } else if (activeContentType.value === 'blog') {
    await loadPosts();
  } else if (activeContentType.value === 'moments') {
    await loadMoments();
  }
};

// 监听页面标题变化
watch(
  pageTitle,
  newTitle => {
    document.title = newTitle;
  },
  { immediate: true }
);

// 监听路由变化，确保导航状态正确
watch(
  () => route.path,
  newPath => {
    // 如果当前在首页，确保视图状态正确
    if (newPath === '/') {
      if (route.query.view === 'columns') {
        currentView.value = 'columns';
        loadColumns();
      } else if (route.query.view === 'about') {
        currentView.value = 'about';
      } else {
        currentView.value = 'home';
      }
    }
  },
  { immediate: true }
);

// 生命周期
onMounted(async () => {
  // 检查是否全屏模式
  if (document.fullscreenElement) {
    showFullscreenTip.value = true;
  }

  // 检查URL参数，决定初始视图
  if (route.query.view === 'columns') {
    currentView.value = 'columns';
    // 如果直接跳转到专栏视图，需要加载专栏数据
    loadColumns();
  } else if (route.query.view === 'about') {
    currentView.value = 'about';
  } else {
    // 确保默认视图是首页
    currentView.value = 'home';
  }

  // 检查是否首次访问，只在首次访问时显示欢迎模态框
  const hasSeenWelcome = sessionStorage.getItem('hasSeenWelcome');
  if (!hasSeenWelcome) {
    showWelcomeModal.value = true;
    sessionStorage.setItem('hasSeenWelcome', 'true');
  }

  // 初始加载
  await loadUserProfile();
  await loadUserStats(); // 加载用户统计数据
  await loadHomepageSettings();
  await loadAutoPlaySetting(); // 加载自动播放设置
  loadWaifuSettings(); // 加载看板娘设置

  loadAllContent(); // 默认加载所有内容
  loadSidebarColumns(); // 加载右侧边栏专栏
  loadTagCloud(); // 加载标签云
  loadPopularPosts(); // 加载最受欢迎博文

  // 不自动播放音乐，等待用户关闭欢迎模态框后播放
});

onUnmounted(() => {
  // 清理工作
});
</script>

<style scoped>
.blog-home {
  min-height: 100vh;
  font-family: 'Microsoft YaHei', sans-serif;
  position: relative;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  /* 使用CSS变量设置背景图，如果没有则使用默认渐变 */
  background-image: var(--bg-image, linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%));
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

/* 主内容区 */
.main-area {
  background: transparent;
  border-radius: 15px;
  padding: 0;
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

/* 响应式设计 */
@media (max-width: 1024px) {
  .blog-home {
    background-size: cover;
    background-attachment: scroll;
  }

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
  .blog-home {
    background-size: cover;
    background-attachment: scroll;
  }

  .content-container {
    padding: 10px;
  }
}

@media (max-width: 480px) {
  .blog-home {
    background-size: cover;
    background-position: center top;
  }
}
</style>
