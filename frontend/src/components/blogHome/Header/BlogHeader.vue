<template>
  <header class="blog-header">
    <div class="header-container">
      <div class="blog-title">
        <h1>{{ title }}</h1>
      </div>
      <div class="nav-container">
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

.nav-container {
  display: flex;
  align-items: center;
  gap: 20px;
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
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  flex-shrink: 0;
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
    padding: 12px 15px;
    gap: 12px;
  }

  .blog-title {
    position: static;
    text-align: center;
    order: 1;
  }

  .blog-title h1 {
    font-size: 20px;
  }

  .nav-container {
    order: 2;
    flex-direction: row;
    gap: 15px;
    align-items: center;
    justify-content: center;
    flex-wrap: wrap;
  }

  .main-nav {
    margin: 0;
    gap: 15px;
    justify-content: center;
    flex-wrap: wrap;
  }

  .nav-item {
    font-size: 14px;
    padding: 6px 12px;
    border-radius: 6px;
    background: rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;
  }

  .nav-item:hover {
    background: rgba(0, 0, 0, 0.1);
    transform: none;
  }

  .nav-item::after {
    display: none;
  }

  .nav-item.active {
    background: #2d8cf0;
    color: white;
    border-bottom: none;
  }

  .search-box {
    margin-top: 0;
  }
}

@media (max-width: 480px) {
  .header-container {
    padding: 10px 12px;
    gap: 10px;
  }

  .blog-title h1 {
    font-size: 18px;
  }

  .nav-container {
    gap: 8px;
    flex-wrap: wrap;
  }

  .main-nav {
    gap: 12px;
    flex-wrap: wrap;
  }

  .nav-item {
    font-size: 13px;
    padding: 5px 10px;
  }

  .search-box {
    padding: 6px 10px;
  }
}

@media (max-width: 360px) {
  .nav-container {
    gap: 6px;
    flex-wrap: wrap;
  }

  .main-nav {
    gap: 10px;
    flex-wrap: wrap;
  }

  .nav-item {
    font-size: 12px;
    padding: 4px 8px;
  }
}
</style>
