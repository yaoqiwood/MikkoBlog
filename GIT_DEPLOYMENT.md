# Git 部署指南

## 🔐 安全部署方案

为了保护敏感信息不被上传到GitHub，我们采用以下策略：

### 1. 敏感文件处理

**不会上传到GitHub的文件**：
- `.env.production` - 生产环境配置
- `backend/uploads/` - 用户上传的文件
- `nginx/ssl/` - SSL证书
- `*.log` - 日志文件

**会上传到GitHub的文件**：
- 所有源代码
- Docker配置文件
- 部署脚本
- 配置模板

### 2. 部署流程

#### 步骤1：准备GitHub仓库

```bash
# 1. 在GitHub上创建新仓库
# 2. 添加远程仓库
git remote add origin https://github.com/yourusername/MikkoBlog.git

# 3. 提交所有文件（除了.gitignore中的文件）
git add .
git commit -m "Initial commit: MikkoBlog deployment ready"
git push -u origin main
```

#### 步骤2：在服务器上部署

```bash
# 1. 登录服务器
ssh user@your-server

# 2. 克隆项目
git clone https://github.com/yourusername/MikkoBlog.git /opt/mikkoblog
cd /opt/mikkoblog

# 3. 运行部署脚本
# 如果是普通用户：
./server-deploy.sh

# 如果是root用户：
./server-deploy-root.sh
```

#### 步骤3：配置生产环境

```bash
# 编辑生产环境配置
nano .env.production

# 重要配置项：
# - JWT_SECRET: 生成强密码
# - CORS_ALLOW_ORIGINS: 设置您的域名
# - VITE_API_BASE_URL: 设置API地址
# - ADMIN_EMAIL 和 ADMIN_PASSWORD: 管理员账号
```

### 3. 更新应用

当您修改代码后：

```bash
# 本地提交代码
git add .
git commit -m "Update: 描述您的修改"
git push origin main

# 在服务器上更新
ssh user@your-server
cd /opt/mikkoblog
./server-deploy.sh
```

### 4. 服务器端脚本说明

`server-deploy.sh` 脚本会自动：

1. **检查系统要求** - Docker, Docker Compose, Git
2. **更新代码** - 从GitHub拉取最新代码
3. **创建目录** - 创建必要的目录结构
4. **生成配置** - 自动生成.env.production文件
5. **部署服务** - 构建并启动Docker容器
6. **初始化数据库** - 运行SQL初始化脚本
7. **显示信息** - 显示访问地址和管理员账号

### 5. 安全注意事项

#### 5.1 环境变量安全
- `.env.production` 文件包含敏感信息，不会上传到GitHub
- 服务器上会自动生成JWT密钥
- 请修改默认的管理员密码

#### 5.2 文件权限
```bash
# 设置正确的文件权限
chmod 600 .env.production
chmod 755 server-deploy.sh
```

#### 5.3 防火墙配置
```bash
# 开放必要端口
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
```

### 6. 故障排除

#### 6.1 Git相关问题
```bash
# 如果Git克隆失败，检查网络连接
ping github.com

# 如果权限问题，使用HTTPS而不是SSH
git clone https://github.com/yourusername/MikkoBlog.git
```

#### 6.2 部署脚本问题
```bash
# 检查脚本权限
ls -la server-deploy.sh

# 手动运行脚本
bash server-deploy.sh
```

#### 6.3 Docker相关问题
```bash
# 检查Docker服务状态
sudo systemctl status docker

# 查看容器日志
docker-compose -f docker-compose.prod.yml logs
```

### 7. 备份策略

#### 7.1 代码备份
代码已经通过Git管理，无需额外备份。

#### 7.2 数据备份
```bash
# 备份数据库
docker exec mikko_mysql mysqldump -umikko -pmikko_pass mikkoBlog > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份上传文件
tar -czf uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz backend/uploads/
```

### 8. 监控和维护

#### 8.1 查看服务状态
```bash
cd /opt/mikkoblog
docker-compose -f docker-compose.prod.yml ps
```

#### 8.2 查看日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose.prod.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.prod.yml logs -f backend
```

#### 8.3 重启服务
```bash
docker-compose -f docker-compose.prod.yml restart
```

### 9. 自动化部署（可选）

可以设置GitHub Actions或Webhook来实现自动部署：

```yaml
# .github/workflows/deploy.yml
name: Deploy to Server
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /opt/mikkoblog
          ./server-deploy.sh
```

### 10. 总结

这个Git部署方案的优势：

✅ **安全性** - 敏感文件不会上传到GitHub
✅ **便捷性** - 一键部署脚本
✅ **可维护性** - 代码版本控制
✅ **可扩展性** - 支持自动化部署
✅ **备份友好** - 代码和数据分离管理

现在您可以安全地将代码推送到GitHub，然后在服务器上轻松部署了！
