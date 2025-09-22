<template>
  <div class="loading-test-page">
    <div class="page-header">
      <h1 class="page-title">Loading 测试页面</h1>
      <p class="page-description">测试全局自动 loading 功能</p>
    </div>

    <div class="test-section">
      <Card>
        <template #title>
          <Icon type="ios-flask" />
          API 请求测试
        </template>

        <div class="test-buttons">
          <Button type="primary" @click="testUserApi" :loading="testing">
            <Icon type="ios-people" />
            测试用户 API
          </Button>

          <Button type="success" @click="testMultipleRequests" :loading="testingMultiple">
            <Icon type="ios-refresh" />
            测试多个并发请求
          </Button>

          <Button type="warning" @click="testSlowRequest" :loading="testingSlow">
            <Icon type="ios-time" />
            测试慢请求 (3秒)
          </Button>

          <Button type="info" @click="testQuickRequest" :loading="testingQuick">
            <Icon type="ios-flash" />
            测试快速请求 (最小显示800ms)
          </Button>

          <Button type="default" @click="testDirectLoading" :loading="testingDirect">
            <Icon type="ios-bug" />
            直接测试 Loading (3秒)
          </Button>

          <Button type="error" @click="testErrorRequest" :loading="testingError">
            <Icon type="ios-close-circle" />
            测试错误请求
          </Button>
        </div>

        <div class="test-results" v-if="results.length > 0">
          <h3>测试结果:</h3>
          <div v-for="(result, index) in results" :key="index" class="result-item">
            <Tag :color="result.success ? 'success' : 'error'">
              {{ result.success ? '成功' : '失败' }}
            </Tag>
            <span>{{ result.message }}</span>
            <span class="result-time">{{ result.time }}</span>
          </div>
        </div>
      </Card>

      <Card>
        <template #title>
          <Icon type="ios-settings" />
          Loading 状态监控
        </template>

        <div class="status-info">
          <div class="status-item">
            <strong>全局 Loading 状态:</strong>
            <Tag :color="globalLoading ? 'processing' : 'default'">
              {{ globalLoading ? '加载中' : '空闲' }}
            </Tag>
          </div>

          <div class="status-item">
            <strong>Loading 计数:</strong>
            <span class="count">{{ loadingCount }}</span>
          </div>

          <div class="status-item" v-if="loadingRequests.length > 0">
            <strong>进行中的请求:</strong>
            <div class="requests-list">
              <Tag v-for="request in loadingRequests" :key="request" color="blue" size="small">
                {{ request }}
              </Tag>
            </div>
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>

<script setup>
import { userApi } from '@/utils/apiService';
import { globalLoading, loadingCount, loadingRequests } from '@/utils/loadingManager';
import { Message } from 'view-ui-plus';
import { ref } from 'vue';

const testing = ref(false);
const testingMultiple = ref(false);
const testingSlow = ref(false);
const testingQuick = ref(false);
const testingDirect = ref(false);
const testingError = ref(false);
const results = ref([]);

// 测试用户 API
async function testUserApi() {
  testing.value = true;
  const startTime = new Date();

  try {
    const users = await userApi.getUsers();
    const duration = new Date() - startTime;

    results.value.unshift({
      success: true,
      message: `获取用户列表成功，共 ${users.length} 个用户`,
      time: `${duration}ms`,
    });

    Message.success('用户 API 测试成功！');
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `用户 API 测试失败: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.error('用户 API 测试失败！');
  } finally {
    testing.value = false;
  }
}

// 测试多个并发请求
async function testMultipleRequests() {
  testingMultiple.value = true;
  const startTime = new Date();

  try {
    // 同时发起多个请求
    const promises = [userApi.getUsers(), userApi.getUsers(), userApi.getUsers()];

    const results_data = await Promise.all(promises);
    const duration = new Date() - startTime;

    results.value.unshift({
      success: true,
      message: `并发请求测试成功，共 ${results_data.length} 个请求`,
      time: `${duration}ms`,
    });

    Message.success('并发请求测试成功！');
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `并发请求测试失败: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.error('并发请求测试失败！');
  } finally {
    testingMultiple.value = false;
  }
}

