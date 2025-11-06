<template>
  <div class="page-container login-container">
    <div class="login-wrapper">
      <div class="login-card">
        <div class="login-content">
          <!-- Left Side - Brand/Icon Section -->
          <div class="brand-section">
            <div class="brand-content">
              <!-- Main Icon -->
              <div class="main-icon">
                <div class="icon-circle">
                  <svg class="icon-svg" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
                    />
                  </svg>
                </div>
              </div>

              <!-- Brand Text -->
              <h1 class="brand-title">MikkoBlog</h1>
              <p class="brand-subtitle">管理员登录</p>

              <!-- Decorative Elements -->
              <div class="decorative-section">
                <div class="dots-container">
                  <div class="dot dot-fade" />
                  <div class="dot dot-full" />
                  <div class="dot dot-fade" />
                </div>
                <p class="decorative-text">安全 · 高效 · 专业</p>
              </div>
            </div>
          </div>

          <!-- Right Side - Login Form -->
          <div class="form-section">
            <div class="form-wrapper">
              <div class="form-header">
                <h2 class="form-title">欢迎回来</h2>
                <p class="form-subtitle">请登录您的管理员账户</p>
                <!-- 检查登录状态提示 -->
                <div v-if="checkingAuth" class="auth-checking">
                  <Icon type="ios-loading" class="loading-icon" />
                  <span>正在检查登录状态...</span>
                </div>
              </div>

              <Form :model="loginModel" :rules="loginRules" @submit.prevent="login">
                <!-- Email Field -->
                <FormItem label="邮箱地址" prop="email">
                  <Input
                    v-model="loginModel.email"
                    type="email"
                    size="large"
                    placeholder="请输入邮箱地址"
                    prefix="ios-mail"
                  />
                </FormItem>

                <!-- Password Field -->
                <FormItem label="密码" prop="password">
                  <Input
                    v-model="loginModel.password"
                    type="password"
                    size="large"
                    placeholder="请输入密码"
                    prefix="ios-lock"
                  />
                </FormItem>

                <!-- Captcha Field (show when required) -->
                <FormItem v-if="captchaRequired" label="" prop="captcha">
                  <div class="captcha-row">
                    <Input
                      v-model="captchaCode"
                      type="text"
                      size="large"
                      placeholder="请输入右侧4位验证码"
                      maxlength="4"
                      style="flex: 1"
                    />
                    <img
                      :src="captchaImageSrc"
                      class="captcha-image"
                      @click="refreshCaptcha"
                      alt="captcha"
                    />
                  </div>
                </FormItem>

                <!-- Error Message -->
                <Alert v-if="error" type="error" show-icon>
                  {{ error }}
                </Alert>

                <!-- Save Credentials Checkbox -->
                <FormItem>
                  <Checkbox v-model="saveCredentials">
                    <span class="save-credentials-text">保存账号密码</span>
                  </Checkbox>
                </FormItem>

                <!-- Login Button -->
                <FormItem>
                  <Button
                    type="primary"
                    size="large"
                    :loading="loading"
                    html-type="submit"
                    long
                    icon="ios-log-in"
                  >
                    {{ loading ? '登录中...' : '登录' }}
                  </Button>
                </FormItem>
              </Form>
              <!-- Footer -->
              <div class="form-footer">
                <router-link :to="homePath" class="back-link"> ← 返回首页 </router-link>
              </div>

              <!-- Additional Info -->
              <div class="form-info">
                <p class="info-text">请妥善保管您的账户信息</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { getAuthUrl } from '@/utils/apiConfig';
import { authApi } from '@/utils/apiService';
import { authCookie } from '@/utils/cookieUtils';
import { getRoutePath, routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { computed, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const loginModel = ref({
  email: '',
  password: '',
});
const error = ref('');
const loading = ref(false);
const checkingAuth = ref(false);
const saveCredentials = ref(false);

// 验证码控制
const captchaRequired = ref(false);
const captchaCode = ref('');
const captchaRefreshKey = ref(0);
const captchaImageSrc = computed(
  () => `${getAuthUrl('CAPTCHA')}?t=${Date.now()}&k=${captchaRefreshKey.value}`
);

// 路由路径常量
const homePath = getRoutePath(ROUTES.HOME);

const loginRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' },
  ],
};

