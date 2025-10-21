# 🚨 紧急：需要立即清理服务器磁盘空间

## 当前状态

❌ **部署失败：磁盘空间不足**

```
E: You don't have enough free space in /var/cache/apt/archives/.
```

## 立即执行（在服务器上）

### 步骤 1：SSH 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 2：检查磁盘使用情况

```bash
# 查看磁盘使用率
df -h /

# 查看 Docker 空间占用
docker system df
```

### 步骤 3：快速清理（选择一种方式）

**方式 A：一键清理所有未使用资源（最快）**

```bash
# 警告：这会删除所有未使用的镜像、容器、卷、网络
docker system prune -a -f --volumes

# 清理系统缓存
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove -y

# 清理日志
sudo journalctl --vacuum-time=7d
```

**预计释放空间：5-15 GB**

**方式 B：使用清理脚本（推荐）**

```bash
# 进入项目目录
cd /var/www/mikkoblog  # 或 /opt/mikkoblog

# 拉取最新代码
git pull origin cicd-deploy

# 运行清理脚本
chmod +x cleanup-docker.sh
sudo ./cleanup-docker.sh
```

**方式 C：手动逐步清理（最安全）**

```bash
# 1. 清理停止的容器
docker container prune -f

# 2. 清理悬空镜像
docker image prune -f

# 3. 清理构建缓存（释放最多空间）
docker builder prune -a -f

# 4. 清理未使用的卷
docker volume prune -f

# 5. 清理系统缓存
sudo apt-get clean
sudo apt-get autoclean

# 6. 清理旧日志
sudo journalctl --vacuum-time=7d
```

### 步骤 4：验证清理结果

```bash
# 再次检查磁盘使用
df -h /

# 应该看到使用率降低了 10-20%
# 例如：从 95% 降到 75-80%
```

### 步骤 5：重新部署

清理完成后，有两种方式触发重新部署：

**方式 A：在服务器上手动部署**

```bash
cd /var/www/mikkoblog  # 或 /opt/mikkoblog

# 拉取最新代码
git pull origin cicd-deploy

# 运行部署脚本（现在包含自动清理功能）
./github-deploy.sh
```

**方式 B：触发 GitHub Actions 自动部署**

在本地：
```bash
git commit --allow-empty -m "trigger: 重新部署（磁盘已清理）"
git push origin cicd-deploy
```

或者手动触发：
1. 访问：https://github.com/yaoqiwood/MikkoBlog/actions
2. 点击 "Deploy to Server"
3. 点击 "Run workflow" → "Run workflow"

## 为什么会空间不足？

### 主要占用来源

```
Docker 累积的资源：
├─ 旧镜像（每次构建产生）    5-8 GB
├─ 构建缓存                   3-5 GB
├─ 悬空镜像                   2-4 GB
├─ 停止的容器                 1-2 GB
├─ 未使用的卷                 1-3 GB
└─ 系统缓存和日志             2-3 GB
────────────────────────────────────
总计：                        14-25 GB
```

### 问题原因

1. **每次部署都创建新镜像，但旧镜像不会自动删除**
2. **`--no-cache` 参数导致不复用缓存，累积大量中间层**
3. **前端构建产生大量临时文件**
4. **没有定期清理机制**

## 已实施的预防措施

✅ **自动清理**：修改了 `github-deploy.sh`，现在每次部署前会自动清理：
```bash
- 未使用的镜像
- 构建缓存
- 停止的容器
```

✅ **清理脚本**：添加了 `cleanup-docker.sh`，可以随时手动清理

✅ **文档**：`DISK_SPACE_FIX.md` 包含详细的预防和监控方案

## 长期解决方案

### 1. 定期自动清理

设置定时任务：

```bash
# 编辑 crontab
crontab -e

# 每周日凌晨 3 点自动清理
0 3 * * 0 docker system prune -a -f --volumes && docker builder prune -a -f
```

### 2. 监控磁盘使用

```bash
# 创建监控脚本
sudo tee /usr/local/bin/check-disk.sh > /dev/null << 'EOF'
#!/bin/bash
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 80 ]; then
    echo "⚠️  警告：磁盘使用率 ${USAGE}%"
    docker system df
fi
EOF

sudo chmod +x /usr/local/bin/check-disk.sh

# 每天早上 8 点检查
(crontab -l 2>/dev/null; echo "0 8 * * * /usr/local/bin/check-disk.sh") | crontab -
```

### 3. 考虑扩容

如果频繁遇到空间问题，考虑：
- 升级服务器磁盘容量
- 添加额外的存储卷
- 使用对象存储（如 S3）存储 uploads 文件

## 检查清单

在重新部署前，确认：

- [ ] SSH 连接到服务器
- [ ] 执行清理命令
- [ ] 磁盘使用率 < 80%
- [ ] Docker 系统有足够空间（至少 5GB 可用）
- [ ] 拉取了最新代码（包含自动清理功能）
- [ ] 准备好触发重新部署

## 常见问题

### Q: 清理会影响正在运行的服务吗？

**A:** 不会。清理只删除未使用的资源，正在运行的容器和镜像不会被删除。

### Q: 可以删除所有 Docker 数据重新开始吗？

**A:** 可以，但需要重新构建：

```bash
# 停止服务
cd /var/www/mikkoblog
docker compose -f docker-compose.prod.yml down

# 清理所有 Docker 数据
docker system prune -a -f --volumes

# 重新部署
./github-deploy.sh
```

### Q: 清理后空间仍然不足怎么办？

**A:**
1. 检查是否有其他大文件：`du -sh /* | sort -h`
2. 清理系统日志：`sudo journalctl --vacuum-size=100M`
3. 考虑升级服务器磁盘

## 总结

🚨 **立即行动**：SSH 到服务器，运行清理命令
✅ **预计效果**：释放 5-15 GB 空间
🔄 **自动化**：未来部署会自动清理，避免再次发生
📊 **监控**：建议设置定时清理和监控告警

---

**现在就去服务器执行清理！清理完成后重新部署即可！**
