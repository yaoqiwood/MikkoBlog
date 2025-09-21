<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1 class="dashboard-title">仪表盘</h1>
      <p class="dashboard-subtitle">欢迎回来，{{ userInfo.email || 'admin@example.com' }}</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <Icon type="ios-people" size="32" color="#667eea" />
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ stats.users }}</div>
          <div class="stat-label">用户总数</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <Icon type="ios-document" size="32" color="#48bb78" />
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ stats.posts }}</div>
          <div class="stat-label">文章总数</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <Icon type="ios-eye" size="32" color="#ed8936" />
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ stats.views }}</div>
          <div class="stat-label">总浏览量</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <Icon type="ios-checkmark-circle" size="32" color="#38b2ac" />
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ stats.activeUsers }}</div>
          <div class="stat-label">活跃用户</div>
        </div>
      </div>
    </div>

    <!-- 快速操作 -->
    <div class="quick-actions">
      <h2 class="section-title">快速操作</h2>
      <div class="actions-grid">
        <Button
          type="primary"
          size="large"
          icon="ios-person-add"
          @click="goToUsers"
          class="action-btn"
        >
          用户管理
        </Button>
        <Button type="success" size="large" icon="ios-create" @click="goToPosts" class="action-btn">
          文章管理
        </Button>
        <Button
          type="warning"
          size="large"
          icon="ios-settings"
          @click="goToSettings"
          class="action-btn"
        >
          系统设置
        </Button>
        <Button type="info" size="large" icon="ios-flask" @click="goToTest" class="action-btn">
          组件测试
        </Button>
      </div>
    </div>

    <!-- 最近活动 -->
    <div class="recent-activities">
      <h2 class="section-title">最近活动</h2>
      <div class="activity-list">
        <div class="activity-item" v-for="activity in activities" :key="activity.id">
          <div class="activity-icon">
            <Icon :type="activity.icon" :color="activity.color" />
          </div>
          <div class="activity-content">
            <div class="activity-title">{{ activity.title }}</div>
            <div class="activity-time">{{ activity.time }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 用户信息
const userInfo = ref({
  email: 'admin@example.com',
});

// 统计数据
const stats = ref({
  users: 0,
  posts: 0,
  views: 0,
  activeUsers: 0,
});

// 最近活动
const activities = ref([
  {
    id: 1,
    icon: 'ios-person-add',
    color: '#667eea',
    title: '新用户注册',
    time: '2分钟前',
  },
  {
    id: 2,
    icon: 'ios-document',
    color: '#48bb78',
    title: '发布新文章',
    time: '15分钟前',
  },
  {
    id: 3,
    icon: 'ios-settings',
    color: '#ed8936',
    title: '系统设置更新',
    time: '1小时前',
  },
  {
    id: 4,
    icon: 'ios-eye',
    color: '#38b2ac',
    title: '页面访问量增加',
    time: '2小时前',
  },
]);

// 快速操作函数
function goToUsers() {
  router.push('/admin/users');
}

function goToPosts() {
  router.push('/admin/posts');
}

function goToSettings() {
  router.push('/admin/settings');
}

function goToTest() {
  router.push('/admin/test-viewui');
}

// 加载统计数据
async function loadStats() {
  try {
    // 这里可以调用API获取真实数据
    // 现在使用模拟数据
    stats.value = {
      users: 156,
      posts: 89,
      views: 1234,
      activeUsers: 23,
    };
  } catch (error) {
    console.error('加载统计数据失败:', error);
    Message.error('加载统计数据失败');
  }
}

onMounted(() => {
  loadStats();
});
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: 2rem;
}

.dashboard-title {
  font-size: 2rem;
  font-weight: bold;
  color: #2d3748;
  margin-bottom: 0.5rem;
}

.dashboard-subtitle {
  color: #718096;
  font-size: 1.1rem;
}

/* 统计卡片 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  background: #f7fafc;
  border-radius: 0.5rem;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 2rem;
  font-weight: bold;
  color: #2d3748;
  line-height: 1;
  margin-bottom: 0.25rem;
}

.stat-label {
  color: #718096;
  font-size: 0.9rem;
}

/* 快速操作 */
.quick-actions {
  background: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.section-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 1rem;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.action-btn {
  height: 48px;
  font-size: 1rem;
  font-weight: 600;
}

/* 最近活动 */
.recent-activities {
  background: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  border-radius: 0.5rem;
  transition: background 0.2s ease;
}

.activity-item:hover {
  background: #f7fafc;
}

.activity-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: #f7fafc;
  border-radius: 0.5rem;
}

.activity-content {
  flex: 1;
}

.activity-title {
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 0.25rem;
}

.activity-time {
  font-size: 0.875rem;
  color: #718096;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .dashboard {
    padding: 0;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .actions-grid {
    grid-template-columns: 1fr;
  }

  .stat-card {
    padding: 1rem;
  }

  .quick-actions,
  .recent-activities {
    padding: 1rem;
  }
}
</style>
