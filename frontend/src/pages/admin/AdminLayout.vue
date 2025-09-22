<template>
  <div class="admin-layout">
    <!-- 侧边栏 -->
    <div class="admin-sidebar">
      <div class="sidebar-header">
        <div class="logo">
          <Icon type="ios-apps" size="32" color="#667eea" />
          <span class="logo-text">MikkoBlog</span>
        </div>
      </div>

      <div class="sidebar-menu">
        <div class="menu-section">
          <div class="menu-title">系统管理</div>
          <div class="menu-items">
            <router-link
              to="/admin/dashboard"
              class="menu-item"
              :class="{ active: $route.path === '/admin/dashboard' }"
            >
              <Icon type="ios-home" />
              <span>仪表盘</span>
            </router-link>
            <router-link
              to="/admin/users"
              class="menu-item"
              :class="{ active: $route.path === '/admin/users' }"
            >
              <Icon type="ios-people" />
              <span>用户管理</span>
            </router-link>
            <router-link
              to="/admin/posts"
              class="menu-item"
              :class="{ active: $route.path === '/admin/posts' }"
            >
              <Icon type="ios-document" />
              <span>文章管理</span>
            </router-link>
            <router-link
              to="/admin/settings"
              class="menu-item"
              :class="{ active: $route.path === '/admin/settings' }"
            >
              <Icon type="ios-settings" />
              <span>系统设置</span>
            </router-link>
          </div>
        </div>

        <div class="menu-section">
          <div class="menu-title">工具</div>
          <div class="menu-items">
            <router-link
              to="/admin/test-viewui"
              class="menu-item"
              :class="{ active: $route.path === '/admin/test-viewui' }"
            >
              <Icon type="ios-flask" />
              <span>组件测试</span>
            </router-link>
            <router-link
              to="/admin/fullscreen-test"
              class="menu-item"
              :class="{ active: $route.path === '/admin/fullscreen-test' }"
            >
              <Icon type="ios-expand" />
              <span>全屏测试</span>
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
          <Button type="text" icon="ios-menu" @click="toggleSidebar" class="sidebar-toggle" />
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

      <!-- 页面内容 -->
      <div class="admin-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { authCookie } from '@/utils/cookieUtils';
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { computed, onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const router = useRouter();
const route = useRoute();
const sidebarCollapsed = ref(false);

// 用户信息
const userInfo = ref({
  email: 'admin@example.com',
  is_admin: true,
});

// 页面标题映射
const pageTitles = {
  '/admin/dashboard': '仪表盘',
  '/admin/users': '用户管理',
  '/admin/posts': '文章管理',
  '/admin/settings': '系统设置',
  '/admin/test-viewui': '组件测试',
  '/admin/fullscreen-test': '全屏测试',
};

// 当前页面标题
const currentPageTitle = computed(() => {
  return pageTitles[route.path] || '后台管理';
});

// 切换侧边栏
function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value;
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

onMounted(() => {
  // 检查登录状态
  if (!checkAuth()) {
    return;
  }

  // 如果直接访问 /admin，重定向到仪表盘
  if (route.path === '/admin') {
    router.replace('/admin/dashboard');
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
  width: 260px;
  background: white;
  border-right: 1px solid #e8eaec;
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
}

.sidebar-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e8eaec;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2d3748;
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

/* 页面内容 */
.admin-content {
  flex: 1;
  padding: 1.5rem;
  overflow-y: auto;
  background: #f5f7fa;
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
