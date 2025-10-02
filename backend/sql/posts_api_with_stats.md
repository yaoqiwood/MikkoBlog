# Posts API 联表查询 PostStats 功能

## 📊 功能说明

posts 接口现在支持联表查询 PostStats 统计数据，返回的文章列表将包含以下统计信息：

- `view_count`: 观看次数
- `like_count`: 点赞次数
- `share_count`: 分享次数
- `comment_count`: 评论次数

## 🔗 API 接口

### 获取文章列表（包含统计数据）

```http
GET /api/posts/?page=1&limit=10&is_visible=true&is_deleted=false
```

**参数说明：**
- `page`: 页码（从1开始）
- `limit`: 每页数量（1-100）
- `is_visible`: 是否可见筛选（可选）
- `is_deleted`: 是否已删除筛选（可选）

**响应示例：**

```json
[
  {
    "id": 1,
    "title": "文章标题",
    "content": "文章内容",
    "summary": "文章摘要",
    "cover_image_url": "https://example.com/image.jpg",
    "is_published": true,
    "is_deleted": false,
    "is_visible": true,
    "user_id": 1,
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00",
    "user_nickname": "作者昵称",
    "user_avatar": "https://example.com/avatar.jpg",
    "view_count": 100,
    "like_count": 25,
    "share_count": 5,
    "comment_count": 10
  }
]
```

## 🔧 技术实现

### 1. 数据库查询

使用 LEFT JOIN 联表查询：

```sql
SELECT post.*, user_profiles.*, post_stats.*
FROM post
JOIN user_profiles ON post.user_id = user_profiles.user_id
LEFT JOIN post_stats ON post.id = post_stats.post_id
WHERE post.is_deleted = false
ORDER BY post.created_at DESC
LIMIT 10 OFFSET 0;
```

### 2. 模型更新

`PostRead` 模型新增统计字段：

```python
class PostRead(PostBase):
    id: int
    created_at: datetime
    updated_at: datetime
    # 用户信息字段
    user_nickname: Optional[str] = None
    user_avatar: Optional[str] = None
    # 统计数据字段
    view_count: Optional[int] = 0
    like_count: Optional[int] = 0
    share_count: Optional[int] = 0
    comment_count: Optional[int] = 0
```

### 3. 查询逻辑

- 使用 `outerjoin` 确保即使没有统计数据的文章也会被返回
- 统计数据默认为 0（如果文章没有对应的统计数据记录）
- 保持原有的分页、筛选和排序功能

## 📝 使用场景

1. **文章列表页面**: 显示文章及其统计数据
2. **热门文章**: 基于统计数据排序
3. **文章详情**: 显示文章的受欢迎程度
4. **数据分析**: 统计文章的互动情况

## 🚀 测试方法

1. **启动后端服务**:
   ```bash
   cd backend
   python app/main.py
   ```

2. **测试接口**:
   ```bash
   python test_posts_api.py
   ```

3. **手动测试**:
   ```bash
   curl "http://localhost:8000/api/posts/?page=1&limit=10&is_visible=true&is_deleted=false"
   ```

## ⚠️ 注意事项

1. **性能优化**: 联表查询可能影响性能，建议在数据量大时考虑缓存
2. **数据一致性**: 统计数据通过 PostStats API 单独维护
3. **默认值**: 没有统计数据的文章，所有统计字段默认为 0
4. **兼容性**: 保持与原有 API 的完全兼容
