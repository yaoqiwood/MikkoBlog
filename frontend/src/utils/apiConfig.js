/**
 * API配置工具类
 * 统一管理所有API接口地址
 */

// 基础配置
const API_CONFIG = {
  // 基础URL - 使用环境变量，生产环境自动使用当前域名
  BASE_URL: import.meta.env.VITE_API_BASE_URL || (import.meta.env.PROD ? window.location.origin : 'http://localhost:8000'),

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
      AVATAR: '/auth/avatar',
    },

    // 个人资料
    PROFILES: {
      ME: '/admin/profiles/me',
      UPDATE: '/admin/profiles/me',
    },

    // 系统默认参数
    SYSTEM: {
      DEFAULTS: '/system/defaults',
      PUBLIC_DEFAULTS: '/system/defaults/public',
      BY_CATEGORY: '/system/defaults/category',
      BY_KEY: '/system/defaults/key',
      CATEGORIES: '/system/defaults/categories',
    },

    // 附件管理
    ATTACHMENTS: {
      LIST: '/attachments',
      PUBLIC_LIST: '/attachments/public',
      DETAIL: '/attachments',
      UPLOAD: '/attachments/upload',
      UPDATE: '/attachments',
      SOFT_DELETE: '/attachments',
      RESTORE: '/attachments',
      HARD_DELETE: '/attachments',
      BATCH_HARD_DELETE: '/attachments/batch/hard-delete',
      STATS: '/attachments/stats/summary',
    },

    // 用户管理
    USERS: {
      LIST: '/admin/users',
      CREATE: '/admin/users/add',
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
      TOGGLE_VISIBILITY: '/posts/',
      RELATED: '/posts/',
    },

    // 评论管理
    COMMENTS: {
      LIST: '/comments/',
      CREATE: '/comments/',
      UPDATE: '/comments/',
      DELETE: '/comments/',
      DETAIL: '/comments/',
      TOGGLE_APPROVAL: '/comments/',
      TOGGLE_VISIBILITY: '/comments/',
      POST_COMMENTS: '/comments/post/',
    },

    // 文件上传
    UPLOAD: {
      IMAGE: '/upload/image',
    },

    // 健康检查
    HEALTH: {
      CHECK: '/healthz',
    },

    // 统计数据
    STATS: {
      SUMMARY: '/stats/summary',
    },

    // 专栏管理
    COLUMNS: {
      LIST: '/columns/',
      CREATE: '/columns/',
      UPDATE: '/columns/',
      DELETE: '/columns/',
      DETAIL: '/columns/',
      ADD_POST: '/columns/',
      REMOVE_POST: '/columns/',
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
  } else if (id && action.toUpperCase() === 'TOGGLE_VISIBILITY') {
    url += `${id}/toggle-visibility`;
  } else if (id && action.toUpperCase() === 'RELATED') {
    url += `${id}/related`;
  }
  return url;
}

/**
 * 获取文件上传相关的URL
 * @param {string} action - 上传操作类型
 * @returns {string} 上传接口URL
 */
export function getUploadUrl(action) {
  const endpoint = API_CONFIG.ENDPOINTS.UPLOAD[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid upload action: ${action}`);
  }
  return getApiUrl(endpoint);
}

/**
 * 获取评论管理相关的URL
 * @param {string} action - 评论操作类型
 * @param {string|number} id - 评论ID（可选）
 * @returns {string} 评论接口URL
 */
export function getCommentUrl(action, id = null) {
  const endpoint = API_CONFIG.ENDPOINTS.COMMENTS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid comment action: ${action}`);
  }

  let url = getApiUrl(endpoint);
  if (id && ['UPDATE', 'DELETE', 'DETAIL'].includes(action.toUpperCase())) {
    url += `${id}`;
  } else if (id && ['TOGGLE_APPROVAL', 'TOGGLE_VISIBILITY'].includes(action.toUpperCase())) {
    url += `${id}/${action.toLowerCase().replace('toggle_', 'toggle-')}`;
  } else if (id && action.toUpperCase() === 'POST_COMMENTS') {
    url += `${id}`;
  }
  return url;
}

/**
 * 获取个人资料相关的URL
 * @param {string} action - 操作类型
 * @returns {string} 个人资料接口URL
 */
export function getProfileUrl(action) {
  const endpoint = API_CONFIG.ENDPOINTS.PROFILES[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid profile action: ${action}`);
  }
  return getApiUrl(endpoint);
}

/**
 * 获取系统默认参数相关的URL
 * @param {string} action - 操作类型
 * @param {string} category - 分类（可选）
 * @param {string} keyName - 键名（可选）
 * @returns {string} 系统默认参数接口URL
 */
export function getSystemUrl(action, category = null, keyName = null) {
  const endpoint = API_CONFIG.ENDPOINTS.SYSTEM[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid system action: ${action}`);
  }

  let url = getApiUrl(endpoint);

  if (action.toUpperCase() === 'BY_CATEGORY' && category) {
    url += `/${category}`;
  } else if (action.toUpperCase() === 'BY_KEY' && category && keyName) {
    url += `/${category}/${keyName}`;
  }

  return url;
}

/**
 * 获取附件管理相关的URL
 * @param {string} action - 操作类型
 * @param {string|number} id - 附件ID（可选）
 * @returns {string} 附件管理接口URL
 */
export function getAttachmentUrl(action, id = null) {
  const endpoint = API_CONFIG.ENDPOINTS.ATTACHMENTS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid attachment action: ${action}`);
  }

  let url = getApiUrl(endpoint);

  if (action.toUpperCase() === 'RESTORE' && id) {
    url += `/${id}/restore`;
  } else if (action.toUpperCase() === 'HARD_DELETE' && id) {
    url += `/${id}/hard-delete`;
  } else if (action.toUpperCase() === 'SOFT_DELETE' && id) {
    url += `/${id}/soft-delete`;
  } else if (id && ['DETAIL', 'UPDATE'].includes(action.toUpperCase())) {
    url += `/${id}`;
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

/**
 * 获取统计数据URL
 * @param {string} action - 统计操作类型
 * @returns {string} 统计接口URL
 */
export function getStatsUrl(action) {
  const endpoint = API_CONFIG.ENDPOINTS.STATS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid stats action: ${action}`);
  }
  return getApiUrl(endpoint);
}

/**
 * 获取专栏管理相关的URL
 * @param {string} action - 专栏操作类型
 * @param {string|number} columnId - 专栏ID（可选）
 * @param {string|number} postId - 文章ID（可选）
 * @returns {string} 专栏接口URL
 */
export function getColumnUrl(action, columnId = null, postId = null) {
  const endpoint = API_CONFIG.ENDPOINTS.COLUMNS[action.toUpperCase()];
  if (!endpoint) {
    throw new Error(`Invalid column action: ${action}`);
  }

  let url = getApiUrl(endpoint);

  if (columnId && ['UPDATE', 'DELETE', 'DETAIL'].includes(action.toUpperCase())) {
    url += `${columnId}`;
  } else if (columnId && postId && action.toUpperCase() === 'ADD_POST') {
    url += `${columnId}/posts/${postId}`;
  } else if (columnId && postId && action.toUpperCase() === 'REMOVE_POST') {
    url += `${columnId}/posts/${postId}`;
  }

  return url;
}

export default API_CONFIG;
