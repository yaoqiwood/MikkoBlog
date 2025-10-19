/**
 * 日志管理工具
 * 在生产环境下自动禁用 console.log 输出
 */

const isDevelopment = import.meta.env.DEV;
const isProduction = import.meta.env.PROD;

class Logger {
  constructor() {
    this.enabled = isDevelopment;
  }

  /**
   * 普通日志
   * @param {...any} args
   */
  log(...args) {
    if (this.enabled) {
      console.log(...args);
    }
  }

  /**
   * 信息日志
   * @param {...any} args
   */
  info(...args) {
    if (this.enabled) {
      console.info(...args);
    }
  }

  /**
   * 警告日志
   * @param {...any} args
   */
  warn(...args) {
    if (this.enabled) {
      console.warn(...args);
    }
  }

  /**
   * 错误日志（生产环境也会输出）
   * @param {...any} args
   */
  error(...args) {
    console.error(...args);
  }

  /**
   * 调试日志
   * @param {...any} args
   */
  debug(...args) {
    if (this.enabled) {
      console.debug(...args);
    }
  }

  /**
   * HTTP 请求日志
   * @param {string} method
   * @param {string} url
   * @param {any} data
   */
  http(method, url, data = null) {
    if (this.enabled) {
      console.log(`🚀 [${method.toUpperCase()}] ${url}`, data);
    }
  }

  /**
   * HTTP 响应日志
   * @param {string} method
   * @param {string} url
   * @param {number} duration
   * @param {any} data
   */
  httpResponse(method, url, duration, data = null) {
    if (this.enabled) {
      console.log(`✅ [${method.toUpperCase()}] ${url} - ${duration}ms`, data);
    }
  }

  /**
   * 音乐播放器日志
   * @param {string} action
   * @param {...any} args
   */
  music(action, ...args) {
    if (this.enabled) {
      console.log(`🎵 [MusicPlayer] ${action}`, ...args);
    }
  }

  /**
   * 组件日志
   * @param {string} component
   * @param {string} action
   * @param {...any} args
   */
  component(component, action, ...args) {
    if (this.enabled) {
      console.log(`🔧 [${component}] ${action}`, ...args);
    }
  }
}

// 创建单例实例
const logger = new Logger();

// 导出实例和类
export default logger;
export { Logger };

// 为了向后兼容，也可以导出常用的方法
export const { log, info, warn, error, debug, http, httpResponse, music, component } = logger;

