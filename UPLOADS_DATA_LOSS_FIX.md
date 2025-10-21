# 静态资源 (Uploads) 数据丢失问题修复

## 问题描述

部署完成后，网站上的图片全部返回 404 错误：

```
GET https://www.mikkocat.top/uploads/images/20251017_140746_99a8c1c3.jpg 404 (Not Found)
```

## 根本原因

**在部署脚本中使用了错误的 `git clean` 命令，导致用户上传的数据被删除！**

### 问题代码

```bash
# ❌ 错误：会删除所有未被 git 跟踪的文件
git clean -fd
```

这个命令会删除：
- ✗ `backend/uploads/images/` 中的所有图片
- ✗ `backend/uploads/music/` 中的所有音乐文件
- ✗ 所有用户上传的数据

### 为什么会影响生产环境

Docker Compose 使用了**绑定挂载 (bind mount)**：

```yaml
# docker-compose.prod.yml
volumes:
  - ./backend/uploads:/app/uploads  # 宿主机目录 -> 容器内目录
```

这意味着：
1. 容器内的 `/app/uploads` 直接使用宿主机的 `./backend/uploads` 目录
2. 如果宿主机的目录被删除，容器内也无法访问
3. **每次部署时 `git clean -fd` 都会删除这个目录！**

## 影响范围

### 受影响的文件

1. ❌ `github-deploy.sh` - GitHub Actions 自动部署脚本
2. ❌ `server-deploy.sh` - 服务器部署脚本
3. ❌ `server-deploy-root.sh` - Root 用户部署脚本

### 受影响的数据

- 所有用户上传的图片（博客文章配图、头像等）
- 所有上传的音乐文件
- 其他 uploads 目录中的文件

## 修复方案

### 1. 修复部署脚本

**正确的做法：排除 uploads 目录**

```bash
# ✅ 正确：清理未跟踪的文件，但保留 uploads 目录
git clean -fd -e backend/uploads -e uploads
```

**说明：**
- `-f` : force（强制）
- `-d` : 删除目录
- `-e backend/uploads` : 排除 backend/uploads 目录
- `-e uploads` : 排除 uploads 目录

### 2. 恢复丢失的数据

如果你有旧的部署路径（如 `/var/www/mikkoblog`），可以使用恢复脚本：

```bash
# 在服务器上运行
cd /opt/mikkoblog
chmod +x restore-uploads.sh
./restore-uploads.sh
```

这个脚本会：
1. 从旧路径复制 uploads 目录到新路径
2. 设置正确的文件权限
3. 显示恢复的文件统计信息

### 3. 手动恢复步骤

如果没有自动恢复脚本，可以手动执行：

```bash
# 1. 检查旧路径是否有数据
ls -lah /var/www/mikkoblog/backend/uploads/images/

# 2. 复制数据到新路径
rsync -av /var/www/mikkoblog/backend/uploads/ /opt/mikkoblog/backend/uploads/

# 3. 设置权限
chmod -R 755 /opt/mikkoblog/backend/uploads

# 4. 重启 Docker 服务
cd /opt/mikkoblog
docker-compose -f docker-compose.prod.yml restart

# 5. 验证文件可访问
curl -I https://www.mikkocat.top/uploads/images/20251017_140746_99a8c1c3.jpg
```

## 预防措施

### 方案 A：使用 git clean 排除（推荐）

已在修复中实施，每次部署时保留 uploads 目录。

### 方案 B：使用 Docker Named Volume

修改 `docker-compose.prod.yml`：

```yaml
services:
  backend:
    volumes:
      - uploads_data:/app/uploads  # 使用命名卷而不是绑定挂载
      - ./backend/config:/app/config

volumes:
  db_data:
  uploads_data:  # 新增命名卷
```

**优点：**
- 数据独立于代码目录
- 不会被 git clean 影响
- Docker 自动管理

**缺点：**
- 数据备份需要额外步骤
- 不能直接在宿主机访问文件

### 方案 C：分离数据目录

将 uploads 目录放在项目目录外：

```yaml
services:
  backend:
    volumes:
      - /var/uploads:/app/uploads  # 使用独立的数据目录
```

## 验证修复

### 1. 检查部署脚本

```bash
# 确认包含 -e 参数
grep "git clean" github-deploy.sh
# 应该看到：git clean -fd -e backend/uploads -e uploads
```

### 2. 检查文件存在

```bash
# 在服务器上
ls -lah /opt/mikkoblog/backend/uploads/images/
```

### 3. 测试 API 访问

```bash
# 健康检查
curl http://localhost:8000/api/healthz

# 测试图片访问（从容器内）
docker exec mikko_backend ls -lah /app/uploads/images/

# 测试图片访问（通过 HTTP）
curl -I https://www.mikkocat.top/uploads/images/20251017_140746_99a8c1c3.jpg
```

## 部署路径说明

### 当前部署架构

```
┌─────────────────────────────────────────────┐
│  GitHub Repository (yaoqiwood/MikkoBlog)   │
│  ↓ push to cicd-deploy branch              │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  GitHub Actions (自动触发)                  │
│  - SSH 连接到服务器                         │
│  - 执行 github-deploy.sh                    │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  服务器: /opt/mikkoblog (新部署路径)        │
│  - git pull 最新代码                        │
│  - docker-compose up (重新构建和启动)       │
│  - volumes:                                 │
│    - ./backend/uploads:/app/uploads         │
└─────────────────────────────────────────────┘
```

### 旧部署路径

- `/var/www/mikkoblog` - 之前手动部署的路径（可能包含旧的 uploads 数据）

### 为什么有两个路径

1. **旧路径** (`/var/www/mikkoblog`)：
   - 手动部署时创建
   - 可能包含之前上传的所有数据
   - 代码可能已经过时

2. **新路径** (`/opt/mikkoblog`)：
   - GitHub Actions 自动部署
   - 在 `CICD_SETUP.md` 中配置
   - 代码始终保持最新

## 备份建议

### 定期备份 uploads 目录

创建定时任务：

```bash
# 添加到 crontab
crontab -e

# 每天凌晨 3 点备份
0 3 * * * rsync -av /opt/mikkoblog/backend/uploads /backup/uploads-$(date +\%Y\%m\%d)
```

### 备份脚本

```bash
#!/bin/bash
BACKUP_DIR="/backup/mikkoblog"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/uploads-$DATE.tar.gz" -C /opt/mikkoblog/backend uploads

# 保留最近 7 天的备份
find "$BACKUP_DIR" -name "uploads-*.tar.gz" -mtime +7 -delete
```

## 提交记录

```bash
# 查看修复提交
git log --oneline --grep="uploads"

# 修复提交应包含：
# - 恢复 git clean -fd -e backend/uploads -e uploads
# - 添加恢复脚本 restore-uploads.sh
# - 添加本说明文档
```

## 总结

- ❌ **问题**：`git clean -fd` 删除了用户上传的所有文件
- ✅ **修复**：使用 `git clean -fd -e backend/uploads -e uploads` 排除 uploads 目录
- 🔄 **恢复**：使用 `restore-uploads.sh` 从旧路径恢复数据
- 🛡️ **预防**：定期备份 uploads 目录

**重要提醒：** uploads 目录包含用户数据，绝对不能在部署时被清除！