function refreshCaptcha() {
  captchaRefreshKey.value++;
}

// 检查登录状态
function checkLoginStatus() {
  // 检查cookie中的token
  const auth = authCookie.getAuth();

  if (auth.token) {
    // 验证token是否有效
    validateToken();
  }
}

// 验证token有效性
async function validateToken() {
  checkingAuth.value = true;
  try {
    // 调用API验证token有效性
    const response = await authApi.getMe();
    if (response) {
      Message.info('检测到已登录状态，正在跳转...');
      // 延迟一下让用户看到提示信息
      window.setTimeout(() => {
        routerUtils.navigateTo(router, ROUTES.ADMIN_DASHBOARD);
      }, 1000);
    }
  } catch (error) {
    console.error('Token验证失败:', error);
    // 如果token无效，清除cookie
    authCookie.clearAuth();

    // 根据错误类型显示不同的提示信息
    if (error.type === 'NETWORK_ERROR') {
      Message.warning('服务器连接失败，请检查后端服务状态');
    } else {
      Message.warning('登录状态已过期，请重新登录');
    }
  } finally {
    checkingAuth.value = false;
  }
}

// 加载保存的账号密码
function loadSavedCredentials() {
  try {
    const savedCredentials = localStorage.getItem('savedCredentials');
    if (savedCredentials) {
      const credentials = JSON.parse(savedCredentials);
      loginModel.value.email = credentials.email || '';
      saveCredentials.value = true; // 如果有保存的账号密码，默认勾选保存选项
    }
  } catch (error) {
    console.error('加载保存的账号密码失败:', error);
    // 如果解析失败，清除无效数据
    localStorage.removeItem('savedCredentials');
  }
}

// 页面加载时检查登录状态
onMounted(() => {
  checkLoginStatus();
  loadSavedCredentials();
});

