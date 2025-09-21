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
              </div>

              <Form :model="loginModel" :rules="loginRules" @submit.prevent="login">
                <!-- Email or Username Field -->
                <FormItem v-if="loginType === 'email'" label="邮箱地址" prop="email">
                  <Input
                    v-model="loginModel.email"
                    type="email"
                    size="large"
                    placeholder="admin@example.com"
                    prefix="ios-mail"
                  />
                </FormItem>
                <FormItem v-else label="用户名" prop="username">
                  <Input
                    v-model="loginModel.username"
                    type="text"
                    size="large"
                    placeholder="admin"
                    prefix="ios-person"
                  />
                </FormItem>

                <!-- Password Field -->
                <FormItem label="密码" prop="password">
                  <Input
                    v-model="loginModel.password"
                    type="password"
                    size="large"
                    placeholder="••••••••"
                    prefix="ios-lock"
                  />
                </FormItem>

                <!-- Error Message -->
                <Alert v-if="error" type="error" show-icon>
                  {{ error }}
                </Alert>

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
              <!-- 切换登录方式 -->
              <div class="login-type-switch" style="text-align: center; margin-bottom: 12px">
                <Button type="text" size="small" @click="toggleLoginType">
                  切换为{{ loginType === 'email' ? '用户名' : '邮箱' }}登录
                </Button>
              </div>

              <!-- Footer -->
              <div class="form-footer">
                <router-link :to="homePath" class="back-link"> ← 返回首页 </router-link>
              </div>

              <!-- Additional Info -->
              <div class="form-info">
                <p class="info-text">默认管理员账号：admin@example.com / admin123</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { authApi } from '@/utils/apiService';
import { getRoutePath, routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const loginType = ref('email'); // 'email' or 'username'
const loginModel = ref({
  email: 'admin@example.com',
  username: 'admin',
  password: 'admin123',
});
const error = ref('');
const loading = ref(false);

// 路由路径常量
const homePath = getRoutePath(ROUTES.HOME);

const loginRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, message: '用户名长度不能少于3位', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' },
  ],
};

function toggleLoginType() {
  loginType.value = loginType.value === 'email' ? 'username' : 'email';
}

async function login() {
  try {
    loading.value = true;
    error.value = '';

    // 根据登录类型使用不同的用户名字段
    const username =
      loginType.value === 'email' ? loginModel.value.email : loginModel.value.username;

    // 使用新的API工具进行登录
    const data = await authApi.login(username, loginModel.value.password);

    localStorage.setItem('token', data.access_token);
    Message.success('登录成功！');
    routerUtils.navigateTo(router, ROUTES.ADMIN_DASHBOARD);
  } catch {
    error.value = '登录失败，请检查用户名/邮箱和密码';
    Message.error('登录失败，请检查用户名/邮箱和密码');
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
