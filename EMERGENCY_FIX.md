# 🚨 紧急修复指南 - 恢复丢失的图片

## 问题现状

- ✅ 部署脚本已修复（防止未来再次丢失）
- ❌ 已部署的服务器上的图片已被删除
- 🔄 需要从旧路径恢复数据

## 立即执行（在服务器上）

### 步骤 1：SSH 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 2：检查数据情况

```bash
# 检查新路径（当前运行的）
ls -lah /opt/mikkoblog/backend/uploads/images/

# 检查旧路径（是否有备份数据）
ls -lah /var/www/mikkoblog/backend/uploads/images/
```

### 步骤 3：恢复数据

**方法 A：使用自动恢复脚本（推荐）**

```bash
cd /opt/mikkoblog

# 拉取最新代码（包含恢复脚本）
git fetch origin
git checkout cicd-deploy
git pull origin cicd-deploy

# 运行恢复脚本
chmod +x restore-uploads.sh
sudo ./restore-uploads.sh
```

**方法 B：手动复制**

```bash
# 如果旧路径有数据
sudo rsync -av /var/www/mikkoblog/backend/uploads/ /opt/mikkoblog/backend/uploads/

# 设置权限
sudo chmod -R 755 /opt/mikkoblog/backend/uploads
sudo chown -R $(whoami):$(whoami) /opt/mikkoblog/backend/uploads
```

### 步骤 4：重启服务

```bash
cd /opt/mikkoblog

# 重启 Docker 容器
docker-compose -f docker-compose.prod.yml restart

# 或者完全重启
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### 步骤 5：验证修复

```bash
# 检查容器内文件
docker exec mikko_backend ls -lah /app/uploads/images/

# 测试图片访问
curl -I https://www.mikkocat.top/uploads/images/20251017_140746_99a8c1c3.jpg

# 应该返回 200 OK，而不是 404
```

## 如果旧路径没有数据

### 情况 1：有数据库备份

从数据库中查找图片路径，然后从备份恢复。

### 情况 2：有服务器快照

恢复到部署前的快照，先备份 uploads 目录。

### 情况 3：需要重新上传

遗憾的是，如果没有任何备份，用户需要重新上传图片。

**防止未来丢失：**
```bash
# 立即备份当前数据
sudo mkdir -p /backup/mikkoblog
sudo tar -czf /backup/mikkoblog/uploads-$(date +%Y%m%d).tar.gz -C /opt/mikkoblog/backend uploads

# 设置定期备份（每天凌晨 3 点）
(crontab -l 2>/dev/null; echo "0 3 * * * tar -czf /backup/mikkoblog/uploads-\$(date +\%Y\%m\%d).tar.gz -C /opt/mikkoblog/backend uploads && find /backup/mikkoblog -name 'uploads-*.tar.gz' -mtime +7 -delete") | crontab -
```

## 检查清单

- [ ] SSH 连接到服务器成功
- [ ] 检查 `/var/www/mikkoblog/backend/uploads/` 是否有数据
- [ ] 复制数据到 `/opt/mikkoblog/backend/uploads/`
- [ ] 设置正确的文件权限
- [ ] 重启 Docker 服务
- [ ] 验证图片可以访问（返回 200 OK）
- [ ] 浏览器刷新页面，图片正常显示
- [ ] 设置定期备份计划

## 未来部署

现在部署脚本已修复，未来推送到 `cicd-deploy` 分支时：

✅ **会保留** uploads 目录
✅ **不会删除** 用户上传的文件
✅ **只会更新** 代码和配置

## 获取帮助

如果遇到问题：

1. **检查日志**
   ```bash
   docker-compose -f docker-compose.prod.yml logs backend
   ```

2. **检查容器状态**
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```

3. **查看详细文档**
   - `UPLOADS_DATA_LOSS_FIX.md` - 完整的问题分析
   - `restore-uploads.sh` - 自动恢复脚本

## 时间线

| 时间 | 事件 |
|------|------|
| 之前 | 手动部署到 `/var/www/mikkoblog`，uploads 数据正常 |
| GitHub Actions 部署后 | 自动部署到 `/opt/mikkoblog`，但 `git clean -fd` 删除了 uploads |
| 现在 | 部署脚本已修复，需要手动恢复数据 |
| 未来 | 新的部署会保留 uploads 目录 ✅ |

---

**⚠️ 重要：立即执行恢复步骤，越早恢复，数据越安全！**

