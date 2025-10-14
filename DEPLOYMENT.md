# MikkoBlog 部署指南

## 🚀 快速部署

### 1. 服务器要求
- Ubuntu 20.04+ 或 CentOS 8+
- Docker 20.10+
- Docker Compose 2.0+
- 至少 2GB RAM
- 至少 10GB 磁盘空间

### 2. 一键部署
```bash
# 克隆项目到服务器
git clone <your-repo-url> /opt/mikkoblog
cd /opt/mikkoblog

# 运行部署脚本
./deploy.sh
```

### 3. 手动部署步骤

#### 3.1 安装Docker和Docker Compose
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 3.2 配置环境变量
```bash
# 创建生产环境配置
cp .env.production .env

# 编辑配置文件
nano .env
```

重要配置项：
- `JWT_SECRET`: 生成强密码
- `CORS_ALLOW_ORIGINS`: 设置您的域名
- `VITE_API_BASE_URL`: 设置API地址
- `ADMIN_EMAIL` 和 `ADMIN_PASSWORD`: 管理员账号

#### 3.3 启动服务
```bash
# 构建并启动所有服务
docker-compose -f docker-compose.prod.yml up -d

# 查看服务状态
docker-compose -f docker-compose.prod.yml ps

# 查看日志
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔧 配置说明

### 数据库配置
- 数据库名: `mikkoBlog`
- 用户名: `mikko`
- 密码: `mikko_pass`
- 端口: `3307` (外部访问)

### 服务端口
- 前端: `80` (HTTP)
- 后端API: `8000`
- 数据库: `3307`

### 目录结构
```
/opt/mikkoblog/
├── backend/
│   ├── uploads/          # 上传文件
│   └── config/           # 配置文件
├── nginx/
│   ├── nginx.conf        # Nginx配置
│   └── ssl/              # SSL证书 (可选)
└── docker-compose.prod.yml
```

## 🔒 SSL证书配置

### 使用Let's Encrypt (推荐)
```bash
# 安装Certbot
sudo apt install certbot

# 获取证书
sudo certbot certonly --standalone -d yourdomain.com

# 复制证书到项目目录
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/key.pem
sudo chown $USER:$USER nginx/ssl/*.pem

# 启用HTTPS配置
# 编辑 nginx/nginx.conf，取消注释HTTPS部分
```

### 自动续期
```bash
# 添加到crontab
echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f /opt/mikkoblog/docker-compose.prod.yml restart nginx" | sudo crontab -
```

## 📊 监控和维护

### 查看服务状态
```bash
# 查看所有容器状态
docker-compose -f docker-compose.prod.yml ps

# 查看资源使用情况
docker stats

# 查看特定服务日志
docker-compose -f docker-compose.prod.yml logs -f backend
```

### 备份数据
```bash
# 备份数据库
docker exec mikko_mysql mysqldump -umikko -pmikko_pass mikkoBlog > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份上传文件
tar -czf uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz backend/uploads/
```

### 更新应用
```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## 🛠️ 故障排除

### 常见问题

1. **数据库连接失败**
   ```bash
   # 检查数据库容器状态
   docker logs mikko_mysql

   # 检查网络连接
   docker network ls
   ```

2. **前端无法访问后端API**
   ```bash
   # 检查nginx配置
   docker exec mikko_nginx nginx -t

   # 重启nginx
   docker-compose -f docker-compose.prod.yml restart nginx
   ```

3. **文件上传失败**
   ```bash
   # 检查上传目录权限
   ls -la backend/uploads/

   # 修复权限
   chmod -R 755 backend/uploads/
   ```

### 日志查看
```bash
# 查看所有服务日志
docker-compose -f docker-compose.prod.yml logs

# 查看特定服务日志
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs frontend
docker-compose -f docker-compose.prod.yml logs nginx
```

## 🔄 服务管理

### 启动服务
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 停止服务
```bash
docker-compose -f docker-compose.prod.yml down
```

### 重启服务
```bash
docker-compose -f docker-compose.prod.yml restart
```

### 查看服务状态
```bash
docker-compose -f docker-compose.prod.yml ps
```

## 📝 默认账号信息

- **管理员邮箱**: admin@example.com
- **管理员密码**: admin123

**⚠️ 重要**: 部署后请立即修改默认管理员密码！

## 🌐 访问地址

部署完成后，您可以通过以下地址访问：

- **前端**: http://your-server-ip
- **后端API**: http://your-server-ip:8000
- **管理员面板**: http://your-server-ip/admin

## 📞 技术支持

如果遇到问题，请检查：
1. Docker和Docker Compose是否正确安装
2. 端口80和8000是否被占用
3. 防火墙是否允许相应端口访问
4. 查看服务日志排查具体错误
