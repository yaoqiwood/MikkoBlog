<template>
  <div class="article-list-page" :style="{ '--bg-image': backgroundImageUrl }">
    <!-- 头部导航 -->
    <header class="blog-header">
      <div class="header-container">
        <div class="blog-title">
          <h1>{{ homepageSettings.header_title || userProfile.blog_title || 'MikkoBlog' }}</h1>
        </div>
        <nav class="main-nav">
          <router-link to="/blog" class="nav-item">首页</router-link>
          <a href="#" class="nav-item active">文章列表</a>
          <a href="#" class="nav-item" @click="goToColumns">专栏</a>
          <a href="#" class="nav-item" @click="goToAbout">关于我</a>
        </nav>
        <div class="search-box">
          <i class="search-icon">🔍</i>
        </div>
      </div>
    </header>

    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">📚 文章列表</h1>
        <p class="page-subtitle">探索所有精彩内容</p>
      </div>
    </div>

    <!-- 筛选器 -->
    <div class="filters-section">
      <div class="filters-container">
        <div class="filter-group">
          <label class="filter-label">📅 日期筛选</label>
          <div class="date-filters">
            <DatePicker
              v-model="dateRange"
              type="daterange"
              placeholder="选择日期范围"
              format="yyyy-MM-dd"
              clearable
            />
          </div>
        </div>

        <div class="filter-group">
          <label class="filter-label">🔍 标题搜索</label>
          <div class="search-input">
            <Input v-model="searchKeyword" placeholder="输入文章标题关键词" clearable>
              <template #prefix>
                <Icon type="ios-search" />
              </template>
            </Input>
          </div>
        </div>

        <div class="filter-group">
          <label class="filter-label">📂 专栏筛选</label>
          <div class="column-filter">
            <Select v-model="selectedColumn">
              <Option value="all">全部专栏</Option>
              <Option v-for="column in columnsList" :key="column.id" :value="column.id">
                {{ column.name }}
              </Option>
            </Select>
          </div>
        </div>

        <div class="filter-actions">
          <Button type="primary" @click="applyFilters" :loading="loading">
            <Icon type="ios-search" />
            筛选
          </Button>
          <Button @click="resetFilters">
            <Icon type="ios-refresh" />
            重置
          </Button>
        </div>
      </div>
    </div>

    <!-- 文章列表 -->
    <div class="articles-section">
      <div class="articles-container">
        <!-- 加载状态 -->
        <div v-if="loading && articlesList.length === 0" class="loading-state">
          <div class="loading-spinner"></div>
          <span>加载文章中...</span>
        </div>

        <!-- 文章列表表格 -->
        <div v-else-if="articlesList.length > 0" class="articles-table-container">
          <Table :data="articlesList" :columns="tableColumns" @on-row-click="viewArticle" stripe>
            <template #title="{ row }">
              <div class="article-title-cell">
                <div class="title-text" :title="row.title">
                  {{ row.title }}
                  <Icon type="ios-arrow-forward" size="14" class="title-icon" />
                </div>
              </div>
            </template>
            <template #summary="{ row }">
              <div class="summary-cell">
                <div class="summary-text">
                  {{ row.summary || getSummary(row.content) }}
                </div>
              </div>
            </template>
            <template #stats="{ row }">
              <div class="stats-cell">
                <span class="stat-item">
                  <Icon type="ios-eye" size="14" />
                  {{ row.view_count || 0 }}
                </span>
                <span class="stat-separator">|</span>
                <span class="stat-item">
                  <Icon type="ios-chatbubbles" size="14" />
                  {{ row.comment_count || 0 }}
                </span>
                <span class="stat-separator">|</span>
                <span class="stat-item">
                  <Icon type="ios-heart" size="14" />
                  {{ row.like_count || 0 }}
                </span>
              </div>
            </template>
            <template #column="{ row }">
              <div v-if="row.column_name" class="column-cell">
                <Icon type="ios-folder" size="14" />
                <span>{{ row.column_name }}</span>
              </div>
              <span v-else class="no-column">-</span>
            </template>
            <template #date="{ row }">
              <div class="date-cell">
                <Icon type="ios-calendar" size="14" />
                <span>{{ formatDate(row.created_at) }}</span>
              </div>
            </template>
          </Table>
        </div>

        <!-- 空状态 -->
        <div v-else class="empty-state">
          <Icon type="ios-document-outline" size="64" />
          <h3>暂无文章</h3>
          <p>没有找到符合条件的文章</p>
          <Button type="primary" @click="resetFilters">重置筛选条件</Button>
        </div>
      </div>

      <!-- 分页器 -->
      <div v-if="totalCount > 0" class="pagination-section">
        <Page
          :current="currentPage"
          :total="totalCount"
          :page-size="pageSize"
          :show-total="true"
          :show-sizer="true"
          :page-size-opts="[10, 20, 50]"
          @on-change="handlePageChange"
          @on-page-size-change="handlePageSizeChange"
          show-elevator
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { columnsApi, homepageApi, postApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { computed, onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

// 响应式数据
const articlesList = ref([]);
const columnsList = ref([]);
const loading = ref(false);

// 用户资料和主页设置数据
const userProfile = ref({
  blog_title: '',
});

const homepageSettings = ref({
  header_title: '',
  background_image_url: '',
});

// 筛选条件
const dateRange = ref([]);
const searchKeyword = ref('');
const selectedColumn = ref('all');

// 分页数据
const currentPage = ref(1);
const pageSize = ref(10);
const totalCount = ref(0);

// 表格列配置
const tableColumns = [
  {
    title: '标题',
    slot: 'title',
    minWidth: 250,
  },
  {
    title: '摘要',
    slot: 'summary',
    minWidth: 300,
  },
  {
    title: '专栏',
    slot: 'column',
    width: 120,
    align: 'center',
  },
  {
    title: '统计',
    slot: 'stats',
    width: 180,
    align: 'center',
  },
  {
    title: '发布时间',
    slot: 'date',
    width: 120,
    align: 'center',
  },
];

// 计算背景图URL
const backgroundImageUrl = computed(() => {
  const url = homepageSettings.value.background_image_url;
  if (!url) return '';
  const fullUrl = getFullImageUrl(url);
  return `url(${fullUrl})`;
});

// 获取完整图片URL
const getFullImageUrl = url => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return url; // 使用相对路径，让Nginx代理处理
};

// 获取文章摘要
const getSummary = content => {
  if (!content) return '';
  // 移除HTML标签
  const textContent = content.replace(/<[^>]*>/g, '');
  return textContent.length > 150 ? textContent.substring(0, 150) + '...' : textContent;
};

// 格式化日期
const formatDate = dateString => {
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
};

// 加载主页设置
const loadHomepageSettings = async () => {
  try {
    const settings = await homepageApi.getSettings();
    homepageSettings.value = {
      header_title: settings.header_title || '',
      background_image_url: settings.background_image_url || '',
    };
  } catch (err) {
    console.error('加载主页设置失败:', err);
  }
};

// 加载专栏列表
const loadColumns = async () => {
  try {
    const response = await columnsApi.getColumns({
      is_visible: true,
      limit: 100,
    });
    if (response && response.items) {
      columnsList.value = response.items;
    }
  } catch (err) {
    console.error('加载专栏失败:', err);
  }
};

// 加载文章列表
const loadArticles = async () => {
  loading.value = true;
  try {
    const params = {
      page: currentPage.value,
      limit: pageSize.value,
      is_visible: true,
      is_deleted: false,
    };

    // 添加筛选条件
    if (searchKeyword.value.trim()) {
      params.title = searchKeyword.value.trim();
    }

    if (selectedColumn.value && selectedColumn.value !== 'all') {
      params.column_id = selectedColumn.value;
    }

    if (dateRange.value && dateRange.value.length === 2) {
      params.start_date = dateRange.value[0];
      params.end_date = dateRange.value[1];
    }

    console.log('请求参数:', params);
    const response = await postApi.getPosts(params);
    console.log('API响应:', response);

    // 后端API直接返回数组格式
    if (response && Array.isArray(response)) {
      articlesList.value = response;
      // 由于后端API没有返回总数，这里使用一个估算值
      // 实际项目中应该修改后端API返回总数
      totalCount.value =
        response.length < pageSize.value
          ? (currentPage.value - 1) * pageSize.value + response.length
          : currentPage.value * pageSize.value + 1;
    } else {
      articlesList.value = [];
      totalCount.value = 0;
    }
  } catch (err) {
    console.error('加载文章失败:', err);
    Message.error('加载文章失败，请稍后重试');
    articlesList.value = [];
    totalCount.value = 0;
  } finally {
    loading.value = false;
  }
};

// 事件处理
const applyFilters = () => {
  currentPage.value = 1;
  loadArticles();
};

const resetFilters = () => {
  dateRange.value = [];
  searchKeyword.value = '';
  selectedColumn.value = 'all';
  currentPage.value = 1;
  loadArticles();
};

const handlePageChange = page => {
  currentPage.value = page;
  loadArticles();
};

const handlePageSizeChange = size => {
  pageSize.value = size;
  currentPage.value = 1;
  loadArticles();
};

const viewArticle = row => {
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
    path: `/blog/${row.id}`,
    query: { from: encodeURIComponent(fromUrl) },
  });
};

