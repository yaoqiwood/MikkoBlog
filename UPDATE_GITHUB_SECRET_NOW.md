# ⚠️ 紧急：立即修改 GitHub Secret

## 问题说明

虽然脚本代码已经修改为 `/var/www/mikkoblog`，但 GitHub Actions 实际使用的路径由 **GitHub Secrets** 控制：

```yaml
# .github/workflows/deploy.yml 第 40 行
cd ${{ secrets.PROJECT_PATH }}  # ← 这里决定了实际部署路径！
```

**当前状态：**
- ❌ GitHub Secret `PROJECT_PATH` = `/opt/mikkoblog` (旧值，仍在使用)
- ✅ 脚本中的 `PROJECT_DIR` = `/var/www/mikkoblog` (已修改，但未生效)

**结果：** 部署仍然在 `/opt/mikkoblog` 执行！

## 🎯 立即执行以下步骤

### 步骤 1：访问 GitHub Secrets 设置页面

**直接链接：**
👉 https://github.com/yaoqiwood/MikkoBlog/settings/secrets/actions

或者手动导航：
1. 访问你的 GitHub 仓库：https://github.com/yaoqiwood/MikkoBlog
2. 点击顶部的 **Settings** 标签
3. 左侧菜单找到 **Secrets and variables**
4. 点击 **Actions**

### 步骤 2：找到 PROJECT_PATH Secret

在 "Repository secrets" 列表中，你会看到类似这样的 Secrets：

```
Name                    Updated
────────────────────────────────────
SERVER_HOST             1 day ago
SERVER_USER             1 day ago  
SERVER_PORT             1 day ago
SERVER_SSH_KEY          1 day ago
PROJECT_PATH            1 day ago  ← 找到这个！
```

### 步骤 3：更新 PROJECT_PATH

1. 点击 `PROJECT_PATH` 右侧的 **✏️ 铅笔图标** 或 **Update** 按钮
2. 在 **Value** 输入框中，将现有值改为：
   ```
   /var/www/mikkoblog
   ```
3. 点击 **Update secret** 按钮保存

### 步骤 4：验证修改

修改后，你应该看到 `PROJECT_PATH` 的 "Updated" 时间变为 "just now" 或 "a few seconds ago"。

## 🚀 触发新的部署

修改 Secret 后，触发一次部署来应用新配置：

### 方法 1：手动触发 Workflow

1. 访问：https://github.com/yaoqiwood/MikkoBlog/actions
2. 点击左侧的 **Deploy to Server** workflow
3. 点击右上角的 **Run workflow** 按钮
4. 确认分支是 `cicd-deploy`
5. 点击绿色的 **Run workflow** 按钮

### 方法 2：推送一个小改动

```bash
cd /Users/jianshujie/MikkoBlog

# 创建一个空提交来触发部署
git commit --allow-empty -m "trigger: 测试新的部署路径 /var/www/mikkoblog"
git push origin cicd-deploy
```

## 🔍 验证部署路径

部署完成后，检查日志确认路径：

1. 访问：https://github.com/yaoqiwood/MikkoBlog/actions
2. 点击最新的 workflow run
3. 展开 "Deploy to server" 步骤
4. 查找这一行：
   ```
   [INFO] 项目目录已存在，拉取最新代码...
   ```
5. 确认显示的路径是 `/var/www/mikkoblog`

## 📊 当前配置检查清单

| 配置项 | 当前值 | 期望值 | 状态 |
|--------|--------|--------|------|
| GitHub Secret: PROJECT_PATH | `/opt/mikkoblog` ❌ | `/var/www/mikkoblog` | **需要修改** |
| github-deploy.sh: PROJECT_DIR | `/var/www/mikkoblog` ✅ | `/var/www/mikkoblog` | 已修改 |
| workflow: cd ${{ secrets.PROJECT_PATH }} | 使用 Secret 值 | 使用 Secret 值 | 等待 Secret 更新 |

## 🐛 为什么脚本修改没有生效？

让我们看看 workflow 的执行流程：

```yaml
# GitHub Actions 执行顺序：
1. SSH 连接到服务器 ✅
2. cd ${{ secrets.PROJECT_PATH }}  ← 使用 Secret (目前是 /opt/mikkoblog)
3. chmod +x github-deploy.sh  ← 在 /opt/mikkoblog 里执行
4. ./github-deploy.sh  ← 在 /opt/mikkoblog 里执行
```

即使 `github-deploy.sh` 内部有 `PROJECT_DIR="/var/www/mikkoblog"`，但脚本已经在 `/opt/mikkoblog` 目录中运行了，所以：
- `git pull` 更新的是 `/opt/mikkoblog` 的代码
- `docker compose up` 启动的容器挂载的是 `/opt/mikkoblog/backend/uploads`

## 💡 关键理解

**GitHub Actions Workflow 的优先级：**

```
Secrets (最高优先级) > 脚本内部变量 (较低优先级)
     ↓
${{ secrets.PROJECT_PATH }}
     ↓
决定在哪个目录执行 github-deploy.sh
     ↓
所有操作都在这个目录进行
```

## ⚡ 快速命令参考

### 在服务器上验证当前部署路径

```bash
# SSH 到服务器
ssh your-username@your-server-ip

# 检查哪个路径有新代码
cd /opt/mikkoblog && git log -1 --oneline
cd /var/www/mikkoblog && git log -1 --oneline

# 检查 Docker 容器正在使用的路径
docker inspect mikko_backend | grep -A 5 "Mounts"
# 你会看到类似：
# "Source": "/opt/mikkoblog/backend/uploads"  ← 当前使用的路径
```

### 验证 uploads 数据位置

```bash
# 检查哪个路径有 uploads 数据
ls -lh /opt/mikkoblog/backend/uploads/images/ | wc -l
ls -lh /var/www/mikkoblog/backend/uploads/images/ | wc -l

# 哪个数字大，说明哪个路径有更多图片
```

## 📝 修改 Secret 后的预期结果

修改 Secret 并重新部署后：

```
✅ GitHub Actions 会 cd 到 /var/www/mikkoblog
✅ 代码更新会应用到 /var/www/mikkoblog
✅ Docker 容器会挂载 /var/www/mikkoblog/backend/uploads
✅ 图片可以正常访问 (因为 uploads 数据在 /var/www/mikkoblog)
```

## 🎯 总结

**立即要做的事情（按顺序）：**

1. ✅ 访问 GitHub Secrets 页面
2. ✅ 修改 `PROJECT_PATH` 为 `/var/www/mikkoblog`
3. ✅ 保存修改
4. ✅ 触发新的部署（手动或推送代码）
5. ✅ 查看部署日志确认路径正确
6. ✅ 测试图片是否可以访问

---

**现在就去修改 GitHub Secret！这是解决问题的关键！** 🔑

