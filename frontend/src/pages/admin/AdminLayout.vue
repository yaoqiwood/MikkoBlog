<template>
  <div class="admin-layout">
    <!-- 侧边栏 -->
    <div class="admin-sidebar" :class="{ collapsed: sidebarCollapsed }">
      <div class="sidebar-header">
        <div class="logo">
          <Icon type="ios-apps" size="32" color="#667eea" />
          <span class="logo-text" v-show="!sidebarCollapsed">MikkoBlog</span>
        </div>
        <Button
          type="text"
          :icon="sidebarCollapsed ? 'ios-arrow-forward' : 'ios-arrow-back'"
          @click="toggleSidebar"
          class="sidebar-toggle-btn"
        />
      </div>

      <div class="sidebar-menu">
        <div class="menu-section">
          <div class="menu-title" v-show="!sidebarCollapsed">系统管理</div>
          <div class="menu-items">
            <router-link
              to="/admin/dashboard"
              class="menu-item"
              :class="{ active: $route.path === '/admin/dashboard' }"
              :title="sidebarCollapsed ? '仪表盘' : ''"
            >
              <Icon type="ios-home" />
              <span v-show="!sidebarCollapsed">仪表盘</span>
            </router-link>
            <router-link
              to="/admin/users"
              class="menu-item"
              :class="{ active: $route.path === '/admin/users' }"
              :title="sidebarCollapsed ? '用户管理' : ''"
            >
              <Icon type="ios-people" />
              <span v-show="!sidebarCollapsed">用户管理</span>
            </router-link>
            <router-link
              to="/admin/posts"
              class="menu-item"
              :class="{ active: $route.path === '/admin/posts' }"
              :title="sidebarCollapsed ? '文章管理' : ''"
            >
              <Icon type="ios-document" />
              <span v-show="!sidebarCollapsed">文章管理</span>
            </router-link>
            <router-link
              to="/admin/comments"
              class="menu-item"
              :class="{ active: $route.path === '/admin/comments' }"
              :title="sidebarCollapsed ? '评论管理' : ''"
            >
              <Icon type="ios-chatbubbles" />
              <span v-show="!sidebarCollapsed">评论管理</span>
            </router-link>
            <router-link
              to="/admin/moments"
              class="menu-item"
              :class="{ active: $route.path === '/admin/moments' }"
              :title="sidebarCollapsed ? '说说管理' : ''"
            >
              <Icon type="ios-heart" />
              <span v-show="!sidebarCollapsed">说说管理</span>
            </router-link>
            <router-link
              to="/admin/columns"
              class="menu-item"
              :class="{ active: $route.path === '/admin/columns' }"
              :title="sidebarCollapsed ? '专栏管理' : ''"
            >
              <Icon type="ios-folder" />
              <span v-show="!sidebarCollapsed">专栏管理</span>
            </router-link>
            <router-link
              to="/admin/profile"
              class="menu-item"
              :class="{ active: $route.path === '/admin/profile' }"
              :title="sidebarCollapsed ? '个人信息' : ''"
            >
              <Icon type="ios-person" />
              <span v-show="!sidebarCollapsed">个人信息</span>
            </router-link>
            <router-link
              to="/admin/attachments"
              class="menu-item"
              :class="{ active: $route.path === '/admin/attachments' }"
              :title="sidebarCollapsed ? '附件管理' : ''"
            >
              <Icon type="ios-folder" />
              <span v-show="!sidebarCollapsed">附件管理</span>
            </router-link>
            <router-link
              to="/admin/homepage"
              class="menu-item"
              :class="{ active: $route.path === '/admin/homepage' }"
              :title="sidebarCollapsed ? '主页设置' : ''"
            >
              <Icon type="ios-color-palette" />
              <span v-show="!sidebarCollapsed">主页设置</span>
            </router-link>
            <router-link
              to="/admin/settings"
              class="menu-item"
              :class="{ active: $route.path === '/admin/settings' }"
              :title="sidebarCollapsed ? '系统设置' : ''"
            >
              <Icon type="ios-settings" />
              <span v-show="!sidebarCollapsed">系统设置</span>
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="admin-main">
      <!-- 顶部导航栏 -->
      <div class="admin-header">
        <div class="header-left">
          <div class="breadcrumb">
            <span class="breadcrumb-item">{{ currentPageTitle }}</span>
          </div>
        </div>

        <div class="header-right">
          <div class="user-info">
            <Icon type="ios-person" />
            <span>{{ userInfo.email || 'admin@example.com' }}</span>
          </div>
          <Button type="error" icon="ios-log-out" @click="logout" class="logout-btn">
            退出登录
          </Button>
        </div>
      </div>

      <!-- 标签页区域 -->
      <div class="admin-tabs" v-if="tabs.length > 0">
        <div class="tabs-container">
          <div
            v-for="tab in tabs"
            :key="tab.path"
            class="tab-item"
            :class="{
              active: activeTab === tab.path,
              'tab-draggable': tab.path !== '/admin/dashboard',
              'tab-dragging': draggedTab && draggedTab.path === tab.path,
            }"
            :draggable="tab.path !== '/admin/dashboard'"
            @click="switchTab(tab.path)"
            @dragstart="handleDragStart($event, tab)"
            @dragover="handleDragOver"
            @drop="handleDrop($event, tab)"
            @dragend="handleDragEnd"
          >
            <span class="tab-title">{{ tab.title }}</span>
            <Icon
              v-if="tab.closable"
              type="ios-close"
              class="tab-close"
              @click.stop="removeTab(tab.path)"
            />
          </div>
        </div>
      </div>

      <!-- 页面内容 -->
      <div class="admin-content" :class="{ 'moments-page': $route.path === '/admin/moments' }">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { authCookie } from '@/utils/cookieUtils';
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const router = useRouter();
const route = useRoute();
const sidebarCollapsed = ref(false);

