<template>
  <div class="not-found-container">
    <div class="not-found-wrapper">
      <div class="not-found-content">
        <!-- 左侧：错误信息区域 -->
        <div class="left-section">
          <div class="error-section">
            <div class="error-icon">
              <Icon type="ios-warning" size="140" color="#ff6b6b" />
            </div>
            <div class="error-number">404</div>
            <div class="error-text">页面未找到</div>
          </div>

          <div class="description-section">
            <h2 class="description-title">抱歉，您访问的页面不存在</h2>
            <p class="description-text">
              您访问的页面可能已被删除、重命名或暂时不可用。请检查URL是否正确，或使用下方的导航链接。
            </p>
          </div>
        </div>

        <!-- 右侧：操作和帮助区域 -->
        <div class="right-section">
          <div class="action-section">
            <h3 class="section-title">快速操作</h3>
            <div class="button-group">
              <Button
                type="primary"
                size="large"
                icon="ios-home"
                @click="goHome"
                class="action-button primary-button"
              >
                返回首页
              </Button>
              <Button
                type="default"
                size="large"
                icon="ios-arrow-back"
                @click="goBack"
                class="action-button secondary-button"
              >
                返回上页
              </Button>
            </div>
          </div>

          <div class="help-section">
            <h3 class="section-title">
              <Icon type="ios-help-circle" />
              导航菜单
            </h3>
            <div class="help-links">
              <router-link :to="getRoutePath(ROUTES.LOGIN)" class="help-link">
                <div class="help-link-content">
                  <Icon type="ios-log-in" size="24" />
                  <div class="help-link-text">
                    <div class="help-link-title">登录页面</div>
                    <div class="help-link-desc">访问管理员登录</div>
                  </div>
                </div>
              </router-link>
              <router-link :to="getRoutePath(ROUTES.ADMIN_USERS)" class="help-link">
                <div class="help-link-content">
                  <Icon type="ios-people" size="24" />
                  <div class="help-link-text">
                    <div class="help-link-title">用户管理</div>
                    <div class="help-link-desc">管理系统用户</div>
                  </div>
                </div>
              </router-link>
              <router-link :to="getRoutePath(ROUTES.TEST_VIEWUI)" class="help-link">
                <div class="help-link-content">
                  <Icon type="ios-apps" size="24" />
                  <div class="help-link-text">
                    <div class="help-link-title">组件测试</div>
                    <div class="help-link-desc">View UI 组件展示</div>
                  </div>
                </div>
              </router-link>
            </div>
          </div>
        </div>

        <!-- 装饰性元素 -->
        <div class="decoration-section">
          <div class="floating-elements">
            <div class="floating-dot dot-1"></div>
            <div class="floating-dot dot-2"></div>
            <div class="floating-dot dot-3"></div>
            <div class="floating-dot dot-4"></div>
            <div class="floating-dot dot-5"></div>
            <div class="floating-dot dot-6"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { getRoutePath, routerUtils, ROUTES } from '@/utils/routeManager';
import { useRouter } from 'vue-router';

const router = useRouter();

// 返回首页
function goHome() {
  routerUtils.navigateTo(router, ROUTES.HOME);
}

// 返回上一页
function goBack() {
  if (window.history.length > 1) {
    router.go(-1);
  } else {
    routerUtils.navigateTo(router, ROUTES.HOME);
  }
}
</script>

<style scoped>
.not-found-container {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  margin: 0;
  position: fixed;
  top: 0;
  left: 0;
  overflow: hidden;
}

.not-found-wrapper {
  width: 100%;
  max-width: 100%;
  padding: 0;
  margin: 0;
}

.not-found-content {
  background: white;
  border-radius: 1.5rem;
  padding: 3rem 2rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  position: relative;
  z-index: 10;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: start;
  min-height: 500px;
  max-width: 100%;
}

/* 左侧区域 */
.left-section {
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: center;
}

