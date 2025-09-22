import AdminLayout from '@/pages/admin/AdminLayout.vue';
import Dashboard from '@/pages/admin/Dashboard.vue';
import UserManagement from '@/pages/admin/UserManagement.vue';
import CookieTest from '@/pages/CookieTest.vue';
import FullscreenTest from '@/pages/FullscreenTest.vue';
import Home from '@/pages/Home.vue';
import LoadingTest from '@/pages/LoadingTest.vue';
import Login from '@/pages/Login.vue';
import NotFound from '@/pages/NotFound.vue';
import NotFoundDemo from '@/pages/NotFoundDemo.vue';
import Test404 from '@/pages/Test404.vue';
import TestViewUI from '@/pages/TestViewUI.vue';
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/login' },
    { path: '/login', name: 'login', component: Login },
    { path: '/home', name: 'home', component: Home },
    { path: '/cookie-test', name: 'cookie-test', component: CookieTest },
    { path: '/loading-test', name: 'loading-test', component: LoadingTest },

    // 后台管理嵌套路由
    {
      path: '/admin',
      component: AdminLayout,
      children: [
        { path: '', redirect: '/admin/dashboard' },
        { path: 'dashboard', name: 'admin-dashboard', component: Dashboard },
        { path: 'users', name: 'admin-users', component: UserManagement },
        {
          path: 'posts',
          name: 'admin-posts',
          component: () => import('@/pages/admin/PostManagement.vue'),
        },
        {
          path: 'settings',
          name: 'admin-settings',
          component: () => import('@/pages/admin/Settings.vue'),
        },
        { path: 'test-viewui', name: 'admin-test-viewui', component: TestViewUI },
        { path: 'fullscreen-test', name: 'admin-fullscreen-test', component: FullscreenTest },
      ],
    },

    // 旧的路由（保持兼容性）
    { path: '/test-viewui', name: 'test-viewui', component: TestViewUI },
    { path: '/test-404', name: 'test-404', component: Test404 },
    { path: '/404-demo', name: 'not-found-demo', component: NotFoundDemo },
    { path: '/fullscreen-test', name: 'fullscreen-test', component: FullscreenTest },

    // 404 页面 - 必须放在最后
    { path: '/404', name: 'not-found', component: NotFound },
    { path: '/:pathMatch(.*)*', name: 'catch-all', redirect: '/404' },
  ],
});

export default router;
