# 磁盘空间不足问题解决方案

## 问题描述

Docker 构建时出现磁盘空间不足错误：

```
E: You don't have enough free space in /var/cache/apt/archives/.
Need to get 86.7 MB of archives.
After this operation, 356 MB of additional disk space will be used.
```

## 根本原因

**服务器磁盘空间被 Docker 资源占满**

### Docker 占用空间的主要来源

1. **Docker 镜像** - 每次 `docker compose build` 都会创建新镜像，旧镜像不会自动删除
2. **悬空镜像（Dangling Images）** - 构建失败或被替换的中间层镜像
3. **构建缓存** - Docker layer 缓存
4. **停止的容器** - 已停止但未删除的容器
5. **未使用的卷** - 孤立的数据卷
6. **系统缓存** - APT 包缓存、日志文件等

### 空间占用示例

```
典型的 Docker 空间占用：
- 镜像: 5-10 GB
- 构建缓存: 3-5 GB
- 悬空镜像: 2-4 GB
- 容器: 1-2 GB
- 卷: 1-3 GB
- 系统缓存: 1-2 GB
──────────────────────
总计: 13-26 GB
```

## 立即解决方案

### 方案 1：运行清理脚本（推荐）

在服务器上运行：

```bash
# SSH 到服务器
ssh your-username@your-server-ip

# 进入项目目录
cd /var/www/mikkoblog  # 或 /opt/mikkoblog

# 拉取最新代码（包含清理脚本）
git pull origin cicd-deploy

# 运行清理脚本
chmod +x cleanup-docker.sh
sudo ./cleanup-docker.sh
```

### 方案 2：手动清理命令

如果无法运行脚本，手动执行以下命令：

```bash
# 1. 清理停止的容器
docker container prune -f

# 2. 清理悬空镜像
docker image prune -f

# 3. 清理构建缓存（释放大量空间）
docker builder prune -a -f

# 4. 清理未使用的卷
docker volume prune -f

# 5. 清理系统缓存
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove -y

# 6. 清理日志
sudo journalctl --vacuum-time=7d

# 7. 一键清理所有未使用的资源（慎用）
docker system prune -a -f --volumes
```

### 方案 3：检查磁盘使用情况

```bash
# 查看总体磁盘使用
df -h

# 查看 Docker 磁盘使用
docker system df

# 查看详细信息
docker system df -v

# 查看大文件
du -sh /var/lib/docker/*
```

## 预防措施

### 1. 修改部署脚本，自动清理

在 `github-deploy.sh` 的 `start_services()` 函数中添加清理步骤：

```bash
start_services() {
    log_info "构建和启动服务..."

    # 在构建前清理旧资源
    log_info "清理旧的 Docker 资源..."
    docker image prune -f
    docker builder prune -f

    # 构建镜像
    docker compose -f docker-compose.prod.yml build --no-cache

    # 启动服务
    docker compose -f docker-compose.prod.yml up -d

    log_success "服务启动完成"
}
```

### 2. 使用 .dockerignore

确保不打包不必要的文件到镜像：

```bash
# backend/.dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.Python
venv/
*.log
.git
.gitignore
uploads/
```

### 3. 定期清理计划

设置定时任务自动清理：

```bash
# 编辑 crontab
crontab -e

# 添加每周日凌晨 3 点清理任务
0 3 * * 0 docker system prune -a -f --volumes && docker builder prune -a -f
```

### 4. 监控磁盘空间

```bash
# 安装监控脚本
cat > /usr/local/bin/check-disk.sh << 'EOF'
#!/bin/bash
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 80 ]; then
    echo "警告：磁盘使用率 ${USAGE}%，需要清理！"
    docker system df
fi
EOF

chmod +x /usr/local/bin/check-disk.sh

# 每天运行检查
echo "0 8 * * * /usr/local/bin/check-disk.sh" | crontab -
```

## 修改后的部署脚本

已修改 `github-deploy.sh`，在构建前自动清理：

```bash
# 构建和启动服务
start_services() {
    log_info "构建和启动服务..."

    # 清理旧资源以释放空间
    log_info "清理旧的 Docker 资源..."
    docker image prune -f || true
    docker builder prune -f || true
    docker container prune -f || true

    # 构建镜像
    docker compose -f docker-compose.prod.yml build --no-cache

    # 启动服务
    docker compose -f docker-compose.prod.yml up -d

    log_success "服务启动完成"
}
```

## 优化 Dockerfile

### 减小镜像体积

**后端 Dockerfile 优化：**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# 1. 只安装必要的包
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 2. 使用 .dockerignore 排除不必要的文件
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY backend /app

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**前端 Dockerfile 优化：**

```dockerfile
# 构建阶段
FROM node:18-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# 生产阶段 - 只包含必要文件
FROM nginx:alpine
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 检查清单

清理后，验证以下内容：

- [ ] 磁盘使用率低于 80%
- [ ] Docker 镜像数量合理（< 10个）
- [ ] 没有悬空镜像
- [ ] 构建缓存已清理
- [ ] 容器正常运行
- [ ] 服务可以访问

## 常见问题

### Q1: 清理会影响正在运行的服务吗？

**A:** 不会。清理命令只删除：
- 停止的容器
- 未使用的镜像
- 悬空的资源

正在运行的容器和它们使用的镜像不会被删除。

### Q2: 如何查看哪些镜像占用空间最大？

```bash
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | sort -k2 -h -r | head -10
```

### Q3: 可以删除所有镜像吗？

**A:** 可以，但需要先停止所有容器：

```bash
# 停止所有容器
docker compose -f docker-compose.prod.yml down

# 删除所有镜像
docker rmi $(docker images -q) -f

# 重新构建
docker compose -f docker-compose.prod.yml up -d --build
```

### Q4: 如何扩大磁盘空间？

如果清理后空间仍不足，考虑：
1. 升级服务器（增加磁盘）
2. 挂载额外的存储卷
3. 将 `/var/lib/docker` 移到更大的分区

## 相关命令参考

```bash
# 查看所有 Docker 对象
docker ps -a           # 所有容器
docker images -a       # 所有镜像
docker volume ls       # 所有卷
docker network ls      # 所有网络

# 查看空间使用
docker system df       # 总览
docker system df -v    # 详细信息

# 清理命令
docker container prune # 清理容器
docker image prune     # 清理镜像
docker volume prune    # 清理卷
docker network prune   # 清理网络
docker system prune    # 清理所有

# 强制清理（慎用）
docker system prune -a -f --volumes  # 清理所有未使用的资源
```

## 总结

✅ **立即行动**：运行 `cleanup-docker.sh` 清理脚本
✅ **预防措施**：修改部署脚本，自动清理旧资源
✅ **定期维护**：设置定时清理任务
✅ **监控告警**：监控磁盘使用率

---

**清理后应该释放 5-15 GB 空间，足够完成部署！**
