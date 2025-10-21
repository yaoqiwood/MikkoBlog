# 修改部署路径指南

## 问题说明

原部署路径为 `/opt/mikkoblog`，但用户上传的数据（uploads 目录）在旧的部署路径 `/var/www/mikkoblog` 中。为了使用现有数据，需要将部署路径改回 `/var/www/mikkoblog`。

## 已完成的修改

✅ 已修改以下文件中的路径配置：

1. `github-deploy.sh` - GitHub Actions 部署脚本
   ```bash
   PROJECT_DIR="/var/www/mikkoblog"
   ```

2. `server-deploy.sh` - 服务器部署脚本
   ```bash
   PROJECT_DIR="/var/www/mikkoblog"
   ```

3. `server-deploy-root.sh` - Root 用户部署脚本
   ```bash
   PROJECT_DIR="/var/www/mikkoblog"
   ```

4. `CICD_SETUP.md` - 文档更新
   ```
   PROJECT_PATH: /var/www/mikkoblog
   ```

## 🎯 你需要完成的操作

### 步骤 1：修改 GitHub Secrets（重要！）

**必须在 GitHub 网页上修改 `PROJECT_PATH` secret：**

1. 访问：https://github.com/yaoqiwood/MikkoBlog/settings/secrets/actions
2. 找到 `PROJECT_PATH` secret
3. 点击右侧的 **Update** 按钮
4. 将值从 `/opt/mikkoblog` 改为：`/var/www/mikkoblog`
5. 点击 **Update secret** 保存

### 步骤 2：提交代码修改

```bash
cd /Users/jianshujie/MikkoBlog

# 查看修改
git status

# 提交修改
git add github-deploy.sh server-deploy.sh server-deploy-root.sh CICD_SETUP.md CHANGE_DEPLOY_PATH.md
git commit -m "fix: 修改部署路径从 /opt/mikkoblog 到 /var/www/mikkoblog

- 使用原有的部署路径以保留 uploads 数据
- 修改所有部署脚本中的 PROJECT_DIR
- 更新文档说明"

# 推送到远程
git push origin cicd-deploy
```

### 步骤 3：在服务器上准备

**在服务器上确保 `/var/www/mikkoblog` 存在且有正确的代码：**

```bash
# SSH 连接到服务器
ssh your-username@your-server-ip

# 检查目录是否存在
ls -lah /var/www/mikkoblog

# 检查是否有 uploads 数据
ls -lah /var/www/mikkoblog/backend/uploads/images/

# 检查当前分支和代码状态
cd /var/www/mikkoblog
git status
git branch

# 如果不在 cicd-deploy 分支，需要切换
git fetch origin
git checkout cicd-deploy
git pull origin cicd-deploy
```

### 步骤 4：测试部署

推送代码后，GitHub Actions 会自动触发部署到 `/var/www/mikkoblog`。

或者手动触发：
1. 访问：https://github.com/yaoqiwood/MikkoBlog/actions
2. 选择 "Deploy to Server" workflow
3. 点击 "Run workflow" -> "Run workflow"

### 步骤 5：验证

部署完成后，检查：

```bash
# 1. 检查容器状态
cd /var/www/mikkoblog
docker compose -f docker compose.prod.yml ps

# 2. 检查 uploads 目录
ls -lah /var/www/mikkoblog/backend/uploads/images/

# 3. 测试图片访问
curl -I https://www.mikkocat.top/uploads/images/20251017_140755_203a84df.jpeg

# 应该返回 200 OK，而不是 404
```

## 路径对比

| 项目 | 旧配置 | 新配置 |
|------|--------|--------|
| GitHub Secret | `/opt/mikkoblog` | `/var/www/mikkoblog` ✅ |
| github-deploy.sh | `/opt/mikkoblog` | `/var/www/mikkoblog` ✅ |
| server-deploy.sh | `/opt/mikkoblog` | `/var/www/mikkoblog` ✅ |
| server-deploy-root.sh | `/opt/mikkoblog` | `/var/www/mikkoblog` ✅ |

## 清理旧部署（可选）

如果 `/opt/mikkoblog` 目录还在且不再需要，可以清理：

```bash
# 停止并删除容器（如果还在运行）
cd /opt/mikkoblog
docker compose -f docker compose.prod.yml down

# 备份（以防万一）
sudo tar -czf /backup/opt-mikkoblog-$(date +%Y%m%d).tar.gz /opt/mikkoblog

# 删除目录（谨慎操作）
sudo rm -rf /opt/mikkoblog
```

## 为什么要改路径？

### 原因

1. **数据完整性**：`/var/www/mikkoblog` 包含完整的 uploads 数据
2. **避免数据迁移**：直接使用现有路径，无需复制大量文件
3. **保持一致性**：与之前的手动部署路径保持一致

### Docker 卷映射

```yaml
# docker compose.prod.yml
volumes:
  - ./backend/uploads:/app/uploads  # 绑定挂载
```

- 如果宿主机路径是 `/var/www/mikkoblog/backend/uploads`
- 容器内就能访问到这些文件
- Nginx 代理 `/uploads/` 请求到后端
- 后端返回 `/app/uploads` 中的文件

## 常见问题

### Q1: 修改后旧的 /opt/mikkoblog 还会被使用吗？

**A:** 不会。只要 GitHub Secret 修改为 `/var/www/mikkoblog`，所有部署都会使用新路径。

### Q2: 需要重新构建 Docker 镜像吗？

**A:** 不需要。只是改变了部署路径，代码和镜像内容没变。

### Q3: 如果还是 404 怎么办？

**A:** 检查：

1. **GitHub Secret 是否已更新**
   ```
   访问 GitHub 仓库 Settings -> Secrets -> Actions
   确认 PROJECT_PATH = /var/www/mikkoblog
   ```

2. **服务器上路径是否正确**
   ```bash
   docker inspect mikko_backend | grep -A 10 Mounts
   # 应该看到 /var/www/mikkoblog/backend/uploads
   ```

3. **文件权限是否正确**
   ```bash
   ls -lah /var/www/mikkoblog/backend/uploads/images/
   chmod -R 755 /var/www/mikkoblog/backend/uploads
   ```

4. **容器是否重启**
   ```bash
   cd /var/www/mikkoblog
   docker compose -f docker compose.prod.yml restart
   ```

## 总结

✅ **代码已修改** - 所有脚本已更新路径
🔄 **需要手动操作** - 修改 GitHub Secrets 中的 PROJECT_PATH
🚀 **推送部署** - 提交代码并触发自动部署
✨ **图片恢复** - 使用原有路径的 uploads 数据

---

**下一步：立即修改 GitHub Secrets！**

