# BlogHome.vue 博客标题集成主页设置

## ✅ **功能实现完成**

### **主要修改内容**：

1. **📝 模板更新**：

   ```vue
   <!-- 原来 -->
   <h1>{{ userProfile.blog_title }}</h1>

   <!-- 修改后 -->
   <h1>{{ homepageSettings.header_title || userProfile.blog_title || 'MikkoBlog' }}</h1>
   ```

2. **🔧 数据结构更新**：

   ```javascript
   // 主页设置数据
   const homepageSettings = ref({
     header_title: '', // 新增字段
     banner_image_url: '',
     background_image_url: '',
     show_music_player: false,
     music_url: '',
     show_live2d: false,
   });
   ```

3. **📡 数据加载更新**：
   ```javascript
   const loadHomepageSettings = async () => {
     try {
       const settings = await homepageApi.getSettings();
       homepageSettings.value = {
         header_title: settings.header_title || '', // 新增加载
         banner_image_url: settings.banner_image_url || '',
         // ... 其他字段
       };
     } catch (err) {
       console.error('加载主页设置失败:', err);
     }
   };
   ```

### **优先级逻辑**：

博客标题显示的优先级顺序：

1. **主页设置的标题** (`homepageSettings.header_title`) - 最高优先级
2. **用户资料的博客标题** (`userProfile.blog_title`) - 次优先级
3. **默认标题** (`'MikkoBlog'`) - 兜底显示

### **数据流程**：

1. **页面加载**: 调用 `loadHomepageSettings()` 获取主页设置
2. **API 请求**: `GET /api/homepage/settings` 获取包含 `header_title` 的数据
3. **数据绑定**: 将 `header_title` 绑定到响应式数据
4. **模板渲染**: 根据优先级显示博客标题

### **管理员设置流程**：

1. **后台设置**: 管理员在 `/admin/homepage-settings` 页面设置主页标题
2. **数据保存**: 标题保存到 `home_page_settings.header_title` 字段
3. **前端获取**: BlogHome 页面通过 API 获取最新标题
4. **实时显示**: 博客首页显示管理员设置的标题

### **API 接口**：

- **获取设置**: `GET /api/homepage/settings`
  ```json
  {
    "id": 1,
    "header_title": "我的个人博客",
    "banner_image_url": "...",
    "background_image_url": "...",
    "show_music_player": false,
    "music_url": "",
    "show_live2d": false,
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
  ```

### **功能特点**：

- ✅ **动态标题**: 管理员可以随时修改博客标题
- ✅ **优雅降级**: 如果主页设置为空，自动使用用户资料或默认标题
- ✅ **实时更新**: 无需重启服务，设置后立即生效
- ✅ **数据一致性**: 标题统一从主页设置获取

### **使用场景**：

- 管理员在后台设置个性化的博客标题
- 博客首页头部显示自定义标题
- 支持多语言或季节性标题变更
- 品牌化博客标题管理

现在博客标题将优先从主页设置的 `header_title` 字段获取，实现了统一的标题管理！