/* 右侧区域 */
.right-section {
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

/* 错误区域 */
.error-section {
  margin-bottom: 3rem;
}

.error-icon {
  margin-bottom: 2rem;
  animation: bounce 2s infinite;
}

.error-number {
  font-size: clamp(6rem, 12vw, 10rem);
  font-weight: bold;
  color: #ff6b6b;
  margin-bottom: 1rem;
  text-shadow: 0 4px 8px rgba(255, 107, 107, 0.3);
  animation: pulse 2s infinite;
  line-height: 1;
}

.error-text {
  font-size: clamp(1.5rem, 4vw, 2.5rem);
  color: #4a5568;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

/* 描述区域 */
.description-section {
  margin-bottom: 2rem;
}

.description-title {
  font-size: clamp(1.2rem, 3vw, 1.8rem);
  color: #2d3748;
  margin-bottom: 1.5rem;
  font-weight: 600;
  line-height: 1.4;
}

.description-text {
  font-size: clamp(0.9rem, 2vw, 1.2rem);
  color: #718096;
  line-height: 1.6;
  max-width: 100%;
  margin: 0 auto;
}

/* 区域标题 */
.section-title {
  font-size: 1.4rem;
  color: #2d3748;
  margin-bottom: 1.5rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* 操作按钮区域 */
.action-section {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 1rem;
  border: 1px solid #e9ecef;
}

.button-group {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.action-button {
  height: clamp(48px, 6vw, 56px);
  font-size: clamp(0.9rem, 2vw, 1.1rem);
  font-weight: 600;
  border-radius: 12px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.primary-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  color: white;
}

.primary-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.secondary-button {
  background: white;
  border: 2px solid #e9ecef;
  color: #6c757d;
}

.secondary-button:hover {
  border-color: #667eea;
  color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

/* 帮助区域 */
.help-section {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 1rem;
  border: 1px solid #e9ecef;
}

.help-links {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.75rem;
}

.help-link {
  display: block;
  text-decoration: none;
  transition: all 0.3s ease;
}

.help-link-content {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.help-link:hover .help-link-content {
  border-color: #667eea;
  background: #f0f4ff;
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.help-link-text {
  flex: 1;
}

.help-link-title {
  font-size: 1rem;
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 0.25rem;
}

.help-link-desc {
  font-size: 0.875rem;
  color: #718096;
}

/* 装饰性元素 */
.decoration-section {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 1;
}

.floating-elements {
  position: relative;
  width: 100%;
  height: 100%;
}

.floating-dot {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  animation: float 6s ease-in-out infinite;
}

.dot-1 {
  width: 20px;
  height: 20px;
  top: 15%;
  left: 8%;
  animation-delay: 0s;
}

.dot-2 {
  width: 15px;
  height: 15px;
  top: 25%;
  right: 12%;
  animation-delay: 2s;
}

.dot-3 {
  width: 25px;
  height: 25px;
  bottom: 25%;
  left: 15%;
  animation-delay: 4s;
}

.dot-4 {
  width: 18px;
  height: 18px;
  top: 45%;
  right: 25%;
  animation-delay: 1s;
}

.dot-5 {
  width: 12px;
  height: 12px;
  top: 65%;
  left: 5%;
  animation-delay: 3s;
}

.dot-6 {
  width: 22px;
  height: 22px;
  bottom: 15%;
  right: 8%;
  animation-delay: 5s;
}

/* 动画效果 */
@keyframes bounce {
  0%,
  20%,
  50%,
  80%,
  100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}

/* 苹果屏幕特殊优化 */
@media screen and (min-width: 1440px) and (max-width: 2560px) {
  .not-found-content {
    max-width: 1600px;
    margin: 0 auto;
    gap: 5rem;
    padding: 4rem 3rem;
  }

  .error-number {
    font-size: 12rem;
  }

  .error-text {
    font-size: 3rem;
  }

  .description-title {
    font-size: 2.2rem;
  }

  .description-text {
    font-size: 1.4rem;
  }

  .action-button {
    height: 64px;
    font-size: 1.2rem;
  }
}

/* 超宽屏优化 */
@media screen and (min-width: 2560px) {
  .not-found-content {
    max-width: 2000px;
    margin: 0 auto;
    gap: 6rem;
    padding: 5rem 4rem;
  }

  .error-number {
    font-size: 14rem;
  }

  .error-text {
    font-size: 3.5rem;
  }

  .description-title {
    font-size: 2.5rem;
  }

  .description-text {
    font-size: 1.6rem;
  }

  .action-button {
    height: 72px;
    font-size: 1.3rem;
  }
}

/* 响应式设计 */
@media (max-width: 1400px) {
  .not-found-content {
    gap: 3rem;
    padding: 2.5rem 1.5rem;
  }
}

@media (max-width: 1200px) {
  .not-found-content {
    gap: 2.5rem;
    padding: 2rem 1.5rem;
  }

  .action-section,
  .help-section {
    padding: 1.5rem;
  }
}

@media (max-width: 992px) {
  .not-found-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    text-align: center;
    padding: 2rem 1rem;
  }

  .left-section {
    order: 1;
  }

  .right-section {
    order: 2;
  }

  .button-group {
    grid-template-columns: 1fr;
  }

  .action-section,
  .help-section {
    padding: 1.5rem;
  }
}

@media (max-width: 768px) {
  .not-found-container {
    padding: 0.5rem;
  }

  .not-found-wrapper {
    padding: 0 0.5rem;
  }

  .not-found-content {
    padding: 1.5rem 1rem;
    gap: 1.5rem;
    border-radius: 1rem;
  }

  .action-section,
  .help-section {
    padding: 1rem;
  }

  .button-group {
    gap: 0.75rem;
  }

  .action-button {
    height: 44px;
  }
}

@media (max-width: 480px) {
  .not-found-content {
    padding: 1rem 0.75rem;
    gap: 1rem;
  }

  .action-section,
  .help-section {
    padding: 0.75rem;
  }

  .help-link-content {
    padding: 0.75rem;
  }

  .help-link-title {
    font-size: 0.9rem;
  }

  .help-link-desc {
    font-size: 0.8rem;
  }
}
</style>