// 测试慢请求
async function testSlowRequest() {
  testingSlow.value = true;
  const startTime = new Date();

  try {
    // 先发起API请求，这样loading会立即开始
    const usersPromise = userApi.getUsers();

    // 然后等待3秒，让loading显示更长时间
    await new Promise(resolve => setTimeout(resolve, 3000));

    // 等待API请求完成
    const users = await usersPromise;
    const duration = new Date() - startTime;

    results.value.unshift({
      success: true,
      message: `慢请求测试成功，共 ${users.length} 个用户`,
      time: `${duration}ms`,
    });

    Message.success('慢请求测试成功！');
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `慢请求测试失败: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.error('慢请求测试失败！');
  } finally {
    testingSlow.value = false;
  }
}

// 测试快速请求（验证最小显示时间）
async function testQuickRequest() {
  testingQuick.value = true;
  const startTime = new Date();

  try {
    // 快速请求，但loading会显示至少800ms
    const users = await userApi.getUsers();
    const duration = new Date() - startTime;

    results.value.unshift({
      success: true,
      message: `快速请求测试成功，共 ${users.length} 个用户（实际请求时间: ${duration}ms，但loading显示至少800ms）`,
      time: `${duration}ms`,
    });

    Message.success('快速请求测试成功！注意loading显示时间');
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `快速请求测试失败: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.error('快速请求测试失败！');
  } finally {
    testingQuick.value = false;
  }
}

// 直接测试 Loading（不通过API）
async function testDirectLoading() {
  testingDirect.value = true;
  const startTime = new Date();

  try {
    // 直接导入并调用 loading 函数
    const { startLoading, stopLoading } = await import('@/utils/loadingManager');

    console.log('开始直接测试 loading...');
    console.log('当前 globalLoading 状态:', globalLoading.value);

    // 开始 loading
    startLoading('direct_test');
    console.log('调用 startLoading 后 globalLoading 状态:', globalLoading.value);

    // 等待3秒
    await new Promise(resolve => setTimeout(resolve, 3000));

    // 结束 loading
    stopLoading('direct_test');
    console.log('调用 stopLoading 后 globalLoading 状态:', globalLoading.value);

    const duration = new Date() - startTime;

    results.value.unshift({
      success: true,
      message: `直接 Loading 测试成功，显示时间: ${duration}ms`,
      time: `${duration}ms`,
    });

    Message.success('直接 Loading 测试成功！');
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `直接 Loading 测试失败: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.error('直接 Loading 测试失败！');
  } finally {
    testingDirect.value = false;
  }
}

// 测试错误请求
async function testErrorRequest() {
  testingError.value = true;
  const startTime = new Date();

  try {
    // 故意请求一个不存在的接口
    await userApi.getUsers({ invalid: true });
  } catch (error) {
    const duration = new Date() - startTime;

    results.value.unshift({
      success: false,
      message: `错误请求测试完成: ${error.message}`,
      time: `${duration}ms`,
    });

    Message.info('错误请求测试完成（这是预期的）');
  } finally {
    testingError.value = false;
  }
}
</script>

<style scoped>
.loading-test-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.page-header {
  text-align: center;
  margin-bottom: 2rem;
}

.page-title {
  font-size: 2rem;
  font-weight: bold;
  color: #2d3748;
  margin: 0 0 0.5rem 0;
}

.page-description {
  color: #718096;
  font-size: 1.1rem;
  margin: 0;
}

.test-section {
  display: grid;
  gap: 1.5rem;
}

.test-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.test-results {
  margin-top: 1rem;
}

.result-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e8eaec;
}

.result-item:last-child {
  border-bottom: none;
}

.result-time {
  margin-left: auto;
  color: #999;
  font-size: 0.9rem;
}

.status-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.count {
  font-weight: bold;
  color: #667eea;
  font-size: 1.2rem;
}

.requests-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .test-buttons {
    grid-template-columns: 1fr;
  }

  .page-title {
    font-size: 1.5rem;
  }

  .loading-test-page {
    padding: 1rem 0.5rem;
  }
}
</style>
