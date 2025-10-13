# 🚀 MikkoBlog 部署指南

## 📋 部署前准备

### 1. 服务器要求
- Ubuntu 20.04+ 或 CentOS 8+
- 至少 2GB RAM
- 至少 20GB 磁盘空间
- 开放端口：80, 443, 8000, 3306

### 2. 域名和SSL证书（可选）
- 准备域名
- 配置DNS解析到服务器IP
- 准备SSL证书（推荐使用Let's Encrypt）

## 🔧 服务器初始化

### 1. 连接服务器
```bash
ssh root@your-server-ip
```

### 2. 运行初始化脚本
```bash
# 下载并运行初始化脚本
curl -fsSL https://raw.githubusercontent.com/yaoqiwood/MikkoBlog/cicd-deploy/scripts/server-setup.sh | bash

# 或者手动执行
wget https://raw.githubusercontent.com/yaoqiwood/MikkoBlog/cicd-deploy/scripts/server-setup.sh
chmod +x server-setup.sh
./server-setup.sh
```

### 3. 配置环境变量
```bash
cd /opt/mikko-blog
nano .env
```

编辑以下内容：
```env
# 数据库配置
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=mikko_blog
MYSQL_USER=mikko
MYSQL_PASSWORD=your_secure_password

# 应用配置
NODE_ENV=production
VITE_API_BASE_URL=https://your-domain.com/api
```

## 🔑 GitHub Secrets 配置

在GitHub仓库中设置以下Secrets：

1. 进入仓库 → Settings → Secrets and variables → Actions
2. 添加以下Secrets：

| Secret名称 | 说明 | 示例值 |
|-----------|------|--------|
| `SERVER_HOST` | 服务器IP地址 | `123.456.789.0` |
| `SERVER_USER` | SSH用户名 | `root` 或 `ubuntu` |
| `SERVER_SSH_KEY` | SSH私钥内容 | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `SERVER_PORT` | SSH端口 | `22` |

### 生成SSH密钥对（如果还没有）
```bash
# 在本地生成密钥对
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/id_rsa.pub root@your-server-ip

# 将私钥内容复制到GitHub Secrets
cat ~/.ssh/id_rsa
```

## 🚀 部署流程

### 自动部署（推荐）
1. 推送代码到 `cicd-deploy` 分支
2. GitHub Actions 会自动触发部署
3. 查看部署状态：仓库 → Actions

### 手动部署
```bash
# 在服务器上执行
cd /opt/mikko-blog
./scripts/deploy.sh
```

## 🔍 部署后检查

### 1. 检查服务状态
```bash
docker-compose -f docker-compose.prod.yml ps
```

### 2. 检查日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose.prod.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f frontend
```

### 3. 健康检查
```bash
# 检查后端API
curl http://your-server-ip:8000/health

# 检查前端
curl http://your-server-ip
```

## 🌐 访问应用

- **前端**: http://your-server-ip 或 https://your-domain.com
- **后端API**: http://your-server-ip:8000
- **API文档**: http://your-server-ip:8000/docs
- **管理后台**: http://your-server-ip/admin

## 🔧 常用运维命令

### 重启服务
```bash
docker-compose -f docker-compose.prod.yml restart
```

### 更新应用
```bash
cd /opt/mikko-blog
git pull origin cicd-deploy
./scripts/deploy.sh
```

### 备份数据库
```bash
docker-compose -f docker-compose.prod.yml exec db mysqldump -u root -p mikko_blog > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 恢复数据库
```bash
docker-compose -f docker-compose.prod.yml exec -T db mysql -u root -p mikko_blog < backup_file.sql
```

### 清理Docker资源
```bash
# 清理未使用的镜像
docker image prune -f

# 清理未使用的容器
docker container prune -f

# 清理未使用的卷
docker volume prune -f
```

## 🚨 故障排除

### 1. 服务无法启动
```bash
# 查看详细错误信息
docker-compose -f docker-compose.prod.yml logs

# 检查端口占用
netstat -tulpn | grep :80
netstat -tulpn | grep :8000
```

### 2. 数据库连接失败
```bash
# 检查数据库状态
docker-compose -f docker-compose.prod.yml exec db mysql -u root -p -e "SHOW DATABASES;"

# 检查网络连接
docker-compose -f docker-compose.prod.yml exec backend ping db
```

### 3. 前端无法访问后端
```bash
# 检查nginx配置
docker-compose -f docker-compose.prod.yml exec frontend cat /etc/nginx/conf.d/default.conf

# 测试API连接
curl http://backend:8000/api/health
```

## 📞 技术支持

如果遇到问题，请：
1. 查看GitHub Issues
2. 检查服务器日志
3. 确认环境变量配置
4. 验证网络连接

---

🎉 **部署完成后，你的MikkoBlog就可以在互联网上访问了！**
