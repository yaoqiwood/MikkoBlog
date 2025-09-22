/**
 * API配置工具类
 * 统一管理所有API接口地址
 */

// 基础配置
const API_CONFIG = {
  // 基础URL
  BASE_URL: 'http://localhost:8000',

  // API版本
  API_VERSION: '/api',

  // 请求超时时间
  TIMEOUT: 10000,

  // 接口地址
  ENDPOINTS: {
    // 认证相关
    AUTH: {
      LOGIN: '/auth/token',
      REFRESH: '/auth/refresh',
      LOGOUT: '/auth/logout',
      PROFILE: '/auth/profile',
      ME: '/auth/me',
    },

    // 用户管理
    USERS: {
      LIST: '/admin/users',
      CREATE: '/admin/users',
      UPDATE: '/admin/users',
      DELETE: '/admin/users',
      DETAIL: '/admin/users',
    },

    // 文章管理
    POSTS: {
      LIST: '/posts/',
      CREATE: '/posts/',
      UPDATE: '/posts/',
      DELETE: '/posts/',
      DETAIL: '/posts/',
    },

    // 健康检查
    HEALTH: {
      CHECK: '/health',
    },
  },
};

/**
 * 获取完整的API URL
 * @param {string} endpoint - 接口路径
 * @returns {string} 完整的API URL
 */
export function getApiUrl(endpoint) {
  return `${API_CONFIG.BASE_URL}${API_CONFIG.API_VERSION}${endpoint}`;
}

/**
 * 获取基础配置
 * @returns {object} API配置对象
 */
export function getApiConfig() {
  return API_CONFIG;
}

/**
 * 获取认证相关的URL
 * @param {string} action - 认证操作类型
 * @returns {string} 认证接口URL
 */
export function getAuthUrl(action) {
  const endpoint = API_CONFIG.ENDPOINTS.AUTH[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid auth action: ${action}`);
  }
  return getApiUrl(endpoint);
}

/**
 * 获取用户管理相关的URL
 * @param {string} action - 用户操作类型
 * @param {string|number} id - 用户ID（可选）
 * @returns {string} 用户接口URL
 */
export function getUserUrl(action, id = null) {
  const endpoint = API_CONFIG.ENDPOINTS.USERS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid user action: ${action}`);
  }

  let url = getApiUrl(endpoint);
  if (id && ['UPDATE', 'DELETE', 'DETAIL'].includes(action.toUpperCase())) {
    url += `/${id}`;
  }
  return url;
}

/**
 * 获取文章管理相关的URL
 * @param {string} action - 文章操作类型
 * @param {string|number} id - 文章ID（可选）
 * @returns {string} 文章接口URL
 */
export function getPostUrl(action, id = null) {
  const endpoint = API_CONFIG.ENDPOINTS.POSTS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid post action: ${action}`);
  }

  let url = getApiUrl(endpoint);
  if (id && ['UPDATE', 'DELETE', 'DETAIL'].includes(action.toUpperCase())) {
    url += `${id}`;
  }
  return url;
}

/**
 * 获取健康检查URL
 * @returns {string} 健康检查接口URL
 */
export function getHealthUrl() {
  return getApiUrl(API_CONFIG.ENDPOINTS.HEALTH.CHECK);
}

export default API_CONFIG;
