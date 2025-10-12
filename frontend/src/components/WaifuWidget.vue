<template>
  <div v-if="showWaifu" class="waifu-widget">
    <!-- 看板娘容器 -->
    <div id="waifu-widget" class="waifu-container">
      <div class="waifu-toolbar">
        <button class="waifu-btn" @click="toggleWaifu" title="隐藏看板娘">
          <i>👋</i>
        </button>
        <button class="waifu-btn" @click="changeModel" title="切换模型">
          <i>🔄</i>
        </button>
        <button class="waifu-btn" @click="showMessage" title="显示消息">
          <i>💬</i>
        </button>
        <button class="waifu-btn" @click="showSettings = true" title="设置">
          <i>⚙️</i>
        </button>
      </div>

      <!-- 消息气泡 -->
      <div class="waifu-message" v-if="showMessageBubble">
        {{ currentMessage }}
      </div>
    </div>

    <!-- 设置面板 -->
    <div v-if="showSettings" class="waifu-settings">
      <div class="settings-header">
        <h3>看板娘设置</h3>
        <button @click="showSettings = false" class="close-btn">×</button>
      </div>
      <div class="settings-content">
        <div class="setting-item">
          <label>当前模型: {{ currentModelName }}</label>
        </div>
        <div class="setting-item">
          <label>自动问候</label>
          <input type="checkbox" v-model="autoGreeting" @change="saveSettings" />
        </div>
        <div class="setting-item" v-if="autoGreeting">
          <label>问候间隔</label>
          <select v-model="greetingInterval" @change="saveSettings">
            <option value="30">30秒</option>
            <option value="60">1分钟</option>
            <option value="120">2分钟</option>
            <option value="300">5分钟</option>
          </select>
        </div>
        <div class="setting-item">
          <label>点击交互</label>
          <input type="checkbox" v-model="clickInteraction" @change="saveSettings" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref, watch } from 'vue';

