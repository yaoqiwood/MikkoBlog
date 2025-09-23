/**
 * API服务类
 * 封装具体的业务接口调用
 */

import { getAuthUrl, getHealthUrl, getPostUrl, getUploadUrl, getUserUrl } from './apiConfig';
import { del, get, patch, post, postForm, put } from './httpClient';

/**
 * 认证相关API
 */
export const authApi = {
  /**
   * 用户登录
   * @param {string} username - 用户名或邮箱
   * @param {string} password - 密码
   * @returns {Promise} 登录结果
   */
  async login(username, password) {
    return postForm(getAuthUrl('LOGIN'), {
      username,
      password,
      grant_type: 'password',
    });
  },

  /**
   * 刷新token
   * @param {string} refreshToken - 刷新token
   * @returns {Promise} 刷新结果
   */
  async refreshToken(refreshToken) {
    return post(getAuthUrl('REFRESH'), { refresh_token: refreshToken });
  },

  /**
   * 用户登出
   * @returns {Promise} 登出结果
   */
  async logout() {
    return post(getAuthUrl('LOGOUT'));
  },

  /**
   * 获取用户信息
   * @returns {Promise} 用户信息
   */
  async getProfile() {
    return get(getAuthUrl('PROFILE'));
  },

  /**
   * 获取当前用户信息（用于验证token有效性）
   * @returns {Promise} 当前用户信息
   */
  async getMe() {
    return get(getAuthUrl('ME'));
  },
};

/**
 * 用户管理API
 */
export const userApi = {
  /**
   * 获取用户列表
   * @param {object} params - 查询参数
   * @returns {Promise} 用户列表
   */
  async getUsers(params = {}) {
    return get(getUserUrl('LIST'), params);
  },

  /**
   * 获取用户详情
   * @param {string|number} id - 用户ID
   * @returns {Promise} 用户详情
   */
  async getUserById(id) {
    return get(getUserUrl('DETAIL', id));
  },

  /**
   * 创建用户
   * @param {object} userData - 用户数据
   * @returns {Promise} 创建结果
   */
  async createUser(userData) {
    return post(getUserUrl('CREATE'), userData);
  },

  /**
   * 更新用户
   * @param {string|number} id - 用户ID
   * @param {object} userData - 用户数据
   * @returns {Promise} 更新结果
   */
  async updateUser(id, userData) {
    return put(getUserUrl('UPDATE', id), userData);
  },

  /**
   * 删除用户
   * @param {string|number} id - 用户ID
   * @returns {Promise} 删除结果
   */
  async deleteUser(id) {
    return del(getUserUrl('DELETE', id));
  },
};

/**
 * 文章管理API
 */
export const postApi = {
  /**
   * 获取文章列表
   * @param {object} params - 查询参数
   * @returns {Promise} 文章列表
   */
  async getPosts(params = {}) {
    return get(getPostUrl('LIST'), params);
  },

  /**
   * 获取文章详情
   * @param {string|number} id - 文章ID
   * @returns {Promise} 文章详情
   */
  async getPostById(id) {
    return get(getPostUrl('DETAIL', id));
  },

  /**
   * 创建文章
   * @param {object} postData - 文章数据
   * @returns {Promise} 创建结果
   */
  async createPost(postData) {
    return post(getPostUrl('CREATE'), postData);
  },

  /**
   * 更新文章
   * @param {string|number} id - 文章ID
   * @param {object} postData - 文章数据
   * @returns {Promise} 更新结果
   */
  async updatePost(id, postData) {
    return put(getPostUrl('UPDATE', id), postData);
  },

  /**
   * 删除文章（软删除）
   * @param {string|number} id - 文章ID
   * @returns {Promise} 删除结果
   */
  async deletePost(id) {
    return del(getPostUrl('DELETE', id));
  },

  /**
   * 切换文章可见性
   * @param {string|number} id - 文章ID
   * @returns {Promise} 切换结果
   */
  async toggleVisibility(id) {
    return patch(getPostUrl('TOGGLE_VISIBILITY', id));
  },
};

/**
 * 文件上传API
 */
export const uploadApi = {
  /**
   * 上传图片
   * @param {FormData} formData - 图片文件数据
   * @returns {Promise} 上传结果
   */
  async uploadImage(formData) {
    return post(getUploadUrl('IMAGE'), formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
};

/**
 * 系统相关API
 */
export const systemApi = {
  /**
   * 健康检查
   * @returns {Promise} 健康状态
   */
  async healthCheck() {
    return get(getHealthUrl());
  },
};

// 导出所有API
export default {
  auth: authApi,
  user: userApi,
  post: postApi,
  upload: uploadApi,
  system: systemApi,
};
