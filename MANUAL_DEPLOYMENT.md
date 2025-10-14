# 手动部署指南

## 🚀 快速开始

### 1. 服务器初始化

在服务器上运行以下命令：

```bash
# 下载并运行服务器设置脚本
curl -fsSL https://raw.githubusercontent.com/yaoqiwood/MikkoBlog/cicd-deploy/scripts/simple-server-setup.sh | bash
```

### 2. 配置环境变量

```bash
# 进入项目目录
cd /opt/mikko-blog

# 编辑环境变量文件
nano .env
```

**必需的配置项：**
```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=你的安全密码
MYSQL_DATABASE=mikko_blog
MYSQL_USER=mikko
MYSQL_PASSWORD=你的安全密码

# 应用配置
NODE_ENV=production
VITE_API_BASE_URL=https://your-domain.com/api
```

### 3. 部署应用

```bash
# 运行部署脚本
./scripts/manual-deploy.sh
```

## 🔧 手动部署步骤

如果自动脚本有问题，可以手动执行以下步骤：

### 1. 停止现有服务
```bash
cd /opt/mikko-blog
docker-compose -f docker-compose.prod.yml down
```

### 2. 构建镜像
```bash
docker-compose -f docker-compose.prod.yml build --no-cache
```

### 3. 启动服务
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 4. 检查状态
```bash
# 查看容器状态
docker-compose -f docker-compose.prod.yml ps

# 查看日志
docker logs mikko_frontend_prod --tail=20
docker logs mikko_backend_prod --tail=20
docker logs mikko_mysql_prod --tail=10
```

### 5. 测试服务
```bash
# 测试前端
curl -I http://localhost

# 测试后端
curl -I http://localhost:8000/api/healthz

# 测试API代理
curl -I http://localhost/api/healthz
```

## 🐛 故障排除

### 容器无法启动
```bash
# 查看详细日志
docker logs mikko_backend_prod
docker logs mikko_frontend_prod
docker logs mikko_mysql_prod

# 检查资源使用
docker stats
```

### 数据库连接问题
```bash
# 检查MySQL容器状态
docker exec mikko_mysql_prod mysql -u root -p -e "SHOW DATABASES;"

# 检查环境变量
docker exec mikko_backend_prod env | grep MYSQL
```

### 网络问题
```bash
# 检查Docker网络
docker network ls
docker network inspect mikko-blog_mikko-network

# 测试容器间通信
docker exec mikko_frontend_prod curl http://backend:8000/api/healthz
```

## 📱 访问地址

部署成功后，可以通过以下地址访问：

- **主页**: http://your-server-ip
- **管理页面**: http://your-server-ip/admin
- **后端API**: http://your-server-ip:8000

## 🔄 更新应用

```bash
cd /opt/mikko-blog
git pull origin cicd-deploy
./scripts/manual-deploy.sh
```

## 📞 获取帮助

如果遇到问题，请检查：
1. 容器日志
2. 环境变量配置
3. 网络连接
4. 资源使用情况
