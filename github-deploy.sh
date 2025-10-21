#!/bin/bash

# GitHub Actions 部署脚本
# 此脚本在服务器上运行，用于接收 GitHub Actions 的部署请求

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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
PROJECT_DIR="/var/www/mikkoblog"
REPO_URL="https://github.com/yaoqiwood/MikkoBlog.git"
BRANCH="cicd-deploy"

# 检查Docker和Docker Compose
check_requirements() {
    log_info "检查系统要求..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装"
        exit 1
    fi

    if ! command -v docker compose &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        log_error "Git 未安装"
        exit 1
    fi

    log_success "系统要求检查通过"
}

# 更新代码
update_code() {
    log_info "更新代码..."

    if [ -d "$PROJECT_DIR" ]; then
        log_info "项目目录已存在，拉取最新代码..."
        cd "$PROJECT_DIR"
        git fetch origin
        git reset --hard origin/$BRANCH
        # 清理未跟踪的文件，但保留 uploads 目录（用户上传的数据）
        git clean -fd -e backend/uploads -e uploads
    else
        log_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi

    log_success "代码更新完成"
}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."

    mkdir -p nginx/ssl
    mkdir -p backend/uploads/images
    mkdir -p backend/uploads/music
    mkdir -p backend/uploads/music/covers

    log_success "目录创建完成"
}

# 停止现有服务
stop_services() {
    log_info "停止现有服务..."

    if [ -f "docker compose.prod.yml" ]; then
        docker compose -f docker compose.prod.yml down || true
    fi

    log_success "服务已停止"
}

# 构建和启动服务
start_services() {
    log_info "构建和启动服务..."

    # 构建镜像
    docker compose -f docker compose.prod.yml build --no-cache

    # 启动服务
    docker compose -f docker compose.prod.yml up -d

    log_success "服务启动完成"
}

# 等待服务就绪
wait_for_services() {
    log_info "等待服务就绪..."

    # 等待数据库
    log_info "等待数据库启动..."
    timeout 60 bash -c 'until docker exec mikko_mysql mysqladmin ping -h"localhost" --silent; do sleep 2; done' || {
        log_warning "数据库启动检查超时，继续执行..."
    }

    # 等待后端
    log_info "等待后端服务启动..."
    timeout 60 bash -c 'until curl -f http://localhost:8000/api/healthz 2>/dev/null; do sleep 2; done' || {
        log_warning "后端服务健康检查超时，但服务可能已启动"
    }

    log_success "服务就绪检查完成"
}

# 健康检查
health_check() {
    log_info "执行健康检查..."

    # 检查Docker容器状态
    log_info "Docker 容器状态："
    docker compose -f docker compose.prod.yml ps

    # 检查后端API
    if curl -f http://localhost:8000/api/healthz 2>/dev/null; then
        log_success "后端API健康检查通过"
    else
        log_warning "后端API健康检查失败"
    fi

    # 检查前端
    if curl -f http://localhost 2>/dev/null; then
        log_success "前端服务健康检查通过"
    else
        log_warning "前端服务健康检查失败"
    fi
}

# 显示部署信息
show_deployment_info() {
    log_success "部署完成！"
    echo ""
    echo "服务访问地址："
    echo "  前端: http://$(hostname -I | awk '{print $1}')"
    echo "  后端API: http://$(hostname -I | awk '{print $1}'):8000"
    echo ""
    echo "Docker 服务状态："
    docker compose -f docker compose.prod.yml ps
    echo ""
    echo "查看日志命令："
    echo "  cd $PROJECT_DIR && docker compose -f docker compose.prod.yml logs -f"
}

# 主函数
main() {
    log_info "开始 GitHub Actions 部署"

    check_requirements
    update_code
    create_directories
    stop_services
    start_services
    wait_for_services
    health_check
    show_deployment_info

    log_success "GitHub Actions 部署完成！"
}

# 执行主函数
main "$@"
