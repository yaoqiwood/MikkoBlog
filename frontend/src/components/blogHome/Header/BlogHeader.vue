<template>
  <header class="blog-header">
    <div class="header-container">
      <div class="blog-title">
        <h1>{{ title }}</h1>
      </div>
      <nav class="main-nav">
        <a
          href="#"
          class="nav-item"
          :class="{ active: currentView === 'home' }"
          @click="$emit('switchView', 'home')"
          >首页</a
        >
        <router-link to="/articles" class="nav-item">文章列表</router-link>
        <a
          href="#"
          class="nav-item"
          :class="{ active: currentView === 'columns' }"
          @click="$emit('switchView', 'columns')"
          >专栏</a
        >
        <a
          href="#"
          class="nav-item"
          :class="{ active: currentView === 'about' }"
          @click="$emit('switchView', 'about')"
          >关于我</a
        >
      </nav>
      <div class="search-box">
        <i class="search-icon">🔍</i>
      </div>
    </div>
  </header>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    default: 'MikkoBlog',
  },
  currentView: {
    type: String,
    default: 'home',
  },
});

defineEmits(['switchView']);
</script>

<style scoped>
/* 头部样式 */
.blog-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60px;
  position: relative;
}

.blog-title {
  position: absolute;
  left: 20px;
}

.blog-title h1 {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
}

.main-nav {
  display: flex;
  gap: 30px;
}

.nav-item {
  text-decoration: none;
  color: #333;
  font-weight: 500;
  transition: all 0.3s ease;
  position: relative;
}

.nav-item:hover {
  color: #ff6b6b;
  transform: translateY(-2px);
}

.nav-item::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
  transition: width 0.3s ease;
}

.nav-item:hover::after {
  width: 100%;
}

.search-box {
  position: absolute;
  right: 20px;
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.search-box:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: scale(1.05);
}

/* 导航激活状态 */
.nav-item.active {
  color: #2d8cf0;
  font-weight: 600;
  border-bottom: 2px solid #2d8cf0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-container {
    flex-direction: column;
    height: auto;
    padding: 15px 20px;
  }

  .main-nav {
    margin: 10px 0;
  }
}
</style>
