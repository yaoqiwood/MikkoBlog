# HomepageSettings.vue 主页标题设置功能

## ✅ **功能实现完成**

### **主要修改内容**：

1. **📝 表单字段添加**：
   - 在表单最上方添加了"主页标题"输入框
   - 使用 `Input` 组件，支持双向绑定

2. **🔧 数据结构更新**：
   - 在 `form` 对象中添加 `header_title` 字段
   - 在 `load` 函数中加载 `header_title` 数据
   - 在 `resetToDefault` 函数中处理默认值

3. **💾 数据持久化**：
   - 通过 `homepageApi.updateSettings` 保存到后端
   - 支持从系统默认设置中恢复默认值

### **表单结构**：

```vue
<FormItem label="主页标题">
  <Input v-model="form.header_title" placeholder="请输入主页标题" />
</FormItem>
```

### **数据流程**：

1. **加载**: 从后端 API 获取 `header_title` 设置
2. **编辑**: 用户在前端输入框中修改标题
3. **保存**: 通过 `save()` 函数保存到后端
4. **重置**: 支持恢复默认设置

### **API 集成**：

- **获取设置**: `homepageApi.getSettings()` - 包含 `header_title`
- **更新设置**: `homepageApi.updateSettings()` - 保存 `header_title`
- **默认设置**: `/api/system/defaults/category/homepage` - 获取默认值

### **使用场景**：

- 管理员可以设置博客的主页标题
- 标题会显示在博客首页的头部
- 支持实时预览和保存
- 可以随时恢复默认设置

现在管理员可以在主页设置页面中设置主页标题了！