// 用户信息
const userInfo = ref({
  email: 'admin@example.com',
  is_admin: true,
});

// 标签页相关
const tabs = ref([]);
const activeTab = ref('');
const draggedTab = ref(null);

// 页面标题映射
const pageTitles = {
  '/admin/dashboard': '仪表盘',
  '/admin/users': '用户管理',
  '/admin/comments': '评论管理',
  '/admin/posts': '文章管理',
  '/admin/moments': '说说管理',
  '/admin/columns': '专栏管理',
  '/admin/profile': '个人信息设置',
  '/admin/attachments': '附件管理',
  '/admin/settings': '系统设置',
  '/admin/system': '系统默认参数设置',
  '/admin/homepage': '主页设置',
};

// 当前页面标题
const currentPageTitle = computed(() => {
  // 如果是文章编辑页面，显示文章管理
  if (route.path.startsWith('/admin/posts/new') || route.path.startsWith('/admin/posts/edit/')) {
    return '文章管理';
  }

  return pageTitles[route.path] || '后台管理';
});

// 标签页管理函数
function addTab(path) {
  // 如果是文章编辑页面，不创建新标签，直接激活文章管理标签
  if (path.startsWith('/admin/posts/new') || path.startsWith('/admin/posts/edit/')) {
    // 查找文章管理标签
    const postsTab = tabs.value.find(tab => tab.path === '/admin/posts');
    if (postsTab) {
      activeTab.value = '/admin/posts';
      return;
    }
  }

  const title = pageTitles[path] || '未知页面';
  const existingTab = tabs.value.find(tab => tab.path === path);

  if (!existingTab) {
    tabs.value.push({
      path,
      title,
      closable: path !== '/admin/dashboard', // dashboard不可关闭
    });
    saveTabsToStorage();
  }

  activeTab.value = path;
}

// 保存标签到localStorage
function saveTabsToStorage() {
  localStorage.setItem('admin-tabs', JSON.stringify(tabs.value));
  localStorage.setItem('admin-active-tab', activeTab.value);
}

// 从localStorage加载标签
function loadTabsFromStorage() {
  try {
    const savedTabs = localStorage.getItem('admin-tabs');
    const savedActiveTab = localStorage.getItem('admin-active-tab');

    if (savedTabs) {
      const parsedTabs = JSON.parse(savedTabs);
      // 确保dashboard标签存在且在最前面
      const dashboardTab = parsedTabs.find(tab => tab.path === '/admin/dashboard');
      if (!dashboardTab) {
        parsedTabs.unshift({
          path: '/admin/dashboard',
          title: '仪表盘',
          closable: false,
        });
      } else {
        // 确保dashboard在最前面
        const otherTabs = parsedTabs.filter(tab => tab.path !== '/admin/dashboard');
        tabs.value = [dashboardTab, ...otherTabs];
        return;
      }
      tabs.value = parsedTabs;
    }

    if (savedActiveTab) {
      activeTab.value = savedActiveTab;
    }
  } catch (error) {
    console.error('加载标签失败:', error);
    // 如果加载失败，至少确保dashboard标签存在
    tabs.value = [
      {
        path: '/admin/dashboard',
        title: '仪表盘',
        closable: false,
      },
    ];
  }
}

// 拖拽相关函数
function handleDragStart(event, tab) {
  if (tab.path === '/admin/dashboard') return; // dashboard不可拖拽
  draggedTab.value = tab;
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('text/html', event.target.outerHTML);
}

