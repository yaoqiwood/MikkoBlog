# Post Stats API 使用说明

## 数据库表结构

```sql
CREATE TABLE `post_stats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `view_count` int NOT NULL DEFAULT '0' COMMENT '观看次数',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞次数',
  `share_count` int NOT NULL DEFAULT '0' COMMENT '分享次数',
  `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论次数',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `post_id` (`post_id`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_share_count` (`share_count`),
  KEY `idx_comment_count` (`comment_count`),
  CONSTRAINT `fk_post_stats_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章统计数据表';
```

## API 接口

### 1. 创建文章统计数据
```http
POST /api/post-stats
Content-Type: application/json

{
  "post_id": 1,
  "view_count": 0,
  "like_count": 0,
  "share_count": 0,
  "comment_count": 0
}
```

### 2. 获取指定文章的统计数据
```http
GET /api/post-stats/{post_id}
```

### 3. 获取所有文章的统计数据
```http
GET /api/post-stats?skip=0&limit=100
```

### 4. 更新文章统计数据
```http
PUT /api/post-stats/{post_id}
Content-Type: application/json

{
  "view_count": 100,
  "like_count": 50,
  "share_count": 10,
  "comment_count": 5
}
```

### 5. 增加文章统计数据（批量）
```http
PATCH /api/post-stats/{post_id}/increment
Content-Type: application/json

{
  "view_count": 1,
  "like_count": 1,
  "share_count": 0,
  "comment_count": 0
}
```

### 6. 增加观看次数
```http
POST /api/post-stats/{post_id}/view
```

### 7. 增加点赞次数
```http
POST /api/post-stats/{post_id}/like
```

### 8. 增加分享次数
```http
POST /api/post-stats/{post_id}/share
```

### 9. 增加评论次数
```http
POST /api/post-stats/{post_id}/comment
```

### 10. 删除文章统计数据
```http
DELETE /api/post-stats/{post_id}
```

### 11. 获取热门文章
```http
GET /api/post-stats/top/popular?limit=10&sort_by=view_count
```

支持的排序字段：
- `view_count`: 按观看次数排序
- `like_count`: 按点赞次数排序
- `share_count`: 按分享次数排序
- `comment_count`: 按评论次数排序

## 使用场景

1. **文章浏览**: 当用户访问文章时，调用 `POST /api/post-stats/{post_id}/view` 增加观看次数
2. **文章点赞**: 当用户点赞文章时，调用 `POST /api/post-stats/{post_id}/like` 增加点赞次数
3. **文章分享**: 当用户分享文章时，调用 `POST /api/post-stats/{post_id}/share` 增加分享次数
4. **文章评论**: 当用户评论文章时，调用 `POST /api/post-stats/{post_id}/comment` 增加评论次数
5. **热门文章**: 使用 `GET /api/post-stats/top/popular` 获取热门文章列表

## 注意事项

1. 每个文章只能有一个统计数据记录（通过 `post_id` 唯一约束保证）
2. 如果文章不存在统计数据，调用增加接口时会自动创建
3. 删除文章时会自动删除对应的统计数据（CASCADE 约束）
4. 所有统计数据的初始值都是 0

