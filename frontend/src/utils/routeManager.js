/**
 * 路由管理工具类
 * 统一管理所有路由路径和导航
 */

// 路由配置
const ROUTE_CONFIG = {
  // 基础路径
  HOME: '/home',
  LOGIN: '/login',

  // 管理页面
  ADMIN: {
    DASHBOARD: '/admin/dashboard',
    USERS: '/admin/users',
    POSTS: '/admin/posts',
    SETTINGS: '/admin/settings',
  },

  // 用户页面
  USER: {
    PROFILE: '/user/profile',
    POSTS: '/user/posts',
    SETTINGS: '/user/settings',
  },

  // 公共页面
  PUBLIC: {
    ABOUT: '/about',
    CONTACT: '/contact',
    HELP: '/help',
  },

  // 测试页面
  TEST: {
    VIEWUI: '/test-viewui',
    API: '/test-api',
    NOT_FOUND: '/test-404',
  },

  // 错误页面
  ERROR: {
    NOT_FOUND: '/404',
    SERVER_ERROR: '/500',
  },
};

/**
 * 获取路由路径
 * @param {string} routeKey - 路由键名，支持嵌套如 'ADMIN.USERS'
 * @returns {string} 路由路径
 */
export function getRoutePath(routeKey) {
  const keys = routeKey.split('.');
  let route = ROUTE_CONFIG;

  for (const key of keys) {
    if (route[key] === undefined) {
      throw new Error(`Route not found: ${routeKey}`);
    }
    route = route[key];
  }

  return route;
}

/**
 * 路由导航工具
 */
export const routerUtils = {
  /**
   * 跳转到指定路由
   * @param {object} router - Vue Router实例
   * @param {string} routeKey - 路由键名
   * @param {object} params - 路由参数
   * @param {object} query - 查询参数
   */
  navigateTo(router, routeKey, params = {}, query = {}) {
    const path = getRoutePath(routeKey);
    router.push({ path, params, query });
  },

  /**
   * 替换当前路由
   * @param {object} router - Vue Router实例
   * @param {string} routeKey - 路由键名
   * @param {object} params - 路由参数
   * @param {object} query - 查询参数
   */
  replaceTo(router, routeKey, params = {}, query = {}) {
    const path = getRoutePath(routeKey);
    router.replace({ path, params, query });
  },

  /**
   * 返回上一页
   * @param {object} router - Vue Router实例
   */
  goBack(router) {
    router.go(-1);
  },

  /**
   * 前进一页
   * @param {object} router - Vue Router实例
   */
  goForward(router) {
    router.go(1);
  },
};

/**
 * 路由守卫工具
 */
export const routeGuards = {
  /**
   * 检查是否已登录
   * @returns {boolean} 是否已登录
   */
  isAuthenticated() {
    return !!localStorage.getItem('token');
  },

  /**
   * 检查是否为管理员
   * @returns {boolean} 是否为管理员
   */
  isAdmin() {
    const userInfo = localStorage.getItem('userInfo');
    if (!userInfo) return false;

    try {
      const user = JSON.parse(userInfo);
      return user.is_admin === true;
    } catch {
      return false;
    }
  },

  /**
   * 需要登录的路由守卫
   * @param {object} router - Vue Router实例
   * @param {string} redirectTo - 未登录时重定向的路径
   */
  requireAuth(router, redirectTo = 'LOGIN') {
    if (!this.isAuthenticated()) {
      const path = getRoutePath(redirectTo);
      router.push(path);
      return false;
    }
    return true;
  },

  /**
   * 需要管理员权限的路由守卫
   * @param {object} router - Vue Router实例
   * @param {string} redirectTo - 无权限时重定向的路径
   */
  requireAdmin(router, redirectTo = 'HOME') {
    if (!this.isAdmin()) {
      const path = getRoutePath(redirectTo);
      router.push(path);
      return false;
    }
    return true;
  },
};

/**
 * 路由常量
 */
export const ROUTES = {
  HOME: 'HOME',
  LOGIN: 'LOGIN',
  ADMIN_DASHBOARD: 'ADMIN.DASHBOARD',
  ADMIN_USERS: 'ADMIN.USERS',
  ADMIN_POSTS: 'ADMIN.POSTS',
  ADMIN_SETTINGS: 'ADMIN.SETTINGS',
  USER_PROFILE: 'USER.PROFILE',
  USER_POSTS: 'USER.POSTS',
  USER_SETTINGS: 'USER.SETTINGS',
  PUBLIC_ABOUT: 'PUBLIC.ABOUT',
  PUBLIC_CONTACT: 'PUBLIC.CONTACT',
  PUBLIC_HELP: 'PUBLIC.HELP',
  TEST_VIEWUI: 'TEST.VIEWUI',
  TEST_API: 'TEST.API',
  TEST_NOT_FOUND: 'TEST.NOT_FOUND',
  NOT_FOUND: 'ERROR.NOT_FOUND',
  SERVER_ERROR: 'ERROR.SERVER_ERROR',
};

export default ROUTE_CONFIG;
