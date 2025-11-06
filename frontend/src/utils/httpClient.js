/**
 * HTTP请求工具类
 * 封装axios请求，统一处理请求和响应
 */

import axios from 'axios';
import { getApiConfig } from './apiConfig';
import { authCookie } from './cookieUtils';
import { startLoading, stopLoading } from './loadingManager';
import logger from './logger';

// 创建axios实例
const httpClient = axios.create({
  baseURL: getApiConfig().BASE_URL,
  timeout: getApiConfig().TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
httpClient.interceptors.request.use(
  config => {
    // 添加认证token
    const token = authCookie.getAuth().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // 添加请求时间戳和唯一ID
    const requestId = `${config.method?.toUpperCase()}_${config.url}_${Date.now()}`;
    config.metadata = {
      startTime: new Date(),
      requestId: requestId,
    };

    // 开始全局loading（除非明确禁用）
    if (config.showLoading !== false) {
      startLoading(requestId);
    }

    logger.http(config.method?.toUpperCase(), config.url, config.data || config.params);
    logger.debug('🔍 [interceptor] Full config:', config);
    return config;
  },
  error => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
httpClient.interceptors.response.use(
  response => {
    const duration = new Date() - response.config.metadata.startTime;

    // 结束全局loading
    if (response.config.showLoading !== false) {
      stopLoading(response.config.metadata.requestId);
    }

    logger.httpResponse(
      response.config.method?.toUpperCase(),
      response.config.url,
      duration,
      response.data
    );
    return response;
  },
  error => {
    const duration = error.config?.metadata ? new Date() - error.config.metadata.startTime : 0;

    // 结束全局loading（即使请求失败）
    if (error.config?.showLoading !== false) {
      stopLoading(error.config?.metadata?.requestId);
    }

    console.error(
      `❌ [${error.config?.method?.toUpperCase()}] ${error.config?.url} - ${duration}ms`,
      error.response?.data || error.message
    );

    // 处理不同类型的错误
    if (error.code === 'ECONNREFUSED' || error.code === 'ERR_NETWORK' || !error.response) {
      // 网络连接错误（后端服务未启动）
      const networkError = new Error('服务器连接失败，请检查后端服务是否已启动');
      networkError.type = 'NETWORK_ERROR';
      networkError.originalError = error;
      return Promise.reject(networkError);
    } else if (error.response?.status === 401) {
      // 401未授权错误
      authCookie.clearAuth();

      // 检查当前是否在公开页面，如果是则不自动跳转
      const currentPath = window.location.pathname;
      const publicPaths = ['/', '/blog', '/article', '/moments'];
      const isPublicPage = publicPaths.some(
        path => currentPath === path || currentPath.startsWith(path + '/')
      );

      // 避免在登录页或登录请求失败时刷新当前页，影响体验
      const isLoginPage = currentPath === '/login';
      const isAuthTokenRequest = (error.config?.url || '').includes('/auth/token');

      if (!isPublicPage && !isLoginPage && !isAuthTokenRequest) {
        // 只有在非公开页面才自动跳转到登录页
        window.location.href = '/login';
      }
    }

    return Promise.reject(error);
  }
);

/**
 * 通用请求方法
 * @param {string} method - 请求方法
 * @param {string} url - 请求URL
 * @param {object} data - 请求数据
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
async function request(method, url, data = null, config = {}) {
  try {
    logger.debug('🔍 [request] Method:', method);
    logger.debug('🔍 [request] URL:', url);
    logger.debug('🔍 [request] Data:', data);
    logger.debug('🔍 [request] Config:', config);

    const response = await httpClient({
      method,
      url,
      data,
      ...config,
    });
    return response.data;
  } catch (error) {
    throw error;
  }
}

/**
 * GET请求
 * @param {string} url - 请求URL
 * @param {object} params - 查询参数
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function get(url, params = {}, config = {}) {
  logger.debug('🔍 [httpClient.get] URL:', url);
  logger.debug('🔍 [httpClient.get] Params:', params);
  logger.debug('🔍 [httpClient.get] Config:', config);
  return request('GET', url, null, { ...config, params });
}

/**
 * POST请求
 * @param {string} url - 请求URL
 * @param {object} data - 请求数据
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function post(url, data = {}, config = {}) {
  return request('POST', url, data, config);
}

/**
 * PUT请求
 * @param {string} url - 请求URL
 * @param {object} data - 请求数据
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function put(url, data = {}, config = {}) {
  return request('PUT', url, data, config);
}

/**
 * DELETE请求
 * @param {string} url - 请求URL
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function del(url, config = {}) {
  return request('DELETE', url, null, config);
}

/**
 * PATCH请求
 * @param {string} url - 请求URL
 * @param {object} data - 请求数据
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function patch(url, data = {}, config = {}) {
  return request('PATCH', url, data, config);
}

/**
 * 上传文件
 * @param {string} url - 上传URL
 * @param {FormData} formData - 文件数据
 * @param {object} config - 请求配置
 * @returns {Promise} 上传结果
 */
export async function upload(url, formData, config = {}) {
  return request('POST', url, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    ...config,
  });
}

/**
 * 下载文件
 * @param {string} url - 下载URL
 * @param {object} config - 请求配置
 * @returns {Promise} 下载结果
 */
export async function download(url, config = {}) {
  return request('GET', url, null, {
    responseType: 'blob',
    ...config,
  });
}

/**
 * 表单提交（application/x-www-form-urlencoded）
 * @param {string} url - 请求URL
 * @param {object} data - 表单数据
 * @param {object} config - 请求配置
 * @returns {Promise} 请求结果
 */
export async function postForm(url, data = {}, config = {}) {
  const formData = new URLSearchParams();
  Object.keys(data).forEach(key => {
    formData.append(key, data[key]);
  });

  // 合并 headers，确保不会被外部 headers 覆盖掉 Content-Type
  const mergedHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    ...(config.headers || {}),
  };

  return request('POST', url, formData, {
    ...config,
    headers: mergedHeaders,
  });
}

export default httpClient;
