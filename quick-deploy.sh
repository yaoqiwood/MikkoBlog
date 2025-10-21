#!/bin/bash

# MikkoBlog 快速部署脚本
# 专门解决构建问题的简化版本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 项目配置
PROJECT_DIR="/opt/mikkoblog"
REPO_URL="https://github.com/yaoqiwood/MikkoBlog.git"
BRANCH="main"

log_info "开始快速部署 MikkoBlog"

# 检查Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    log_error "Docker Compose 未安装"
    exit 1
fi

# 更新代码
if [ -d "$PROJECT_DIR" ]; then
    log_info "更新代码..."
    cd "$PROJECT_DIR"
    git fetch origin
    git reset --hard origin/$BRANCH
    git clean -fd
else
    log_info "克隆代码..."
    mkdir -p /opt
    git clone -b $BRANCH $REPO_URL $PROJECT_DIR
    cd "$PROJECT_DIR"
fi

# 创建目录
mkdir -p nginx/ssl
mkdir -p backend/uploads/{images,music,music/covers}

# 创建环境配置
if [ ! -f ".env.production" ]; then
    log_info "创建环境配置..."
    cat > .env.production << EOF
# 生产环境配置
DB_HOST=db
DB_PORT=3306
DB_NAME=mikkoBlog
DB_USER=mikko
DB_PASSWORD=mikko_pass
JWT_SECRET=$(openssl rand -base64 32)
JWT_ALGORITHM=HS256
JWT_EXPIRES_MINUTES=1440
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=admin123
SERVER_ENVIRONMENT=production
SERVER_PORT=8000
CORS_ALLOW_ORIGINS=http://localhost,http://localhost:80
UNSPLASH_ACCESS_KEY=demo_key
# VITE_API_BASE_URL 在生产环境中将自动使用当前域名
EOF
fi

# 停止现有服务
log_info "停止现有服务..."
docker compose -f docker-compose.prod.yml down || true

# 清理Docker缓存
log_info "清理Docker缓存..."
docker system prune -f

# 构建并启动服务
log_info "构建和启动服务..."
docker compose -f docker-compose.prod.yml build --no-cache
docker compose -f docker-compose.prod.yml up -d

# 等待服务启动
log_info "等待服务启动..."
sleep 30

# 显示状态
log_success "部署完成！"
echo ""
echo "服务状态："
docker compose -f docker-compose.prod.yml ps
echo ""
echo "访问地址："
echo "  前端: http://$(hostname -I | awk '{print $1}')"
echo "  后端: http://$(hostname -I | awk '{print $1}'):8000"
echo ""
echo "默认管理员账号："
echo "  邮箱: admin@example.com"
echo "  密码: admin123"
echo ""
echo "查看日志："
echo "  docker compose -f docker-compose.prod.yml logs -f"
