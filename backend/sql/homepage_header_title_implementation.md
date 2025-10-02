# 主页标题设置功能完整实现

## ✅ **功能实现完成**

### **数据库表结构**

```sql
-- home_page_settings 表
CREATE TABLE IF NOT EXISTS home_page_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    header_title VARCHAR(255) DEFAULT NULL,  -- 新增字段
    banner_image_url TEXT,
    background_image_url TEXT,
    show_music_player INTEGER DEFAULT 0,
    music_url TEXT,
    show_live2d INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **后端修改**

1. **模型更新** (`backend/app/models/homepage.py`):
   ```python
   class HomePageSettingsBase(SQLModel):
       header_title: Optional[str] = None  # 新增字段
       banner_image_url: Optional[str] = None
       # ... 其他字段
   ```

2. **API 路由** (`backend/app/api/routers/homepage.py`):
   - 自动支持 `header_title` 的 CRUD 操作
   - 在 `sync_system_defaults` 中添加了同步逻辑

3. **数据库迁移** (`backend/sql/add_header_title_to_homepage.sql`):
   ```sql
   ALTER TABLE home_page_settings ADD COLUMN header_title VARCHAR(255) DEFAULT NULL;
   ```

### **前端修改**

1. **表单字段** (`frontend/src/pages/admin/HomepageSettings.vue`):
   ```vue
   <FormItem label="主页标题">
     <Input v-model="form.header_title" placeholder="请输入主页标题" />
   </FormItem>
   ```

2. **数据绑定**:
   ```javascript
   const form = ref({
     header_title: '',  // 新增字段
     banner_image_url: '',
     // ... 其他字段
   });
   ```

### **API 接口**

- **获取设置**: `GET /api/homepage/settings`
- **更新设置**: `PUT /api/homepage/settings`

**请求示例**:
```json
{
  "header_title": "我的博客",
  "banner_image_url": "...",
  "background_image_url": "...",
  "show_music_player": false,
  "music_url": "",
  "show_live2d": false
}
```

**响应示例**:
```json
{
  "id": 1,
  "header_title": "我的博客",
  "banner_image_url": "...",
  "background_image_url": "...",
  "show_music_player": false,
  "music_url": "",
  "show_live2d": false,
  "created_at": "2024-01-01T00:00:00",
  "updated_at": "2024-01-01T00:00:00"
}
```

### **部署步骤**

1. **执行数据库迁移**:
   ```bash
   # 如果使用 SQLite
   sqlite3 dev.db < backend/sql/add_header_title_to_homepage.sql

   # 如果使用 MySQL
   mysql -u username -p database_name < backend/sql/add_header_title_to_homepage.sql
   ```

2. **重启后端服务**:
   ```bash
   cd backend
   python app/main.py
   ```

3. **前端无需额外操作**，刷新页面即可使用

### **功能特点**

- ✅ **数据持久化**: 保存在 `home_page_settings` 表的 `header_title` 字段
- ✅ **API 集成**: 通过 homepage API 进行 CRUD 操作
- ✅ **系统默认值**: 支持从系统默认设置恢复
- ✅ **表单验证**: 支持输入验证和错误提示
- ✅ **实时保存**: 点击保存按钮立即生效

### **使用场景**

- 管理员在后台设置博客的主页标题
- 标题显示在博客首页的头部
- 支持动态修改，无需重启服务
- 可以随时恢复默认设置

现在主页标题设置功能已完全集成到 `home_page_settings` 表中！
