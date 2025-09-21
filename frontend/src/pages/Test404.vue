<template>
  <div class="test-container">
    <h1>404 页面测试</h1>
    <div class="test-buttons">
      <Button type="primary" @click="test404">测试 404 页面</Button>
      <Button type="default" @click="testInvalidRoute">测试无效路由</Button>
      <Button type="success" @click="goHome">返回首页</Button>
    </div>
    <div class="test-info">
      <p>点击按钮测试不同的路由场景：</p>
      <ul>
        <li><strong>测试 404 页面</strong>：直接访问 /404 路径</li>
        <li><strong>测试无效路由</strong>：访问不存在的路径，应该自动重定向到 404</li>
        <li><strong>返回首页</strong>：回到首页</li>
      </ul>
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
.test-container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 2rem;
  text-align: center;
}

.test-buttons {
  margin: 2rem 0;
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.test-info {
  margin-top: 2rem;
  text-align: left;
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
}

.test-info ul {
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.test-info li {
  margin: 0.5rem 0;
}
</style>