async function login() {
  try {
    loading.value = true;
    error.value = '';

    const username = loginModel.value.email;

    // 使用新的API工具进行登录
    const data = await authApi.login(
      username,
      loginModel.value.password,
      captchaRequired.value ? captchaCode.value : null
    );

    // 将token保存到cookie
    authCookie.setAuth(data.access_token, {
      email: username,
      is_admin: true,
    });

    // 如果用户选择保存账号密码，则保存到localStorage
    if (saveCredentials.value) {
      const credentials = {
        email: loginModel.value.email,
      };
      localStorage.setItem('savedCredentials', JSON.stringify(credentials));
    } else {
      // 如果不保存，清除之前保存的账号密码
      localStorage.removeItem('savedCredentials');
    }

    Message.success('登录成功！');
    routerUtils.navigateTo(router, ROUTES.ADMIN_DASHBOARD);
  } catch (err) {
    // 根据错误类型显示不同的错误信息
    if (err.type === 'NETWORK_ERROR') {
      error.value = '服务器无法连接，请联系管理员';
      Message.error('服务器无法连接，请联系管理员');
    } else if (err.response?.status === 403) {
      // 处理验证码相关的错误
      const detail = err.response?.data?.detail;
      if (detail === 'CAPTCHA_INCORRECT') {
        // 验证码输入错误
        captchaRequired.value = true;
        error.value = '验证码输入错误，请检查';
        Message.error('验证码输入错误，请检查');
        refreshCaptcha();
      } else if (detail === 'CAPTCHA_REQUIRED') {
        // 未提供验证码或首次显示验证码
        captchaRequired.value = true;
        // 检查是否已经输入了验证码（但可能为空）
        if (!captchaCode.value || !captchaCode.value.trim()) {
          error.value = '请输入验证码';
          Message.warning('请输入验证码');
        } else {
          error.value = '需要输入验证码后再尝试登录';
          Message.warning('需要输入验证码后再尝试登录');
        }
        refreshCaptcha();
      }
    } else if (err.response?.status === 401) {
      error.value = '用户名或密码错误';
      Message.error('用户名或密码错误');
      // 如果验证码已经显示，每次登录失败时都要刷新验证码
      if (captchaRequired.value) {
        refreshCaptcha();
      }
    } else if (err.response?.status === 422) {
      error.value = '输入格式不正确，请检查用户名/邮箱和密码';
      Message.error('输入格式不正确，请检查用户名/邮箱和密码');
      // 如果验证码已经显示，每次登录失败时都要刷新验证码
      if (captchaRequired.value) {
        refreshCaptcha();
      }
    } else {
      error.value = '登录失败，请稍后重试';
      Message.error('登录失败，请稍后重试');
      // 如果验证码已经显示，每次登录失败时都要刷新验证码
      if (captchaRequired.value) {
        refreshCaptcha();
      }
    }
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.login-container {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #eff6ff 0%, #ffffff 50%, #e0e7ff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  margin: 0;
  position: fixed;
  top: 0;
  left: 0;
}

.login-wrapper {
  width: 100%;
  max-width: 75rem;
}

.login-card {
  background: white;
  border-radius: 1.5rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  border: 1px solid #f3f4f6;
  overflow: hidden;
}

.login-content {
  display: flex;
  min-height: 600px;
}

.brand-section {
  flex: 1;
  background: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem;
}

.brand-content {
  text-align: center;
  color: white;
}

.main-icon {
  margin-bottom: 2rem;
}

.icon-circle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 6rem;
  height: 6rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(8px);
  border-radius: 1.5rem;
}

.icon-svg {
  width: 3rem;
  height: 3rem;
  color: white;
}

.brand-title {
  font-size: 2.5rem;
  font-weight: bold;
  margin-bottom: 1rem;
}

.brand-subtitle {
  font-size: 1.25rem;
  color: #dbeafe;
  margin-bottom: 2rem;
}

.decorative-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.dots-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.dot {
  width: 0.5rem;
  height: 0.5rem;
  border-radius: 50%;
}

.dot-fade {
  background: rgba(255, 255, 255, 0.6);
}

.dot-full {
  background: white;
}

.decorative-text {
  color: #bfdbfe;
  font-size: 0.875rem;
}

.form-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3rem;
}

.form-wrapper {
  width: 100%;
  max-width: 28rem;
}

.form-header {
  text-align: center;
  margin-bottom: 2rem;
}

.form-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #111827;
  margin-bottom: 0.5rem;
}

.form-subtitle {
  color: #6b7280;
}

.auth-checking {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 1rem;
  padding: 0.75rem;
  background: #f0f9ff;
  border: 1px solid #0ea5e9;
  border-radius: 0.5rem;
  color: #0369a1;
  font-size: 0.875rem;
}

.loading-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.form-footer {
  margin-top: 2rem;
  text-align: center;
}

.back-link {
  font-size: 0.875rem;
  color: #6b7280;
  text-decoration: none;
  transition: color 0.2s;
}

.back-link:hover {
  color: #2563eb;
}

.form-info {
  margin-top: 1.5rem;
  text-align: center;
}

.info-text {
  font-size: 0.75rem;
  color: #6b7280;
}

.captcha-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.captcha-image {
  height: 40px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  cursor: pointer;
}

/* 保存账号密码样式 */
.save-credentials-text {
  font-size: 14px;
  color: #6b7280;
  user-select: none;
}

.ivu-checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ivu-checkbox {
  margin-right: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .login-content {
    flex-direction: column;
    min-height: auto;
  }

  .brand-section {
    padding: 2rem;
  }

  .form-section {
    padding: 2rem;
  }

  .brand-title {
    font-size: 2rem;
  }

  .brand-subtitle {
    font-size: 1rem;
  }
}
</style>
