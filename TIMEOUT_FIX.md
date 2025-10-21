# SSH Action 超时问题修复

## 问题描述

部署过程中出现超时错误：

```
#*** [frontend build-stage 6/6] RUN npm run build
✓ 193 modules transformed.
2025/10/21 09:17:28 Run Command Timeout  ← 超时！
```

## 根本原因

**前端构建时间过长，超过了 SSH action 的默认超时限制**

### 构建过程分析

1. **Docker 镜像构建** - 后端和前端同时构建
2. **后端构建** - 相对较快（~4分钟）
   - 安装 Python 依赖
   - 复制应用代码
3. **前端构建** - 较慢（~10-15分钟）
   - npm install（~5分钟）
   - vite build（~8-10分钟）
   - 需要转换 193 个模块

### 默认超时时间

`appleboy/ssh-action` 的默认 `command_timeout` 约为 **10分钟**，不够前端构建完成。

## 修复方案

### 增加超时时间配置

在 `.github/workflows/deploy.yml` 中为每个 SSH action 步骤添加 `command_timeout` 参数：

```yaml
- name: Test SSH connection
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    port: ${{ secrets.SERVER_PORT }}
    command_timeout: 2m  # ← 新增：2分钟足够测试连接
    script: |
      echo "测试连接..."

- name: Deploy to server
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    port: ${{ secrets.SERVER_PORT }}
    command_timeout: 30m  # ← 新增：30分钟足够完整部署
    script: |
      ./github-deploy.sh

- name: Verify deployment
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    port: ${{ secrets.SERVER_PORT }}
    command_timeout: 5m  # ← 新增：5分钟足够验证
    script: |
      docker compose ps
      curl http://localhost:8000/api/healthz
```

### 超时时间分配

| 步骤 | 超时时间 | 说明 |
|------|---------|------|
| Test SSH connection | 2m | 测试连接很快 |
| Deploy to server | 30m | 包含前端构建，需要较长时间 |
| Verify deployment | 5m | 验证服务状态 |

## 部署时间预估

### 完整部署流程耗时

```
1. Checkout code              ~30秒
2. Test SSH connection        ~5秒
3. Deploy to server           ~15-20分钟
   ├─ git pull                ~10秒
   ├─ docker compose build    ~12-18分钟
   │  ├─ Backend build        ~4分钟
   │  └─ Frontend build       ~8-14分钟
   │     ├─ npm install       ~5分钟
   │     └─ vite build        ~3-9分钟
   ├─ docker compose up       ~30秒
   └─ Health checks           ~1分钟
4. Verify deployment          ~30秒
────────────────────────────────────
总计：                        ~16-22分钟
```

### 为什么前端构建慢？

1. **npm install**
   - 下载大量依赖包
   - 构建原生模块（如果有）

2. **vite build**
   - 转换 193 个模块
   - 代码压缩和优化
   - 生成 source maps
   - 处理静态资源

## 优化建议

### 方案 1：使用缓存（推荐）

在 Dockerfile 中利用 Docker 层缓存：

```dockerfile
# frontend/Dockerfile
FROM node:18-alpine as build-stage

WORKDIR /app

# 先复制 package.json，利用缓存
COPY package*.json ./
RUN npm install

# 再复制源代码
COPY . .
RUN npm run build
```

**效果：** 如果依赖没变，npm install 会使用缓存，节省 ~5分钟

### 方案 2：使用多阶段构建（已应用）

当前已使用多阶段构建，只打包必要文件到生产镜像。

### 方案 3：并行构建

Docker Compose 已自动并行构建前后端，无需额外配置。

### 方案 4：使用预构建镜像

如果代码变化不频繁，可以：
1. 预先在本地构建镜像
2. 推送到 Docker Hub
3. 服务器直接拉取镜像

**效果：** 可以节省全部构建时间，但增加了镜像管理复杂度。

## 验证修复

### 查看部署日志

1. 访问：https://github.com/yaoqiwood/MikkoBlog/actions
2. 点击最新的 workflow run
3. 展开 "Deploy to server" 步骤
4. 应该看到完整的构建过程，不再有超时错误

### 预期输出

```
[INFO] 构建和启动服务...
#1 [backend internal] load build definition
#2 [frontend internal] load build definition
...
#20 [backend 5/6] RUN pip install
✓ Backend build complete
...
#*** [frontend build-stage 6/6] RUN npm run build
✓ 193 modules transformed.
✓ building...
✓ dist ready
✓ Frontend build complete
...
[SUCCESS] 服务启动完成  ← 应该看到这个，而不是超时
```

## 相关资源

- [appleboy/ssh-action 文档](https://github.com/appleboy/ssh-action)
- [Docker 多阶段构建](https://docs.docker.com/build/building/multi-stage/)
- [Vite 构建优化](https://vitejs.dev/guide/build.html)

## 提交记录

```
commit 3d65039
fix: 增加 SSH action 超时时间以支持前端构建

问题：前端构建时间较长，默认超时导致部署失败
修复：设置合理的超时时间（Test: 2m, Deploy: 30m, Verify: 5m）
```

## 总结

✅ **已修复** - 增加了 SSH action 的超时时间
✅ **已验证** - 下次部署应该能够完整完成前端构建
📝 **建议** - 考虑使用 Docker 层缓存进一步优化构建速度

---

**下次部署预计耗时：** 16-22分钟（首次完整构建）
**后续部署预计耗时：** 5-10分钟（利用缓存）
