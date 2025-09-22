# 全局 Loading 使用说明

## 🎯 功能特性

- ✅ **自动管理**：所有 HTTP 请求自动显示/隐藏 loading
- ✅ **计数管理**：支持多个并发请求的计数管理
- ✅ **可控制**：可以禁用特定请求的 loading
- ✅ **美观界面**：现代化的 loading 界面设计
- ✅ **响应式**：支持移动端和桌面端

## 🚀 使用方法

### 1. 自动 Loading（推荐）

所有通过 `httpClient` 的请求都会自动显示全局 loading：

```javascript
import { userApi } from '@/utils/apiService';

// 自动显示全局 loading
const users = await userApi.getUsers();
```

### 2. 禁用特定请求的 Loading

如果某个请求不需要显示全局 loading：

```javascript
import { get } from '@/utils/httpClient';

// 禁用全局 loading
const data = await get('/api/data', {}, { showLoading: false });
```

### 3. 手动控制 Loading

```javascript
import { startLoading, stopLoading, isLoading } from '@/utils/loadingManager';

// 手动开始 loading
startLoading('custom-operation');

// 检查 loading 状态
if (isLoading()) {
  console.log('正在加载中...');
}

// 手动结束 loading
stopLoading('custom-operation');
```

## 📊 Loading 状态管理

### 全局状态

```javascript
import { globalLoading, loadingCount, loadingRequests } from '@/utils/loadingManager';

// 在组件中使用
const isGlobalLoading = globalLoading.value;
const currentLoadingCount = loadingCount.value;
const activeRequests = loadingRequests.value;
```

### Loading 管理器 API

```javascript
import {
  startLoading, // 开始 loading
  stopLoading, // 结束 loading
  isLoading, // 检查 loading 状态
  getLoadingCount, // 获取 loading 计数
  getLoadingRequests, // 获取正在进行的请求
  clearAllLoading, // 清除所有 loading
} from '@/utils/loadingManager';
```

## 🎨 自定义 Loading 样式

可以在 `GlobalLoading.vue` 中自定义样式：

```vue
<style scoped>
.global-loading-overlay {
  /* 自定义遮罩层样式 */
  background: rgba(0, 0, 0, 0.7);
}

.spinner {
  /* 自定义旋转器样式 */
  border-top-color: #your-color;
}

.loading-text p {
  /* 自定义文字样式 */
  color: #your-color;
}
</style>
```

## 🔧 配置选项

### 显示请求计数

在 `GlobalLoading.vue` 中：

```javascript
// 显示请求计数
const showCount = ref(true);
```

### 自定义 Loading 文本

```vue
<template>
  <div class="loading-text">
    <p>{{ loadingText }}</p>
    <p class="loading-count" v-if="showCount">请求数量: {{ loadingCount }}</p>
  </div>
</template>

<script setup>
const loadingText = ref('正在加载数据...');
</script>
```

## 📱 响应式支持

Loading 组件已经支持响应式设计：

- **桌面端**：大尺寸 spinner 和文字
- **移动端**：小尺寸 spinner 和文字
- **自适应**：根据屏幕尺寸自动调整

## 🎯 最佳实践

1. **默认启用**：让所有 API 请求都显示 loading
2. **禁用场景**：只在特殊情况下禁用 loading（如实时数据更新）
3. **错误处理**：即使请求失败，loading 也会正确结束
4. **性能优化**：使用计数管理避免重复显示

## 🐛 故障排除

### Loading 不消失

```javascript
// 强制清除所有 loading
import { clearAllLoading } from '@/utils/loadingManager';
clearAllLoading();
```

### 检查 Loading 状态

```javascript
import { isLoading, getLoadingCount } from '@/utils/loadingManager';

console.log('Is loading:', isLoading());
console.log('Loading count:', getLoadingCount());
```