// 跳转到专栏页面
const goToColumns = () => {
  // 跳转到首页并传递参数，让首页自动切换到专栏视图
  router.push({ path: '/blog', query: { view: 'columns' } });
};

// 跳转到关于我页面
const goToAbout = () => {
  // 跳转到首页并传递参数，让首页自动切换到关于我视图
  router.push({ path: '/blog', query: { view: 'about' } });
};

// 生命周期
onMounted(() => {
  console.log('页面加载，selectedColumn初始值:', selectedColumn.value);
  loadHomepageSettings();
  loadColumns();
  loadArticles();
});
</script>

<style scoped>
.article-list-page {
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

.nav-item:hover,
.nav-item.active {
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

.nav-item:hover::after,
.nav-item.active::after {
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

/* 页面头部 */
.page-header {
  text-align: center;
  margin: 15px auto 20px;
  max-width: 1200px;
  padding: 0 20px;
}

.header-content {
  background: white;
  border-radius: 12px;
  padding: 25px 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.page-title {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(45deg, #667eea, #764ba2);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0 0 8px 0;
}

.page-subtitle {
  color: #666;
  font-size: 14px;
  margin: 0;
}

/* 筛选器 */
.filters-section {
  margin-bottom: 20px;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding: 0 20px;
}

.filters-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
  gap: 12px;
  align-items: end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-weight: 600;
  color: #333;
  font-size: 13px;
  white-space: nowrap;
}

.date-filters,
.search-input,
.column-filter {
  width: 100%;
}

.date-filters :deep(.ivu-date-picker) {
  width: 100%;
}

.date-filters :deep(.ivu-date-picker .ivu-input) {
  width: 100%;
}

.filter-actions {
  display: flex;
  gap: 8px;
  align-items: flex-end;
}

/* 文章列表 */
.articles-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.articles-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
  margin-bottom: 0;
}

/* 加载状态 */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #666;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #f0f0f0;
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 文章表格 */
.articles-table-container {
  overflow-x: auto;
}

.article-title-cell {
  max-width: 250px;
}

.title-text {
  font-weight: 600;
  color: #333;
  font-size: 14px;
  line-height: 1.4;
  cursor: pointer;
  transition: color 0.2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.title-text:hover {
  color: #667eea;
}

.title-icon {
  opacity: 0;
  transition: opacity 0.2s ease;
  color: #667eea;
}

.title-text:hover .title-icon {
  opacity: 1;
}

.summary-cell {
  max-width: 300px;
}

.summary-text {
  color: #666;
  font-size: 12px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.stats-cell {
  display: flex;
  flex-direction: row;
  gap: 8px;
  align-items: center;
  justify-content: center;
}

.stat-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #999;
  font-size: 12px;
}

.stat-separator {
  color: #ddd;
  font-size: 12px;
}

.column-cell {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #667eea;
  font-size: 12px;
  background: rgba(102, 126, 234, 0.1);
  padding: 4px 8px;
  border-radius: 12px;
  justify-content: center;
}

.no-column {
  color: #ccc;
  font-size: 12px;
}

.date-cell {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #999;
  font-size: 12px;
  justify-content: center;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 50px 20px;
  color: #999;
}

.empty-state i {
  margin-bottom: 20px;
  color: #ddd;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 20px;
}

.empty-state p {
  margin: 0 0 20px 0;
  font-size: 14px;
}

/* 分页器 */
.pagination-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px 20px;
  background: white;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.05);
  border-top: none;
  gap: 10px;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .page-header {
    margin: 10px auto 15px;
  }

  .filters-section {
    margin-bottom: 15px;
  }

  .article-title-cell {
    max-width: 250px;
  }
}

@media (max-width: 768px) {
  .article-list-page {
    padding: 0;
  }

  .header-container {
    flex-direction: column;
    height: auto;
    padding: 12px 15px;
  }

  .blog-title {
    position: static;
    margin-bottom: 8px;
  }

  .blog-title h1 {
    font-size: 20px;
  }

  .main-nav {
    margin: 8px 0;
    gap: 15px;
  }

  .search-box {
    position: static;
    margin-top: 8px;
  }

  .page-header {
    margin: 10px auto 12px;
    padding: 0 15px;
  }

  .header-content {
    padding: 20px 15px;
  }

  .page-title {
    font-size: 20px;
  }

  .filters-section {
    padding: 0 15px;
    margin-bottom: 12px;
  }

  .filters-container {
    grid-template-columns: 1fr;
    gap: 12px;
    padding: 15px;
  }

  .filter-actions {
    justify-content: center;
  }

  .articles-section {
    padding: 0 15px;
  }

  .articles-container {
    padding: 15px;
    margin-bottom: 12px;
  }

  .article-title-cell {
    max-width: 180px;
  }

  .summary-cell {
    max-width: 200px;
  }

  .pagination-section {
    padding: 12px;
  }
}

@media (max-width: 480px) {
  .header-container {
    padding: 10px 12px;
  }

  .blog-title h1 {
    font-size: 18px;
  }

  .main-nav {
    gap: 12px;
  }

  .page-header {
    padding: 0 12px;
  }

  .header-content {
    padding: 15px 12px;
  }

  .page-title {
    font-size: 18px;
  }

  .filters-section {
    padding: 0 12px;
  }

  .filters-container {
    padding: 12px;
  }

  .articles-section {
    padding: 0 12px;
  }

  .articles-container {
    padding: 12px;
  }

  .article-title-cell {
    max-width: 120px;
  }

  .summary-cell {
    max-width: 150px;
  }

  .title-text {
    font-size: 13px;
  }

  .summary-text {
    font-size: 11px;
  }

  .stat-item,
  .column-cell,
  .date-cell {
    font-size: 11px;
  }

  .pagination-section {
    padding: 10px;
  }
}
</style>
