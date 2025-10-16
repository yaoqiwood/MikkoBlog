# 开发环境配置指南

## 环境配置

### 开发环境
- 前端：`http://localhost:5173`
- 后端：`http://localhost:8000`
- 数据库：`localhost:3307`

### 生产环境
- 前端：`https://mikkocat.top`
- 后端：`https://mikkocat.top/api`
- 数据库：Docker内部 `db:3306`

## 本地开发设置

### 1. 前端开发
```bash
cd frontend
npm install
npm run dev
```

### 2. 后端开发
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. 数据库
```bash
# 使用Docker启动数据库
docker-compose -f docker-compose.prod.yml up -d db
```

## 环境变量

### 开发环境
创建 `frontend/.env.local` 文件：
```
VITE_API_BASE_URL=http://localhost:8000
```

### 生产环境
Docker构建时会自动设置：
```
VITE_API_BASE_URL=https://mikkocat.top
```

## 配置说明

### API配置
- 开发环境：自动使用 `http://localhost:8000`
- 生产环境：自动使用 `https://mikkocat.top`
- 通过 `urlUtils.js` 统一管理

### CORS配置
后端已配置支持所有必要的域名：
- 开发环境：`localhost` 相关域名
- 生产环境：`mikkocat.top` 相关域名

## 部署

### 开发环境测试
```bash
# 启动所有服务
docker-compose -f docker-compose.prod.yml up -d

# 查看日志
docker-compose -f docker-compose.prod.yml logs -f
```

### 生产环境部署
```bash
# 拉取最新代码
git pull origin main

# 重新构建
docker-compose -f docker-compose.prod.yml build --no-cache

# 启动服务
docker-compose -f docker-compose.prod.yml up -d
```

## 故障排除

### 常见问题
1. **HTTPS混合内容错误**：确保API使用HTTPS协议
2. **CORS错误**：检查后端CORS配置
3. **404错误**：检查API路由和数据库数据

### 调试命令
```bash
# 检查服务状态
docker-compose -f docker-compose.prod.yml ps

# 查看日志
docker-compose -f docker-compose.prod.yml logs [service_name]

# 进入容器调试
docker exec -it [container_name] /bin/sh
```
