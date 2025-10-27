# 新表部署说明

## 概述

当添加新的数据库表时，有两种方式处理表结构：

### 方式1: SQL脚本 + SQLModel自动创建（推荐）

1. **创建SQL脚本** - 放在 `backend/sql/` 目录下
2. **创建SQLModel模型** - 放在 `backend/app/models/` 目录下
3. **导入模型** - 在 `backend/app/main.py` 中导入模型

#### 工作原理

- **首次部署**: `deploy.sh` 会执行所有 `.sql` 文件创建基础表
- **应用启动**: `initialize_database()` 会自动创建不存在的表
- **更新部署**: 新表由SQLModel自动创建，无需手动SQL

#### 示例：post_like_tracking 表

1. **SQL脚本**: `backend/sql/post_like_tracking.sql`
```sql
CREATE TABLE IF NOT EXISTS `post_like_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '文章ID',
  `user_ip` varchar(45) NOT NULL COMMENT '用户IP地址',
  ...
);
```

2. **SQLModel模型**: `backend/app/models/postLikeTracking.py`
```python
class PostLikeTracking(PostLikeTrackingBase, table=True):
    __tablename__ = "post_like_tracking"
    ...
```

3. **导入模型**: `backend/app/main.py`
```python
from app.models.postLikeTracking import PostLikeTracking  # noqa: F401
```

### 方式2: 纯SQLModel自动创建

如果不想手动编写SQL，可以依赖SQLModel的自动表创建功能：

1. 创建SQLModel模型
2. 在 `main.py` 中导入模型
3. `initialize_database()` 会自动创建表

**注意**: 这只适用于首次创建表，已有表的结构变更需要手动SQL迁移。

## 部署流程

### 开发环境

```bash
# 启动服务，SQLModel会自动创建新表
cd backend
python -m uvicorn app.main:app --reload
```

### 生产环境（Docker）

```bash
# 1. 添加新模型后，重新构建
docker compose -f docker-compose.prod.yml build --no-cache backend

# 2. 重启服务
docker compose -f docker-compose.prod.yml up -d --force-recreate backend

# 3. 检查新表是否创建
docker exec mikko_mysql mysql -umikko -pmikko_pass mikkoBlog -e "SHOW TABLES LIKE 'post_like_tracking'"
```

## 当前新增表

### post_like_tracking（点赞追踪表）

- **文件**: `backend/sql/post_like_tracking.sql`
- **模型**: `backend/app/models/postLikeTracking.py`
- **用途**: 记录用户IP和点赞历史，防止重复点赞
- **特点**: SQLModel自动创建，无需手动迁移

## 注意事项

1. **首次部署**: SQL脚本创建基础表
2. **后续更新**: 新表由SQLModel自动创建
3. **数据迁移**: 表结构变更需要编写迁移SQL
4. **备份**: 建议在升级前备份数据库

## 验证部署

```bash
# 检查表是否存在
docker exec mikko_mysql mysql -umikko -pmikko_pass mikkoBlog -e "SHOW TABLES"

# 查看表结构
docker exec mikko_mysql mysql -umikko -pmikko_pass mikkoBlog -e "DESCRIBE post_like_tracking"

# 查看是否有数据
docker exec mikko_mysql mysql -umikko -pmikko_pass mikkoBlog -e "SELECT COUNT(*) FROM post_like_tracking"
```
