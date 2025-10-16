/**
 * URL工具类
 * 统一处理API URL和资源URL
 */

/**
 * 获取API基础URL
 * @returns {string} API基础URL
 */
export function getApiBaseUrl() {
  // 如果设置了环境变量，直接使用
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL;
  }

  // 生产环境使用当前域名的HTTPS
  if (import.meta.env.PROD) {
    return window.location.origin;
  }

  // 开发环境使用localhost
  return 'http://localhost:8000';
}

/**
 * 获取完整的API URL
 * @param {string} path - API路径
 * @returns {string} 完整的API URL
 */
export function getApiUrl(path) {
  const baseUrl = getApiBaseUrl();
  return `${baseUrl}${path}`;
}

/**
 * 获取完整的资源URL
 * @param {string} url - 资源路径
 * @returns {string} 完整的资源URL
 */
export function getFullUrl(url) {
  if (!url) return '';

  // 如果已经是完整URL，直接返回
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  // 如果是相对路径，添加基础URL
  if (url.startsWith('/')) {
    return `${getApiBaseUrl()}${url}`;
  }

  return url;
}

/**
 * 获取上传URL
 * @param {string} path - 上传路径
 * @returns {string} 完整的上传URL
 */
export function getUploadUrl(path) {
  return getApiUrl(`/api/upload/${path}`);
}
