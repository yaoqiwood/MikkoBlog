/**
 * API服务类
 * 封装具体的业务接口调用
 */

import {
  getAttachmentUrl,
  getAuthUrl,
  getColumnUrl,
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

  /**
   * 获取公开的用户资料（不需要登录）
   * @param {number} userId - 用户ID
   * @returns {Promise} 用户资料
   */
  async getPublicProfile(userId) {
    return get(`http://localhost:8000/api/admin/profiles/public/${userId}`);
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
   * 按分类和键名更新系统默认参数
   * @param {string} category - 分类
   * @param {string} keyName - 键名
   * @param {any} value - 新值
   * @param {string} dataType - 数据类型
   * @returns {Promise} 更新结果
   */
  async updateDefaultByKey(category, keyName, value, dataType = 'string') {
    return put(getSystemUrl('BY_KEY', category, keyName), {
      key_value: value,
      data_type: dataType,
    });
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
 * 主页设置 API
 */
export const homepageApi = {
  async getSettings() {
    return get('http://localhost:8000/api/homepage/settings');
  },
  async updateSettings(data) {
    return put('http://localhost:8000/api/homepage/settings', data);
  },
};

/**
 * 标签云管理API
 */
export const tagCloudApi = {
  /**
   * 获取标签云列表
   * @param {object} params - 查询参数
   * @returns {Promise} 标签列表
   */
  async getTags(params = {}) {
    return get('http://localhost:8000/api/tag-cloud/tags', params);
  },

  /**
   * 获取活跃标签（用于前端显示）
   * @param {number} limit - 限制数量
   * @returns {Promise} 活跃标签列表
   */
  async getActiveTags(limit = 50) {
    return get('http://localhost:8000/api/tag-cloud/tags/active', { limit });
  },

  /**
   * 创建标签（管理员）
   * @param {object} tagData - 标签数据
   * @returns {Promise} 创建结果
   */
  async createTag(tagData) {
    return post('http://localhost:8000/api/tag-cloud/tags', tagData);
  },

  /**
   * 更新标签（管理员）
   * @param {number} tagId - 标签ID
   * @param {object} tagData - 标签数据
   * @returns {Promise} 更新结果
   */
  async updateTag(tagId, tagData) {
    return put(`http://localhost:8000/api/tag-cloud/tags/${tagId}`, tagData);
  },

  /**
   * 删除标签（管理员）
   * @param {number} tagId - 标签ID
   * @returns {Promise} 删除结果
   */
  async deleteTag(tagId) {
    return del(`http://localhost:8000/api/tag-cloud/tags/${tagId}`);
  },

  /**
   * 切换标签状态（管理员）
   * @param {number} tagId - 标签ID
   * @returns {Promise} 切换结果
   */
  async toggleTagStatus(tagId) {
    return patch(`http://localhost:8000/api/tag-cloud/tags/${tagId}/toggle`);
  },

  /**
   * 立即获取标签（管理员）
   * @returns {Promise} 获取结果
   */
  async fetchTagsNow() {
    return post('http://localhost:8000/api/tag-cloud/tags/fetch');
  },

  /**
   * 获取标签获取历史（管理员）
   * @param {number} limit - 限制数量
   * @returns {Promise} 获取历史
   */
  async getFetchHistory(limit = 30) {
    return get('http://localhost:8000/api/tag-cloud/tags/fetch-history', { limit });
  },

  /**
   * 获取标签统计信息（管理员）
   * @returns {Promise} 统计信息
   */
  async getStats() {
    return get('http://localhost:8000/api/tag-cloud/tags/stats');
  },

  /**
   * 获取调度时间信息
   * @returns {Promise} 调度时间信息
   */
  async getScheduleTime() {
    return get('http://localhost:8000/api/tag-cloud/schedule/time');
  },

  /**
   * 获取调度配置信息
   * @returns {Promise} 调度配置信息
   */
  async getScheduleConfig() {
    return get('http://localhost:8000/api/tag-cloud/schedule/config');
  },

  /**
   * 更新调度时间（管理员）
   * @param {string} time - 时间 (HH:MM格式)
   * @returns {Promise} 更新结果
   */
  async updateScheduleTime(time) {
    return put('http://localhost:8000/api/tag-cloud/schedule/time', { time });
  },

  /**
   * 更新调度配置（管理员）
   * @param {object} config - 调度配置 {frequency, time, day}
   * @returns {Promise} 更新结果
   */
  async updateScheduleConfig(config) {
    return put('http://localhost:8000/api/tag-cloud/schedule/config', config);
  },

  /**
   * 更新搜索关键词（管理员）
   * @param {array|string} keywords - 搜索关键词数组或逗号分隔的字符串
   * @returns {Promise} 更新结果
   */
  async updateSearchKeywords(keywords) {
    return put('http://localhost:8000/api/tag-cloud/search/keywords', { keywords });
  },

  /**
   * 立即根据关键词获取标签（管理员）
   * @param {array|string} keywords - 搜索关键词数组或逗号分隔的字符串
   * @returns {Promise} 任务启动结果
   */
  async fetchTagsByKeywords(keywords) {
    return post('http://localhost:8000/api/tag-cloud/search/fetch', { keywords });
  },
};

/**
 * 说说管理API
 */
export const momentsApi = {
  /**
   * 获取说说列表
   * @param {object} params - 查询参数
   * @returns {Promise} 说说列表
   */
  async getMoments(params = {}) {
    return get('http://localhost:8000/api/moments', params);
  },

  /**
   * 获取说说详情
   * @param {string|number} id - 说说ID
   * @returns {Promise} 说说详情
   */
  async getMomentById(id) {
    return get(`http://localhost:8000/api/moments/${id}`);
  },

  /**
   * 创建说说
   * @param {object} momentData - 说说数据
   * @returns {Promise} 创建结果
   */
  async createMoment(momentData) {
    return post('http://localhost:8000/api/moments', momentData);
  },

  /**
   * 更新说说
   * @param {string|number} id - 说说ID
   * @param {object} momentData - 说说数据
   * @returns {Promise} 更新结果
   */
  async updateMoment(id, momentData) {
    return put(`http://localhost:8000/api/moments/${id}`, momentData);
  },

  /**
   * 删除说说（软删除）
   * @param {string|number} id - 说说ID
   * @returns {Promise} 删除结果
   */
  async deleteMoment(id) {
    return del(`http://localhost:8000/api/moments/${id}`);
  },

  /**
   * 切换说说可见性
   * @param {string|number} id - 说说ID
   * @returns {Promise} 切换结果
   */
  async toggleMomentVisibility(id) {
    return patch(`http://localhost:8000/api/moments/${id}/toggle-visibility`);
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

/**
 * 专栏相关API
 */
export const columnsApi = {
  /**
   * 获取专栏列表
   * @param {Object} params - 查询参数
   * @returns {Promise} 专栏列表
   */
  async getColumns(params = {}) {
    const url = getColumnUrl('LIST');
    const queryParams = new URLSearchParams();

    if (params.page) queryParams.append('page', params.page);
    if (params.limit) queryParams.append('limit', params.limit);
    if (params.is_visible !== undefined) queryParams.append('is_visible', params.is_visible);
    if (params.user_id) queryParams.append('user_id', params.user_id);

    const fullUrl = queryParams.toString() ? `${url}?${queryParams}` : url;
    return get(fullUrl);
  },

  /**
   * 获取单个专栏详情
   * @param {number} columnId - 专栏ID
   * @returns {Promise} 专栏详情
   */
  async getColumnById(columnId) {
    return get(getColumnUrl('DETAIL', columnId));
  },

  /**
   * 创建专栏
   * @param {Object} columnData - 专栏数据
   * @returns {Promise} 创建结果
   */
  async createColumn(columnData) {
    return post(getColumnUrl('CREATE'), columnData);
  },

  /**
   * 更新专栏
   * @param {number} columnId - 专栏ID
   * @param {Object} columnData - 更新数据
   * @returns {Promise} 更新结果
   */
  async updateColumn(columnId, columnData) {
    return put(getColumnUrl('UPDATE', columnId), columnData);
  },

  /**
   * 删除专栏
   * @param {number} columnId - 专栏ID
   * @returns {Promise} 删除结果
   */
  async deleteColumn(columnId) {
    return del(getColumnUrl('DELETE', columnId));
  },

  /**
   * 将文章添加到专栏
   * @param {number} columnId - 专栏ID
   * @param {number} postId - 文章ID
   * @param {number} sortOrder - 排序顺序
   * @returns {Promise} 添加结果
   */
  async addPostToColumn(columnId, postId, sortOrder = 0) {
    const url = getColumnUrl('ADD_POST', columnId, postId);
    const queryParams = new URLSearchParams();
    if (sortOrder) queryParams.append('sort_order', sortOrder);

    const fullUrl = queryParams.toString() ? `${url}?${queryParams}` : url;
    return post(fullUrl);
  },

  /**
   * 从专栏移除文章
   * @param {number} columnId - 专栏ID
   * @param {number} postId - 文章ID
   * @returns {Promise} 移除结果
   */
  async removePostFromColumn(columnId, postId) {
    return del(getColumnUrl('REMOVE_POST', columnId, postId));
  },
};

/**
 * 混合内容API（博客+说说）
 */
export const mixedContentApi = {
  /**
   * 获取混合内容（博客文章和说说）
   * @param {object} params - 查询参数
   * @returns {Promise} 混合内容列表
   */
  async getMixedContent(params = {}) {
    // 并行获取博客和说说
    const [postsResponse, momentsResponse] = await Promise.all([
      postApi.getPosts({
        page: params.page || 1,
        limit: params.limit || 10,
        is_visible: true,
        is_deleted: false,
      }),
      momentsApi.getMoments({
        page: params.page || 1,
        limit: params.limit || 10,
        is_visible: true,
      }),
    ]);

    // 格式化博客数据
    const formattedPosts = (postsResponse || []).map(post => ({
      id: post.id,
      type: 'blog',
      title: post.title,
      content: post.summary || post.content.substring(0, 200) + '...',
      views: post.view_count || 0,
      comments: post.comment_count || 0,
      likes: post.like_count || 0,
      shares: post.share_count || 0,
      image: post.cover_image_url,
      created_at: post.created_at,
      updated_at: post.updated_at,
      author_name: post.user_nickname || '',
      author_avatar: post.user_avatar || '',
    }));

    // 格式化说说数据
    const formattedMoments = (momentsResponse?.items || []).map(moment => ({
      id: moment.id,
      type: 'moment',
      content: moment.content,
      views: 0,
      comments: 0,
      likes: 0,
      shares: 0,
      images: moment.images || [],
      created_at: moment.created_at,
      updated_at: moment.updated_at,
      author_name: moment.user_nickname || '',
      author_avatar: moment.user_avatar || '',
    }));

    // 合并并按时间排序
    const allContent = [...formattedPosts, ...formattedMoments];
    allContent.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    return {
      items: allContent,
      total: (postsResponse?.length || 0) + (momentsResponse?.total || 0),
      has_more:
        postsResponse?.length === (params.limit || 10) || momentsResponse?.has_more === true,
    };
  },
};

/**
 * 图片搜索API
 */
export const imageSearchApi = {
  /**
   * 搜索图片
   * @param {Array} tags - 搜索标签
   * @param {number} count - 图片数量
   * @param {string} orientation - 图片方向
   * @returns {Promise} 图片列表
   */
  async searchImages(tags, count = 10, orientation = 'landscape') {
    return post('http://localhost:8000/api/image-search/search', {
      tags,
      count,
      orientation,
    });
  },

  /**
   * 获取随机封面图片
   * @param {Array} tags - 搜索标签
   * @returns {Promise} 封面图片URL
   */
  async getRandomCover(tags) {
    return post('http://localhost:8000/api/image-search/random-cover', {
      tags,
    });
  },

  /**
   * 获取可用标签
   * @returns {Promise} 标签列表
   */
  async getTags() {
    return get('http://localhost:8000/api/image-search/tags');
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
  homepage: homepageApi,
  moments: momentsApi,
  columns: columnsApi,
  mixedContent: mixedContentApi,
  attachment: attachmentApi,
  imageSearch: imageSearchApi,
};
