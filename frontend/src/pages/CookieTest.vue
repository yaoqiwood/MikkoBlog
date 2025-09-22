<template>
  <div class="cookie-test">
    <div class="test-container">
      <h1>Cookie检测测试</h1>

      <div class="test-section">
        <h2>当前状态</h2>
        <div class="status-info">
          <div class="status-item">
            <strong>LocalStorage Token:</strong>
            <span :class="localStorageToken ? 'status-valid' : 'status-invalid'">
              {{ localStorageToken || '无' }}
            </span>
          </div>
          <div class="status-item">
            <strong>Cookie Token:</strong>
            <span :class="cookieToken ? 'status-valid' : 'status-invalid'">
              {{ cookieToken || '无' }}
            </span>
          </div>
          <div class="status-item">
            <strong>Cookie UserInfo:</strong>
            <pre v-if="userInfo" class="user-info-display">{{ userInfo }}</pre>
            <span v-else class="status-invalid">无</span>
          </div>
        </div>
      </div>

      <div class="test-section">
        <h2>测试操作</h2>
        <div class="test-buttons">
          <Button type="primary" @click="setTestToken">设置测试Token</Button>
          <Button type="success" @click="setTestCookie">设置测试Cookie</Button>
          <Button type="warning" @click="clearAll">清除所有</Button>
          <Button type="info" @click="goToLogin">测试登录页面</Button>
        </div>
      </div>

      <div class="test-section">
        <h2>说明</h2>
        <div class="explanation">
          <p>1. 点击"设置测试Token"会在localStorage中设置一个测试token（用于对比）</p>
          <p>2. 点击"设置测试Cookie"会在cookie中设置一个测试token和用户信息</p>
          <p>3. 点击"测试登录页面"会跳转到登录页面，测试自动登录功能</p>
          <p>4. 如果检测到有效的token，会自动跳转到后台管理页面</p>
          <p>5. 现在系统使用cookie存储认证信息，不再依赖localStorage</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { authCookie } from '@/utils/cookieUtils';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const localStorageToken = ref('');
const cookieToken = ref('');
const userInfo = ref('');

// 更新状态显示
function updateStatus() {
  // 检查localStorage（为了对比）
  localStorageToken.value = localStorage.getItem('token') || '';

  // 检查cookie中的认证信息
  const auth = authCookie.getAuth();
  cookieToken.value = auth.token || '';
  userInfo.value = auth.userInfo ? JSON.stringify(auth.userInfo, null, 2) : '';
}

// 设置测试token
function setTestToken() {
  localStorage.setItem('token', 'test-token-' + Date.now());
  updateStatus();
  Message.success('已设置测试Token到LocalStorage');
}

// 设置测试cookie
function setTestCookie() {
  const token = 'test-cookie-token-' + Date.now();
  const userInfo = {
    email: 'test@example.com',
    is_admin: true,
  };

  authCookie.setAuth(token, userInfo);
  updateStatus();
  Message.success('已设置测试Token到Cookie');
}

// 清除所有
function clearAll() {
  localStorage.removeItem('token');
  localStorage.removeItem('userInfo');
  authCookie.clearAuth();
  updateStatus();
  Message.info('已清除所有Token');
}

// 跳转到登录页面
function goToLogin() {
  router.push('/login');
}

onMounted(() => {
  updateStatus();
});
</script>

<style scoped>
.cookie-test {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 2rem;
}

.test-container {
  max-width: 800px;
  margin: 0 auto;
  background: white;
  padding: 2rem;
  border-radius: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.test-container h1 {
  text-align: center;
  color: #2d3748;
  margin-bottom: 2rem;
}

.test-section {
  margin-bottom: 2rem;
}

.test-section h2 {
  color: #4a5568;
  margin-bottom: 1rem;
  border-bottom: 2px solid #e2e8f0;
  padding-bottom: 0.5rem;
}

.status-info {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.5rem;
  border: 1px solid #e9ecef;
}

.status-item {
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.status-item strong {
  min-width: 150px;
  color: #2d3748;
}

.status-valid {
  color: #38a169;
  font-weight: 600;
}

.status-invalid {
  color: #e53e3e;
  font-style: italic;
}

.user-info-display {
  background: #f7fafc;
  border: 1px solid #e2e8f0;
  border-radius: 0.375rem;
  padding: 0.75rem;
  font-size: 0.875rem;
  color: #2d3748;
  margin: 0;
  white-space: pre-wrap;
  word-break: break-all;
  max-width: 100%;
  overflow-x: auto;
}

.test-buttons {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.test-buttons .ivu-btn {
  min-width: 120px;
}

.explanation {
  background: #f0f4ff;
  padding: 1rem;
  border-radius: 0.5rem;
  border: 1px solid #c7d2fe;
}

.explanation p {
  margin-bottom: 0.5rem;
  color: #4a5568;
  line-height: 1.5;
}

.explanation p:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .cookie-test {
    padding: 1rem;
  }

  .test-container {
    padding: 1rem;
  }

  .test-buttons {
    flex-direction: column;
  }

  .test-buttons .ivu-btn {
    width: 100%;
  }

  .status-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .status-item strong {
    min-width: auto;
  }
}
</style>
