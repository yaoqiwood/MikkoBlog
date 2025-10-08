<template>
  <div v-if="show" class="welcome-modal-overlay" @click="closeModal">
    <div class="welcome-modal" @click.stop>
      <!-- 日期显示 -->
      <div class="date-section">
        <h2 class="date-title">{{ formattedDate }}</h2>
        <div class="date-subtitle">{{ formattedWeekday }}</div>
      </div>

      <!-- 内容区域 -->
      <div class="content-section">
        <div class="content-item">
          <p class="content-text chinese">{{ currentContent.chinese }}</p>
          <p class="content-reference chinese">{{ currentContent.chineseRef }}</p>
        </div>
        <div class="content-item">
          <p class="content-text english">{{ currentContent.english }}</p>
          <p class="content-reference english">{{ currentContent.englishRef }}</p>
        </div>
      </div>

      <!-- 关闭按钮 -->
      <div class="close-section">
        <button class="close-btn" @click="closeModal">进入博客</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import bibleVersesData from '@/data/bible-verses.json';
import famousQuotesData from '@/data/famous-quotes.json';
import { computed, onMounted, ref, watch } from 'vue';

// Props
const props = defineProps({
  show: {
    type: Boolean,
    default: true,
  },
  modalType: {
    type: String,
    default: 'bible', // 'bible' 或 'quotes'
  },
});

// Emits
const emit = defineEmits(['close']);

// 今天的日期
const today = ref(new Date());

// 格式化日期
const formattedDate = computed(() => {
  const year = today.value.getFullYear();
  const month = today.value.getMonth() + 1;
  const day = today.value.getDate();
  return `${year}年${month}月${day}日`;
});

// 格式化星期
const formattedWeekday = computed(() => {
  const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  return weekdays[today.value.getDay()];
});

// 当前显示的内容
const currentContent = ref({});

// 随机选择内容
const selectContent = () => {
  if (props.modalType === 'quotes') {
    // 选择世界名人格言
    const randomIndex = Math.floor(Math.random() * famousQuotesData.length);
    currentContent.value = famousQuotesData[randomIndex];
  } else {
    // 选择圣经话语
    const randomIndex = Math.floor(Math.random() * bibleVersesData.length);
    currentContent.value = bibleVersesData[randomIndex];
  }
};

// 关闭模态框
const closeModal = () => {
  emit('close');
};

// 组件挂载时选择内容
onMounted(() => {
  selectContent();
});

// 监听 modalType 变化
watch(
  () => props.modalType,
  () => {
    selectContent();
  }
);
</script>

<style scoped>
.welcome-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  backdrop-filter: blur(5px);
}

.welcome-modal {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  padding: 40px;
  max-width: 600px;
  width: 90%;
  text-align: center;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  color: white;
  animation: modalSlideIn 0.5s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-50px) scale(0.9);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.date-section {
  margin-bottom: 30px;
}

.date-title {
  font-size: 2.5rem;
  font-weight: 300;
  margin: 0 0 10px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.date-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
  font-weight: 300;
}

.content-section {
  margin-bottom: 30px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 15px;
  backdrop-filter: blur(10px);
}

.content-item {
  margin-bottom: 20px;
}

.content-item:last-child {
  margin-bottom: 0;
}

.content-text {
  font-size: 1.1rem;
  line-height: 1.6;
  margin: 0 0 8px 0;
  font-style: italic;
}

.content-reference {
  font-size: 0.9rem;
  opacity: 0.8;
  font-weight: 500;
}

.chinese {
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.english {
  font-family: 'Georgia', 'Times New Roman', serif;
}

.close-section {
  margin-top: 20px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  color: white;
  padding: 12px 30px;
  border-radius: 25px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.close-btn:active {
  transform: translateY(0);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .welcome-modal {
    padding: 30px 20px;
    margin: 20px;
  }

  .date-title {
    font-size: 2rem;
  }

  .content-text {
    font-size: 1rem;
  }
}
</style>
