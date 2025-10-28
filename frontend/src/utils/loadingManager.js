/**
 * 全局Loading管理器
 * 管理所有HTTP请求的loading状态
 */

import { reactive, ref } from 'vue';

/* global setTimeout */

// 全局loading状态
const globalLoading = ref(false);
const loadingCount = ref(0);
const loadingText = ref('正在加载数据...');
const loadingRequests = reactive(new Set());

// 最小显示时间（毫秒）
const MIN_DISPLAY_TIME = 300; // 800ms 最小显示时间
const loadingStartTime = ref(null);

/**
 * 开始loading
 * @param {string} requestId - 请求唯一标识
 * @param {string} text - 自定义loading文字
 */
export function startLoading(requestId = null, text = '正在加载数据...') {
  loadingCount.value++;
  globalLoading.value = true;

  // 只有在没有自定义文字时才更新文字，或者当前文字是默认文字时才更新
  if (loadingCount.value === 1 || loadingText.value === '正在加载数据...') {
    loadingText.value = text;
  }

  if (requestId) {
    loadingRequests.add(requestId);
  }

  // 记录开始时间
  if (!loadingStartTime.value) {
    loadingStartTime.value = Date.now();
  }

  console.log(`🔄 Loading started. Count: ${loadingCount.value}, Text: ${loadingText.value}`);
}

/**
 * 结束loading
 * @param {string} requestId - 请求唯一标识
 */
export function stopLoading(requestId = null) {
  loadingCount.value = Math.max(0, loadingCount.value - 1);

  if (requestId) {
    loadingRequests.delete(requestId);
  }

  // 当所有请求都完成时，检查最小显示时间
  if (loadingCount.value === 0) {
    const elapsedTime = Date.now() - (loadingStartTime.value || Date.now());
    const remainingTime = Math.max(0, MIN_DISPLAY_TIME - elapsedTime);

    if (remainingTime > 0) {
      // 延迟关闭loading，确保最小显示时间
      setTimeout(() => {
        globalLoading.value = false;
        loadingStartTime.value = null;
        loadingText.value = '正在加载数据...'; // 重置文字
        console.log(`✅ Loading stopped with delay. Count: ${loadingCount.value}`);
      }, remainingTime);
    } else {
      // 立即关闭loading
      globalLoading.value = false;
      loadingStartTime.value = null;
      loadingText.value = '正在加载数据...'; // 重置文字
      console.log(`✅ Loading stopped immediately. Count: ${loadingCount.value}`);
    }
  }

  console.log(`✅ Loading stopped. Count: ${loadingCount.value}`);
}

/**
 * 获取全局loading状态
 * @returns {boolean} loading状态
 */
export function isLoading() {
  return globalLoading.value;
}

/**
 * 获取loading计数
 * @returns {number} loading计数
 */
export function getLoadingCount() {
  return loadingCount.value;
}

/**
 * 获取正在进行的请求列表
 * @returns {Array} 请求列表
 */
export function getLoadingRequests() {
  return Array.from(loadingRequests);
}

/**
 * 清除所有loading状态
 */
export function clearAllLoading() {
  loadingCount.value = 0;
  globalLoading.value = false;
  loadingRequests.clear();
  loadingStartTime.value = null;
  console.log('🧹 All loading cleared');
}

// 导出响应式状态供组件使用
export { globalLoading, loadingCount, loadingRequests, loadingText };
