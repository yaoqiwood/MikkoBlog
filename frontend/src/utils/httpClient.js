/**
 * HTTP请求工具类
 * 封装axios请求，统一处理请求和响应
 */

import axios from 'axios';
import { getApiConfig } from './apiConfig';
import { authCookie } from './cookieUtils';

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

    // 添加请求时间戳
    config.metadata = { startTime: new Date() };

    console.log(`🚀 [${config.method?.toUpperCase()}] ${config.url}`, config.data || config.params);
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
    console.log(
      `✅ [${response.config.method?.toUpperCase()}] ${response.config.url} - ${duration}ms`,
      response.data
    );
    return response;
  },
  error => {
    const duration = error.config?.metadata ? new Date() - error.config.metadata.startTime : 0;
    console.error(
      `❌ [${error.config?.method?.toUpperCase()}] ${error.config?.url} - ${duration}ms`,
      error.response?.data || error.message
    );

    // 处理401未授权错误
    if (error.response?.status === 401) {
      authCookie.clearAuth();
      // 可以在这里触发登录页面跳转
      window.location.href = '/login';
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
  return request('GET', url, null, { params, ...config });
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

  return request('POST', url, formData, {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    ...config,
  });
}

export default httpClient;
