# 健康检查端点修复说明

## 问题描述

在 GitHub Actions 部署过程中，遇到后端 API 健康检查失败的问题：

```
❌ 后端API健康检查失败
```

## 根本原因

**健康检查端点路径错误**

后端实际端点：
- 定义在 `backend/app/api/routers/health.py` 中
- 端点路径：`/healthz`
- 挂载路径：`/api` (在 `main.py` 第 43 行)
- **完整路径应该是：`/api/healthz`**

但是部署脚本中使用的是错误的路径：
- ❌ 使用了：`http://localhost:8000/health`
- ✅ 应该是：`http://localhost:8000/api/healthz`

## 修复内容

已修复以下 5 个文件中的健康检查端点路径：

### 1. `.github/workflows/deploy.yml`
GitHub Actions 工作流中的健康检查

**修改位置：**
```yaml
# 修改前
if curl -f http://localhost:8000/health 2>/dev/null; then

# 修改后
if curl -f http://localhost:8000/api/healthz 2>/dev/null; then
```

### 2. `github-deploy.sh`
GitHub Actions 部署脚本（2 处修改）

**位置 1：** 等待服务就绪检查
```bash
# 修改前
timeout 60 bash -c 'until curl -f http://localhost:8000/health 2>/dev/null; do sleep 2; done'

# 修改后
timeout 60 bash -c 'until curl -f http://localhost:8000/api/healthz 2>/dev/null; do sleep 2; done'
```

**位置 2：** 健康检查
```bash
# 修改前
if curl -f http://localhost:8000/health 2>/dev/null; then

# 修改后
if curl -f http://localhost:8000/api/healthz 2>/dev/null; then
```

### 3. `server-deploy.sh`
服务器部署脚本

### 4. `server-deploy-root.sh`
服务器 root 用户部署脚本

### 5. `deploy.sh`
通用部署脚本

## 验证方法

部署完成后，可以通过以下命令验证健康检查端点：

```bash
# 本地测试
curl http://localhost:8000/api/healthz

# 预期响应
{"status":"ok"}

# 或者使用 -f 参数（失败时返回非 0 状态码）
curl -f http://localhost:8000/api/healthz && echo "✅ 健康检查通过"
```

## 提交信息

```
commit 11b9494
fix: 修复健康检查端点路径从 /health 到 /api/healthz

修改文件：
- .github/workflows/deploy.yml
- github-deploy.sh (2 处)
- server-deploy.sh
- server-deploy-root.sh
- deploy.sh
```

## 影响范围

- ✅ 修复了所有部署脚本中的健康检查
- ✅ GitHub Actions 工作流现在可以正确验证后端服务状态
- ✅ 不影响现有功能，只是修正了检查逻辑

## 后续部署

下次推送到 `cicd-deploy` 分支时，GitHub Actions 将：
1. 自动触发部署
2. 正确检查后端服务健康状态
3. 部署验证步骤将成功通过

## 相关端点

| 端点 | 路径 | 说明 |
|-----|------|-----|
| 健康检查 | `/api/healthz` | 返回 `{"status":"ok"}` |
| API 文档 | `/docs` | FastAPI 自动生成的 Swagger 文档 |
| API 文档 (ReDoc) | `/redoc` | ReDoc 格式的 API 文档 |

## 故障排查

如果健康检查仍然失败，可以：

1. **检查容器状态**
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```

2. **查看后端日志**
   ```bash
   docker-compose -f docker-compose.prod.yml logs backend
   ```

3. **手动测试端点**
   ```bash
   # 进入容器
   docker exec -it mikko_backend bash

   # 测试健康检查
   curl http://localhost:8000/api/healthz
   ```

4. **检查网络连接**
   ```bash
   docker network ls
   docker network inspect mikkoblog_default
   ```

## 总结

这是一个简单但关键的修复，确保部署流程能够正确验证服务状态。现在所有的部署脚本都使用正确的健康检查端点 `/api/healthz`。
