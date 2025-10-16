#!/bin/bash

# 开发环境启动脚本

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

log_info "启动MikkoBlog开发环境"

# 检查Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose 未安装"
    exit 1
fi

# 启动数据库
log_info "启动数据库..."
docker-compose -f docker-compose.prod.yml up -d db

# 等待数据库启动
log_info "等待数据库启动..."
sleep 10

# 检查数据库状态
if docker-compose -f docker-compose.prod.yml ps db | grep -q "Up"; then
    log_success "数据库启动成功"
else
    log_error "数据库启动失败"
    exit 1
fi

log_info "开发环境准备完成！"
log_info "数据库: localhost:3307"
log_info "现在可以启动前端和后端服务："
log_info "前端: cd frontend && npm run dev"
log_info "后端: cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