function handleDragOver(event) {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
}

function handleDrop(event, targetTab) {
  event.preventDefault();

  if (
    !draggedTab.value ||
    draggedTab.value.path === '/admin/dashboard' ||
    targetTab.path === '/admin/dashboard'
  ) {
    return;
  }

  const draggedIndex = tabs.value.findIndex(tab => tab.path === draggedTab.value.path);
  const targetIndex = tabs.value.findIndex(tab => tab.path === targetTab.path);

  if (draggedIndex !== targetIndex) {
    // 移动标签
    const draggedTabData = tabs.value[draggedIndex];
    tabs.value.splice(draggedIndex, 1);
    tabs.value.splice(targetIndex, 0, draggedTabData);
    saveTabsToStorage();
  }

  draggedTab.value = null;
}

function handleDragEnd() {
  draggedTab.value = null;
}

function removeTab(path) {
  if (path === '/admin/dashboard') return; // dashboard不可关闭

  const index = tabs.value.findIndex(tab => tab.path === path);
  if (index > -1) {
    tabs.value.splice(index, 1);
    saveTabsToStorage();

    // 如果关闭的是当前活跃标签，切换到其他标签
    if (activeTab.value === path) {
      if (tabs.value.length > 0) {
        const newActiveTab = tabs.value[tabs.value.length - 1];
        activeTab.value = newActiveTab.path;
        router.push(newActiveTab.path);
      } else {
        // 如果没有标签了，跳转到dashboard
        router.push('/admin/dashboard');
      }
    }
  }
}

function switchTab(path) {
  activeTab.value = path;
  saveTabsToStorage();
  router.push(path);
}

// 切换侧边栏
function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value;
  // 保存状态到localStorage
  localStorage.setItem('sidebar-collapsed', sidebarCollapsed.value.toString());
}

// 退出登录
async function logout() {
  try {
    // 清除cookie
    authCookie.clearAuth();

    Message.success('已安全退出登录');

    // 跳转到登录页面
    routerUtils.navigateTo(router, ROUTES.LOGIN);
  } catch (error) {
    console.error('退出登录失败:', error);
    Message.error('退出登录失败');
  }
}

// 检查登录状态
function checkAuth() {
  const auth = authCookie.getAuth();
  if (!auth.token) {
    Message.warning('请先登录');
    routerUtils.navigateTo(router, ROUTES.LOGIN);
    return false;
  }

  // 更新用户信息
  if (auth.userInfo) {
    userInfo.value = auth.userInfo;
  }

  return true;
}

// 初始化标志
const isInitialized = ref(false);

// 监听路由变化
watch(
  () => route.path,
  newPath => {
    if (newPath.startsWith('/admin') && isInitialized.value) {
      addTab(newPath);
    }
  }
);

onMounted(() => {
  // 检查登录状态
  if (!checkAuth()) {
    return;
  }

  // 加载侧边栏状态
  const savedSidebarState = localStorage.getItem('sidebar-collapsed');
  if (savedSidebarState !== null) {
    sidebarCollapsed.value = savedSidebarState === 'true';
  }

  // 加载保存的标签
  loadTabsFromStorage();

  // 标记为已初始化
  isInitialized.value = true;

  // 如果直接访问 /admin，重定向到仪表盘
  if (route.path === '/admin') {
    router.replace('/admin/dashboard');
  } else {
    // 添加当前页面标签
    addTab(route.path);
  }
});
</script>

<style scoped>
.admin-layout {
  display: flex;
  height: 100vh;
  background: #f5f7fa;
}

/* 侧边栏样式 */
.admin-sidebar {
  width: 230px;
  background: white;
  border-right: 1px solid #e8eaec;
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
}

.admin-sidebar.collapsed {
  width: 64px;
}

.sidebar-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e8eaec;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100px;
  box-sizing: border-box;
}

