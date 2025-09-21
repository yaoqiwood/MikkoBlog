<template>
  <div class="demo-container">
    <div class="demo-header">
      <h1>404页面设计演示</h1>
      <p>新的404页面采用桌面端优先的设计，具有更好的用户体验</p>
    </div>

    <div class="demo-content">
      <div class="demo-section">
        <h2>设计特点</h2>
        <div class="features-grid">
          <div class="feature-card">
            <Icon type="ios-desktop" size="48" color="#667eea" />
            <h3>桌面端优先</h3>
            <p>采用左右分栏布局，充分利用桌面端屏幕空间</p>
          </div>
          <div class="feature-card">
            <Icon type="ios-phone-portrait" size="48" color="#667eea" />
            <h3>响应式设计</h3>
            <p>在小屏幕设备上自动切换为垂直布局</p>
          </div>
          <div class="feature-card">
            <Icon type="ios-navigate" size="48" color="#667eea" />
            <h3>智能导航</h3>
            <p>提供多种导航选项和帮助链接</p>
          </div>
          <div class="feature-card">
            <Icon type="ios-color-palette" size="48" color="#667eea" />
            <h3>现代设计</h3>
            <p>使用渐变背景和动画效果，提升视觉体验</p>
          </div>
        </div>
      </div>

      <div class="demo-section">
        <h2>测试404页面</h2>
        <div class="test-buttons">
          <Button type="primary" size="large" @click="test404" icon="ios-eye"> 查看404页面 </Button>
          <Button type="default" size="large" @click="testInvalidRoute" icon="ios-bug">
            测试无效路由
          </Button>
          <Button type="success" size="large" @click="goHome" icon="ios-home"> 返回首页 </Button>
        </div>
      </div>

      <div class="demo-section">
        <h2>响应式断点</h2>
        <div class="breakpoints">
          <div class="breakpoint">
            <div class="breakpoint-label">桌面端</div>
            <div class="breakpoint-range">≥ 992px</div>
            <div class="breakpoint-desc">左右分栏布局，最大宽度1400px</div>
          </div>
          <div class="breakpoint">
            <div class="breakpoint-label">平板端</div>
            <div class="breakpoint-range">768px - 991px</div>
            <div class="breakpoint-desc">垂直布局，保持桌面端样式</div>
          </div>
          <div class="breakpoint">
            <div class="breakpoint-label">移动端</div>
            <div class="breakpoint-range">≤ 767px</div>
            <div class="breakpoint-desc">紧凑布局，优化触摸操作</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { useRouter } from 'vue-router';

const router = useRouter();

function test404() {
  router.push('/404');
}

function testInvalidRoute() {
  router.push('/this-page-does-not-exist');
}

function goHome() {
  routerUtils.navigateTo(router, ROUTES.HOME);
}
</script>

<style scoped>
.demo-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.demo-header {
  text-align: center;
  margin-bottom: 3rem;
}

.demo-header h1 {
  font-size: 2.5rem;
  color: #2d3748;
  margin-bottom: 1rem;
}

.demo-header p {
  font-size: 1.2rem;
  color: #718096;
}

.demo-content {
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

.demo-section {
  background: white;
  padding: 2rem;
  border-radius: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.demo-section h2 {
  font-size: 1.8rem;
  color: #2d3748;
  margin-bottom: 1.5rem;
  text-align: center;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.feature-card {
  text-align: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 0.75rem;
  border: 1px solid #e9ecef;
}

.feature-card h3 {
  font-size: 1.2rem;
  color: #2d3748;
  margin: 1rem 0 0.5rem;
}

.feature-card p {
  color: #718096;
  line-height: 1.5;
}

.test-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.test-buttons .ivu-btn {
  min-width: 160px;
  height: 48px;
}

.breakpoints {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.breakpoint {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 0.75rem;
  border: 1px solid #e9ecef;
  text-align: center;
}

.breakpoint-label {
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 0.5rem;
}

.breakpoint-range {
  font-size: 1rem;
  color: #667eea;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.breakpoint-desc {
  font-size: 0.9rem;
  color: #718096;
  line-height: 1.4;
}

@media (max-width: 768px) {
  .demo-container {
    padding: 1rem;
  }

  .demo-header h1 {
    font-size: 2rem;
  }

  .demo-header p {
    font-size: 1rem;
  }

  .demo-section {
    padding: 1.5rem;
  }

  .test-buttons {
    flex-direction: column;
    align-items: center;
  }

  .test-buttons .ivu-btn {
    width: 100%;
    max-width: 300px;
  }
}
</style>
