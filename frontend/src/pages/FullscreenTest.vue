<template>
  <div class="page-container fullscreen-test">
    <div class="test-content">
      <h1>全屏布局测试</h1>
      <div class="test-info">
        <div class="info-item"><strong>容器宽度:</strong> <span id="container-width">-</span></div>
        <div class="info-item"><strong>容器高度:</strong> <span id="container-height">-</span></div>
        <div class="info-item"><strong>视口宽度:</strong> <span id="viewport-width">-</span></div>
        <div class="info-item"><strong>视口高度:</strong> <span id="viewport-height">-</span></div>
      </div>
      <div class="test-buttons">
        <Button type="primary" @click="test404">测试404页面</Button>
        <Button type="default" @click="testLogin">测试登录页面</Button>
        <Button type="success" @click="goHome">返回首页</Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

function test404() {
  router.push('/404');
}

function testLogin() {
  router.push('/login');
}

function goHome() {
  routerUtils.navigateTo(router, ROUTES.HOME);
}

onMounted(() => {
  // 更新尺寸信息
  function updateDimensions() {
    const container = document.querySelector('.fullscreen-test');
    const containerWidth = container.offsetWidth;
    const containerHeight = container.offsetHeight;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    document.getElementById('container-width').textContent = `${containerWidth}px`;
    document.getElementById('container-height').textContent = `${containerHeight}px`;
    document.getElementById('viewport-width').textContent = `${viewportWidth}px`;
    document.getElementById('viewport-height').textContent = `${viewportHeight}px`;
  }

  updateDimensions();
  window.addEventListener('resize', updateDimensions);
});
</script>

<style scoped>
.fullscreen-test {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0;
  padding: 0;
  position: fixed;
  top: 0;
  left: 0;
}

.test-content {
  background: white;
  padding: 3rem;
  border-radius: 1rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  text-align: center;
  max-width: 600px;
  width: 90%;
}

.test-content h1 {
  color: #2d3748;
  margin-bottom: 2rem;
  font-size: 2rem;
}

.test-info {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 0.5rem;
  margin-bottom: 2rem;
  text-align: left;
}

.info-item {
  margin-bottom: 0.5rem;
  font-size: 1rem;
}

.info-item strong {
  color: #2d3748;
}

.info-item span {
  color: #667eea;
  font-weight: 600;
}

.test-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.test-buttons .ivu-btn {
  min-width: 120px;
}

@media (max-width: 768px) {
  .test-content {
    padding: 2rem;
    margin: 1rem;
  }

  .test-buttons {
    flex-direction: column;
    align-items: center;
  }

  .test-buttons .ivu-btn {
    width: 100%;
    max-width: 200px;
  }
}
</style>