.admin-sidebar.collapsed .sidebar-header {
  padding: 1rem;
  justify-content: center;
  flex-direction: column;
  gap: 0.5rem;
  height: 100px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.admin-sidebar.collapsed .logo {
  gap: 0;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2d3748;
  transition: opacity 0.3s ease;
}

.sidebar-toggle-btn {
  width: 32px;
  height: 32px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.sidebar-toggle-btn:hover {
  background: #f7fafc;
}

.admin-sidebar.collapsed .sidebar-toggle-btn {
  width: 28px;
  height: 28px;
  margin-top: 0.5rem;
}

.sidebar-menu {
  flex: 1;
  padding: 1rem 0;
  overflow-y: auto;
}

.menu-section {
  margin-bottom: 2rem;
}

.menu-title {
  padding: 0 1.5rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #718096;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  transition: opacity 0.3s ease;
}

.admin-sidebar.collapsed .menu-title {
  display: none;
}

.menu-items {
  display: flex;
  flex-direction: column;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1.5rem;
  color: #4a5568;
  text-decoration: none;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
  justify-content: flex-start;
  min-height: 48px;
}

.admin-sidebar.collapsed .menu-item {
  justify-content: center;
  padding: 0.75rem 0.5rem;
  position: relative;
  gap: 0;
}

.admin-sidebar.collapsed .menu-item .ivu-icon {
  font-size: 18px;
}

.admin-sidebar.collapsed .menu-item:hover::after {
  content: attr(title);
  position: absolute;
  left: 100%;
  top: 50%;
  transform: translateY(-50%);
  background: #2d3748;
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
  white-space: nowrap;
  z-index: 1000;
  margin-left: 0.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  pointer-events: none;
}

.menu-item:hover {
  background: #f7fafc;
  color: #2d3748;
}

.menu-item.active {
  background: #e6f3ff;
  color: #667eea;
  border-left-color: #667eea;
  font-weight: 600;
}

.menu-item span {
  font-size: 0.95rem;
}

/* 主内容区域 */
.admin-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 顶部导航栏 */
.admin-header {
  background: white;
  border-bottom: 1px solid #e8eaec;
  padding: 0 1.5rem;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sidebar-toggle {
  display: none;
}

.breadcrumb {
  font-size: 1.125rem;
  font-weight: 600;
  color: #2d3748;
}

.breadcrumb-item {
  color: #4a5568;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #4a5568;
  font-size: 0.9rem;
}

.logout-btn {
  height: 36px;
  padding: 0 1rem;
}

/* 标签页样式 */
.admin-tabs {
  background: white;
  border-bottom: 1px solid #e8eaec;
  padding: 0 1.5rem;
  position: relative;
}

.tabs-container {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  overflow-x: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.tabs-container::-webkit-scrollbar {
  display: none;
}

.tab-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #f7fafc;
  border: 1px solid #e8eaec;
  border-radius: 4px 4px 0 0;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  min-width: 80px;
  max-width: 200px;
  max-height: 35px;
}

.tab-item:hover {
  background: #edf2f7;
  border-color: #cbd5e0;
}

.tab-item.active {
  background: white;
  border-color: #667eea;
  border-bottom-color: white;
  color: #667eea;
  font-weight: 600;
  position: relative;
  z-index: 1;
}

.tab-draggable {
  cursor: move;
}

.tab-draggable:hover {
  cursor: move;
}

/*
  拖拽歪斜的效果就是在拖拽标签时，标签会有一个轻微的旋转和透明度变化。
  具体实现代码如下，就是 .tab-dragging 这个 class 的样式。
  这个 class 会在拖拽中的标签上动态添加。
*/
.tab-dragging {
  opacity: 0.5;
  transform: rotate(5deg); /* 拖拽时标签歪斜5度 */
}

.tab-title {
  font-size: 0.875rem;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tab-close {
  font-size: 0.75rem;
  color: #a0aec0;
  cursor: pointer;
  padding: 0.125rem;
  border-radius: 2px;
  transition: all 0.2s ease;
}

.tab-close:hover {
  color: #e53e3e;
  background: #fed7d7;
}

/* 页面内容 */
.admin-content {
  flex: 1;
  padding: 0;
  overflow-y: auto;
  background: #f5f7fa;
}

/* 为除说说管理外的其他管理页面添加20px间距 */
.admin-content:not(.moments-page) {
  padding: 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-sidebar {
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    z-index: 1000;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .admin-sidebar.open {
    transform: translateX(0);
  }

  .sidebar-toggle {
    display: block !important;
  }

  .admin-main {
    width: 100%;
  }

  .admin-header {
    padding: 0 1rem;
  }

  .admin-content {
    padding: 1rem;
  }

  .admin-tabs {
    padding: 0 10px;
  }

  .tab-item {
    min-width: 60px;
    max-width: 120px;
    padding: 0.375rem 0.75rem;
    max-height: 35px;
  }

  .tab-title {
    font-size: 0.8rem;
  }

  .header-right {
    gap: 0.5rem;
  }

  .user-info span {
    display: none;
  }
}

@media (max-width: 480px) {
  .admin-header {
    padding: 0 0.75rem;
  }

  .admin-content {
    padding: 0.75rem;
  }

  .breadcrumb {
    font-size: 1rem;
  }
}
</style>
