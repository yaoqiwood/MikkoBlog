/**
 * Cookie工具类
 * 提供统一的cookie操作方法
 */

/**
 * 设置cookie
 * @param {string} name - cookie名称
 * @param {string} value - cookie值
 * @param {object} options - cookie选项
 * @param {number} options.maxAge - 最大存活时间（秒）
 * @param {string} options.path - 路径
 * @param {string} options.domain - 域名
 * @param {boolean} options.secure - 是否只在HTTPS下传输
 * @param {boolean} options.httpOnly - 是否只允许HTTP访问
 * @param {string} options.sameSite - SameSite策略
 */
export function setCookie(name, value, options = {}) {
  const {
    maxAge = 7 * 24 * 60 * 60, // 默认7天
    path = '/',
    domain,
    secure = false,
    httpOnly = false,
    sameSite = 'Lax',
  } = options;

  let cookieString = `${name}=${encodeURIComponent(value)}`;

  if (maxAge) {
    cookieString += `; max-age=${maxAge}`;
  }

  if (path) {
    cookieString += `; path=${path}`;
  }

  if (domain) {
    cookieString += `; domain=${domain}`;
  }

  if (secure) {
    cookieString += '; secure';
  }

  if (httpOnly) {
    cookieString += '; httpOnly';
  }

  if (sameSite) {
    cookieString += `; samesite=${sameSite}`;
  }

  document.cookie = cookieString;
}

/**
 * 获取cookie值
 * @param {string} name - cookie名称
 * @returns {string|null} cookie值
 */
export function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) {
    return decodeURIComponent(parts.pop().split(';').shift());
  }
  return null;
}

/**
 * 删除cookie
 * @param {string} name - cookie名称
 * @param {string} path - 路径
 * @param {string} domain - 域名
 */
export function removeCookie(name, path = '/', domain) {
  let cookieString = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=${path}`;

  if (domain) {
    cookieString += `; domain=${domain}`;
  }

  document.cookie = cookieString;
}

/**
 * 检查cookie是否存在
 * @param {string} name - cookie名称
 * @returns {boolean} 是否存在
 */
export function hasCookie(name) {
  return getCookie(name) !== null;
}

/**
 * 获取所有cookie
 * @returns {object} 所有cookie的键值对
 */
export function getAllCookies() {
  const cookies = {};
  if (document.cookie) {
    document.cookie.split(';').forEach(cookie => {
      const [name, value] = cookie.trim().split('=');
      if (name && value) {
        cookies[name] = decodeURIComponent(value);
      }
    });
  }
  return cookies;
}

/**
 * 清除所有cookie
 * @param {string} path - 路径
 * @param {string} domain - 域名
 */
export function clearAllCookies(path = '/', domain) {
  const cookies = getAllCookies();
  Object.keys(cookies).forEach(name => {
    removeCookie(name, path, domain);
  });
}

/**
 * Token相关的cookie操作
 */
export const tokenCookie = {
  /**
   * 设置token到cookie
   * @param {string} token - JWT token
   * @param {number} maxAge - 过期时间（秒），默认7天
   */
  set(token, maxAge = 7 * 24 * 60 * 60) {
    setCookie('token', token, {
      maxAge,
      path: '/',
      secure: false, // 开发环境设为false，生产环境应设为true
      httpOnly: false, // 前端需要访问，设为false
      sameSite: 'Lax',
    });
  },

  /**
   * 获取token
   * @returns {string|null} token值
   */
  get() {
    return getCookie('token');
  },

  /**
   * 删除token
   */
  remove() {
    removeCookie('token');
  },

  /**
   * 检查token是否存在
   * @returns {boolean} 是否存在
   */
  exists() {
    return hasCookie('token');
  },
};

/**
 * 用户信息相关的cookie操作
 */
export const userInfoCookie = {
  /**
   * 设置用户信息到cookie
   * @param {object} userInfo - 用户信息对象
   * @param {number} maxAge - 过期时间（秒），默认7天
   */
  set(userInfo, maxAge = 7 * 24 * 60 * 60) {
    const userInfoString = JSON.stringify(userInfo);
    setCookie('userInfo', userInfoString, {
      maxAge,
      path: '/',
      secure: false,
      httpOnly: false,
      sameSite: 'Lax',
    });
  },

  /**
   * 获取用户信息
   * @returns {object|null} 用户信息对象
   */
  get() {
    const userInfoString = getCookie('userInfo');
    if (userInfoString) {
      try {
        return JSON.parse(userInfoString);
      } catch (error) {
        console.error('解析用户信息失败:', error);
        return null;
      }
    }
    return null;
  },

  /**
   * 删除用户信息
   */
  remove() {
    removeCookie('userInfo');
  },

  /**
   * 检查用户信息是否存在
   * @returns {boolean} 是否存在
   */
  exists() {
    return hasCookie('userInfo');
  },
};

/**
 * 认证相关的cookie操作
 */
export const authCookie = {
  /**
   * 设置认证信息
   * @param {string} token - JWT token
   * @param {object} userInfo - 用户信息
   * @param {number} maxAge - 过期时间（秒），默认7天
   */
  setAuth(token, userInfo, maxAge = 7 * 24 * 60 * 60) {
    tokenCookie.set(token, maxAge);
    if (userInfo) {
      userInfoCookie.set(userInfo, maxAge);
    }
  },

  /**
   * 获取认证信息
   * @returns {object} 包含token和userInfo的对象
   */
  getAuth() {
    return {
      token: tokenCookie.get(),
      userInfo: userInfoCookie.get(),
    };
  },

  /**
   * 清除认证信息
   */
  clearAuth() {
    tokenCookie.remove();
    userInfoCookie.remove();
  },

  /**
   * 检查是否已认证
   * @returns {boolean} 是否已认证
   */
  isAuthenticated() {
    return tokenCookie.exists();
  },
};