const props = defineProps({
  show: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['update:show']);

// 响应式数据
const showWaifu = ref(props.show);
const showMessageBubble = ref(false);
const currentMessage = ref('');
const showSettings = ref(false);
const autoGreeting = ref(true);
const greetingInterval = ref(60);
const clickInteraction = ref(true);
const currentModelName = ref('雷姆');

// 模型列表
const models = [
  { id: 'rem', name: '雷姆' },
  { id: 'kurumi', name: '时崎狂三' },
  { id: 'chino', name: '香风智乃' },
  { id: 'index', name: '茵蒂克丝' },
];

let currentModelIndex = 0;
let greetingTimer = null;
let clickCount = 0;
let lastClickTime = 0;

// 消息列表
const messages = [
  'こんにちは！私はレムです！',
  '今日も一日頑張りましょう！',
  '何かお手伝いできることはありますか？',
  'ご主人様、おかえりなさい！',
  'このブログを楽しんでくださいね！',
  '私をクリックして遊んでね！',
  '今日の気分はどうですか？',
  '一緒に新しいことを学びませんか？',
  'あなたの笑顔が大好きです！',
  'お疲れ様でした！',
];

// 切换看板娘显示
const toggleWaifu = () => {
  showWaifu.value = !showWaifu.value;
  emit('update:show', showWaifu.value);

  if (showWaifu.value) {
    initWaifu();
  } else {
    destroyWaifu();
  }
};

// 切换模型
const changeModel = () => {
  currentModelIndex = (currentModelIndex + 1) % models.length;
  currentModelName.value = models[currentModelIndex].name;
  destroyWaifu();
  globalThis.setTimeout(() => {
    initWaifu();
  }, 100);
  saveSettings();
};

// 显示消息
const showMessage = () => {
  const randomMessage = messages[Math.floor(Math.random() * messages.length)];
  displayMessage(randomMessage);
};

// 显示消息气泡
const displayMessage = message => {
  currentMessage.value = message;
  showMessageBubble.value = true;

  globalThis.setTimeout(() => {
    showMessageBubble.value = false;
  }, 3000);
};

// 处理点击事件
const handleClick = () => {
  if (!clickInteraction.value) return;

  const currentTime = Date.now();
  if (currentTime - lastClickTime < 500) {
    clickCount++;
  } else {
    clickCount = 1;
  }
  lastClickTime = currentTime;

  if (clickCount === 1) {
    displayMessage('こんにちは！');
  } else if (clickCount === 2) {
    displayMessage('また会えて嬉しいです！');
  } else if (clickCount === 3) {
    displayMessage('あなたのことが大好きです！');
    clickCount = 0;
  }
};

// 初始化看板娘
const initWaifu = () => {
  if (!showWaifu.value) return;

  // 使用成熟的 live2d-widget
  if (window.L2Dwidget) {
    startL2Dwidget();
  } else {
    loadL2Dwidget()
      .then(() => {
        startL2Dwidget();
      })
      .catch(error => {
        console.error('L2Dwidget 加载失败:', error);
        displayMessage('看板娘加载失败，显示静态版本');
      });
  }
};

// 加载 L2Dwidget 库
const loadL2Dwidget = () => {
  return new Promise((resolve, reject) => {
    // 检查是否已经加载过
    if (window.L2Dwidget) {
      resolve();
      return;
    }

    // 使用成熟的 live2d-widget CDN
    const script = document.createElement('script');
    script.src = 'https://fastly.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/autoload.js';
    script.async = true;
    script.onload = () => {
      // 等待一下确保库完全加载
      // globalThis.setTimeout(() => {
      //   if (window.L2Dwidget) {
      //     resolve();
      //   } else {
      //     reject(new Error('L2Dwidget 未正确加载'));
      //   }
      // }, 1000);
    };
    script.onerror = () => {
      reject(new Error('Live2D 库加载失败'));
    };
    document.head.appendChild(script);
  });
};

// 启动 L2Dwidget
const startL2Dwidget = () => {
  const currentModel = models[currentModelIndex];

  // 使用成熟的配置
  window.L2Dwidget.init({
    model: {
      jsonPath: `https://fastly.jsdelivr.net/gh/stevenjoezhang/live2d-widget@latest/assets/${currentModel.id}/model.json`,
      scale: 0.5,
    },
    display: {
      superSample: 2,
      width: 200,
      height: 400,
      hOffset: 0,
      vOffset: 0,
    },
    mobile: {
      show: true,
      scale: 0.5,
    },
    react: {
      opacityDefault: 1,
      opacityOnHover: 0.8,
    },
    dialog: {
      enable: true,
      script: {
        'tap body': messages,
      },
    },
  });

  // 添加点击事件
  document.addEventListener('click', handleClick);

  // 显示欢迎消息
  globalThis.setTimeout(() => {
    displayMessage(`你好！我是${currentModelName.value}！`);
  }, 1000);
};

// 显示静态看板娘
const showStaticWaifu = () => {
  const container = document.getElementById('waifu-widget');
  if (container) {
    container.innerHTML = `
      <div style="
        width: 200px;
        height: 400px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #f0f8ff 0%, #e6f3ff 100%);
        border-radius: 10px;
        color: #666;
        text-align: center;
        padding: 20px;
        box-sizing: border-box;
        cursor: pointer;
        transition: all 0.3s ease;
      " onclick="this.style.transform = 'scale(1.05)'">
        <div style="font-size: 80px; margin-bottom: 20px; animation: bounce 2s infinite;">🎭</div>
        <div style="font-size: 18px; font-weight: bold; margin-bottom: 10px;">${currentModelName.value}</div>
        <div style="font-size: 14px; opacity: 0.8; margin-bottom: 15px;">静态看板娘</div>
        <div style="font-size: 12px; opacity: 0.6;">点击我试试看！</div>
        <div style="font-size: 10px; opacity: 0.5; margin-top: 10px;">Live2D 库加载中...</div>
      </div>
      <style>
        @keyframes bounce {
          0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
          40% { transform: translateY(-10px); }
          60% { transform: translateY(-5px); }
        }
      </style>
    `;

    // 添加点击事件
    container.addEventListener('click', () => {
      displayMessage('我是静态看板娘，Live2D 版本正在加载中...');
    });
  }
};

// 销毁看板娘
const destroyWaifu = () => {
  document.removeEventListener('click', handleClick);

  // 清理 L2Dwidget
  if (window.L2Dwidget) {
    try {
      window.L2Dwidget.destroy();
    } catch (error) {
      console.warn('销毁 L2Dwidget 时出错:', error);
    }
  }

  // 清理相关 DOM 元素
  const waifuElements = document.querySelectorAll(
    '[id*="waifu"], [class*="waifu"], [id*="l2d"], [class*="l2d"]'
  );
  waifuElements.forEach(element => {
    if (element.id !== 'waifu-widget' && element.parentNode) {
      element.parentNode.removeChild(element);
    }
  });
};

// 设置自动问候
const setupAutoGreeting = () => {
  if (greetingTimer) {
    globalThis.clearInterval(greetingTimer);
  }

  if (autoGreeting.value) {
    greetingTimer = globalThis.setInterval(() => {
      showMessage();
    }, greetingInterval.value * 1000);
  }
};

// 保存设置
const saveSettings = () => {
  const settings = {
    autoGreeting: autoGreeting.value,
    greetingInterval: greetingInterval.value,
    clickInteraction: clickInteraction.value,
    currentModel: currentModelIndex,
  };
  localStorage.setItem('waifu-settings', JSON.stringify(settings));
  setupAutoGreeting();
};

// 加载设置
const loadSettings = () => {
  try {
    const settings = JSON.parse(localStorage.getItem('waifu-settings') || '{}');
    autoGreeting.value = settings.autoGreeting !== undefined ? settings.autoGreeting : true;
    greetingInterval.value = settings.greetingInterval || 60;
    clickInteraction.value =
      settings.clickInteraction !== undefined ? settings.clickInteraction : true;
    currentModelIndex = settings.currentModel || 0;
    currentModelName.value = models[currentModelIndex].name;
  } catch (error) {
    console.error('加载设置失败:', error);
  }
};

// 监听 show 属性变化
watch(
  () => props.show,
  newShow => {
    showWaifu.value = newShow;
    if (newShow) {
      globalThis.setTimeout(() => {
        initWaifu();
      }, 100);
    } else {
      destroyWaifu();
    }
  }
);

onMounted(() => {
  loadSettings();
  setupAutoGreeting();

  if (showWaifu.value) {
    globalThis.setTimeout(() => {
      initWaifu();
    }, 500);
  }
});

onUnmounted(() => {
  destroyWaifu();
  if (greetingTimer) {
    globalThis.clearInterval(greetingTimer);
  }
});
</script>

<style scoped>
.waifu-container {
  position: relative;
  width: 200px;
  height: 400px;
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  background: linear-gradient(135deg, #f0f8ff 0%, #e6f3ff 100%);
  overflow: hidden;
}

.waifu-toolbar {
  position: absolute;
  top: -35px;
  display: flex;
  gap: 5px;
  z-index: 1001;
}

.waifu-toolbar {
  right: 0;
}

.waifu-btn {
  width: 30px;
  height: 30px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  color: #333;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.waifu-btn:hover {
  background: #667eea;
  color: white;
  transform: scale(1.1);
}

.waifu-message {
  position: absolute;
  bottom: 100%;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 10px 15px;
  border-radius: 15px;
  font-size: 14px;
  max-width: 200px;
  word-wrap: break-word;
  margin-bottom: 10px;
  animation: messageIn 0.3s ease-out;
}

.waifu-message {
  right: 0;
}

.waifu-message::after {
  content: '';
  position: absolute;
  top: 100%;
  right: 20px;
  border: 5px solid transparent;
  border-top-color: rgba(0, 0, 0, 0.8);
}

@keyframes messageIn {
  from {
    opacity: 0;
    transform: translateY(10px) scale(0.8);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.waifu-settings {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: white;
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  z-index: 2000;
  min-width: 300px;
  max-width: 500px;
}

.settings-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.settings-header h3 {
  margin: 0;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #999;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #333;
}

.settings-content {
  padding: 20px;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.setting-item label {
  font-weight: 500;
  color: #333;
}

.setting-item input[type='checkbox'] {
  width: 18px;
  height: 18px;
}

.setting-item select {
  padding: 5px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .waifu-widget {
    bottom: 10px;
  }

  .waifu-widget {
    right: 10px;
  }

  .waifu-container {
    width: 160px;
    height: 320px;
  }

  .waifu-btn {
    width: 25px;
    height: 25px;
    font-size: 12px;
  }

  .waifu-message {
    bottom: 60px;
    right: 10px;
    max-width: 200px;
    font-size: 12px;
  }

  .waifu-settings {
    margin: 20px;
    min-width: auto;
    max-width: calc(100vw - 40px);
  }
}
</style>
