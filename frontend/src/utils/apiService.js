/**
 * API服务类
 * 封装具体的业务接口调用
 */

import {
  getAttachmentUrl,
  getAuthUrl,
  getCommentUrl,
  getHealthUrl,
  getPostUrl,
  getProfileUrl,
  getSystemUrl,
  getUploadUrl,
  getUserUrl,
} from './apiConfig';
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

  /**
   * 获取用户头像（智能获取：个人信息表优先，否则使用系统默认头像）
   * @returns {Promise} 头像信息
   */
  async getAvatar() {
    return get(getAuthUrl('AVATAR'));
  },

  /**
   * 重置用户头像为默认头像
   * @returns {Promise} 重置结果
   */
  async resetAvatar() {
    return del('http://localhost:8000/api/upload/avatar');
  },
};

/**
 * 个人资料API
 */
export const profileApi = {
  /**
   * 获取当前登录用户的个人资料（user_profiles）
   */
  async getMyProfile() {
    return get(getProfileUrl('ME'));
  },

  /**
   * 更新当前登录用户的个人资料
   * @param {object} data
   */
  async updateMyProfile(data) {
    return put(getProfileUrl('UPDATE'), data);
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
 * 评论管理API
 */
export const commentApi = {
  /**
   * 获取评论列表
   * @param {object} params - 查询参数
   * @returns {Promise} 评论列表
   */
  async getComments(params = {}) {
    return get(getCommentUrl('LIST'), params);
  },

  /**
   * 获取评论详情
   * @param {string|number} id - 评论ID
   * @returns {Promise} 评论详情
   */
  async getCommentById(id) {
    return get(getCommentUrl('DETAIL', id));
  },

  /**
   * 创建评论
   * @param {object} commentData - 评论数据
   * @returns {Promise} 创建结果
   */
  async createComment(commentData) {
    return post(getCommentUrl('CREATE'), commentData);
  },

  /**
   * 更新评论
   * @param {string|number} id - 评论ID
   * @param {object} commentData - 评论数据
   * @returns {Promise} 更新结果
   */
  async updateComment(id, commentData) {
    return put(getCommentUrl('UPDATE', id), commentData);
  },

  /**
   * 删除评论（软删除）
   * @param {string|number} id - 评论ID
   * @returns {Promise} 删除结果
   */
  async deleteComment(id) {
    return del(getCommentUrl('DELETE', id));
  },

  /**
   * 切换评论审核状态
   * @param {string|number} id - 评论ID
   * @returns {Promise} 切换结果
   */
  async toggleApproval(id) {
    return patch(getCommentUrl('TOGGLE_APPROVAL', id));
  },

  /**
   * 切换评论可见性
   * @param {string|number} id - 评论ID
   * @returns {Promise} 切换结果
   */
  async toggleVisibility(id) {
    return patch(getCommentUrl('TOGGLE_VISIBILITY', id));
  },

  /**
   * 获取指定文章的评论列表
   * @param {string|number} postId - 文章ID
   * @param {object} params - 查询参数
   * @returns {Promise} 文章评论列表
   */
  async getPostComments(postId, params = {}) {
    return get(getCommentUrl('POST_COMMENTS', postId), params);
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

  /**
   * 获取所有系统默认参数（管理员）
   * @param {object} params - 查询参数
   * @returns {Promise} 系统默认参数列表
   */
  async getDefaults(params = {}) {
    return get(getSystemUrl('DEFAULTS'), params);
  },

  /**
   * 获取公开的系统默认参数
   * @param {object} params - 查询参数
   * @returns {Promise} 公开的系统默认参数列表
   */
  async getPublicDefaults(params = {}) {
    return get(getSystemUrl('PUBLIC_DEFAULTS'), params);
  },

  /**
   * 按分类获取系统默认参数
   * @param {string} category - 分类
   * @param {object} params - 查询参数
   * @returns {Promise} 系统默认参数列表
   */
  async getDefaultsByCategory(category, params = {}) {
    return get(getSystemUrl('BY_CATEGORY', category), params);
  },

  /**
   * 根据分类和键名获取系统默认参数
   * @param {string} category - 分类
   * @param {string} keyName - 键名
   * @returns {Promise} 系统默认参数
   */
  async getDefaultByKey(category, keyName) {
    return get(getSystemUrl('BY_KEY', category, keyName));
  },

  /**
   * 获取所有分类列表
   * @returns {Promise} 分类列表
   */
  async getCategories() {
    return get(getSystemUrl('CATEGORIES'));
  },

  /**
   * 创建系统默认参数（管理员）
   * @param {object} defaultData - 系统默认参数数据
   * @returns {Promise} 创建结果
   */
  async createDefault(defaultData) {
    return post(getSystemUrl('DEFAULTS'), defaultData);
  },

  /**
   * 更新系统默认参数（管理员）
   * @param {number} id - 参数ID
   * @param {object} defaultData - 系统默认参数数据
   * @returns {Promise} 更新结果
   */
  async updateDefault(id, defaultData) {
    return put(`${getSystemUrl('DEFAULTS')}/${id}`, defaultData);
  },

  /**
   * 删除系统默认参数（管理员）
   * @param {number} id - 参数ID
   * @returns {Promise} 删除结果
   */
  async deleteDefault(id) {
    return del(`${getSystemUrl('DEFAULTS')}/${id}`);
  },
};

/**
 * 附件管理API
 */
export const attachmentApi = {
  /**
   * 获取附件列表（管理员）
   * @param {object} params - 查询参数
   * @returns {Promise} 附件列表
   */
  async getAttachments(params = {}) {
    return get(getAttachmentUrl('LIST'), params);
  },

  /**
   * 获取公开附件列表
   * @param {object} params - 查询参数
   * @returns {Promise} 公开附件列表
   */
  async getPublicAttachments(params = {}) {
    return get(getAttachmentUrl('PUBLIC_LIST'), params);
  },

  /**
   * 获取附件详情
   * @param {number} id - 附件ID
   * @returns {Promise} 附件详情
   */
  async getAttachment(id) {
    return get(getAttachmentUrl('DETAIL', id));
  },

  /**
   * 上传附件
   * @param {FormData} formData - 文件数据
   * @returns {Promise} 上传结果
   */
  async uploadAttachment(formData) {
    return postForm(getAttachmentUrl('UPLOAD'), formData);
  },

  /**
   * 更新附件信息（管理员）
   * @param {number} id - 附件ID
   * @param {object} attachmentData - 附件数据
   * @returns {Promise} 更新结果
   */
  async updateAttachment(id, attachmentData) {
    return put(getAttachmentUrl('UPDATE', id), attachmentData);
  },

  /**
   * 软删除附件（管理员）
   * @param {number} id - 附件ID
   * @returns {Promise} 删除结果
   */
  async softDeleteAttachment(id) {
    return del(getAttachmentUrl('SOFT_DELETE', id));
  },

  /**
   * 恢复已删除的附件（管理员）
   * @param {number} id - 附件ID
   * @returns {Promise} 恢复结果
   */
  async restoreAttachment(id) {
    return post(getAttachmentUrl('RESTORE', id));
  },

  /**
   * 硬删除附件（管理员）
   * @param {number} id - 附件ID
   * @returns {Promise} 硬删除结果
   */
  async hardDeleteAttachment(id) {
    return del(getAttachmentUrl('HARD_DELETE', id));
  },

  /**
   * 批量硬删除附件（管理员）
   * @param {Array<number>} ids - 附件ID数组
   * @returns {Promise} 批量删除结果
   */
  async batchHardDeleteAttachments(ids) {
    return post(getAttachmentUrl('BATCH_HARD_DELETE'), ids);
  },

  /**
   * 获取附件统计信息（管理员）
   * @returns {Promise} 统计信息
   */
  async getAttachmentStats() {
    return get(getAttachmentUrl('STATS'));
  },
};

// 导出所有API
export default {
  auth: authApi,
  profile: profileApi,
  user: userApi,
  post: postApi,
  comment: commentApi,
  upload: uploadApi,
  system: systemApi,
  attachment: attachmentApi,
};
