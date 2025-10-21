#!/bin/bash

# MikkoBlog 部署脚本
# 使用方法: ./deploy.sh [环境]
# 环境选项: dev, prod (默认: prod)

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

# 检查Docker和Docker Compose
check_requirements() {
    log_info "检查系统要求..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi

    log_success "系统要求检查通过"
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

# 生成JWT密钥
generate_jwt_secret() {
    log_info "生成JWT密钥..."

    JWT_SECRET=$(openssl rand -base64 32)
    echo "JWT_SECRET=$JWT_SECRET" > .env.production

    log_success "JWT密钥已生成并保存到 .env.production"
}

# 停止现有服务
stop_services() {
    log_info "停止现有服务..."

    docker-compose -f docker-compose.prod.yml down || true

    log_success "服务已停止"
}

# 构建和启动服务
start_services() {
    log_info "构建和启动服务..."

    # 构建镜像
    docker-compose -f docker-compose.prod.yml build --no-cache

    # 启动服务
    docker-compose -f docker-compose.prod.yml up -d

    log_success "服务启动完成"
}

# 等待服务就绪
wait_for_services() {
    log_info "等待服务就绪..."

    # 等待数据库
    log_info "等待数据库启动..."
    timeout 60 bash -c 'until docker exec mikko_mysql mysqladmin ping -h"localhost" --silent; do sleep 2; done'

    # 等待后端
    log_info "等待后端服务启动..."
    timeout 60 bash -c 'until curl -f http://localhost:8000/api/healthz 2>/dev/null; do sleep 2; done'

    log_success "所有服务已就绪"
}

# 初始化数据库
init_database() {
    log_info "初始化数据库..."

    # 等待数据库完全启动
    sleep 10

    # 运行数据库初始化脚本
    if [ -d "backend/sql" ]; then
        log_info "执行数据库初始化脚本..."
        for sql_file in backend/sql/*.sql; do
            if [ -f "$sql_file" ]; then
                log_info "执行: $(basename "$sql_file")"
                docker exec -i mikko_mysql mysql -umikko -pmikko_pass mikkoBlog < "$sql_file"
            fi
        done
    fi

    log_success "数据库初始化完成"
}

# 显示部署信息
show_deployment_info() {
    log_success "部署完成！"
    echo ""
    echo "服务访问地址："
    echo "  前端: http://$(hostname -I | awk '{print $1}')"
    echo "  后端API: http://$(hostname -I | awk '{print $1}'):8000"
    echo ""
    echo "默认管理员账号："
    echo "  邮箱: admin@example.com"
    echo "  密码: admin123"
    echo ""
    echo "Docker 服务状态："
    docker-compose -f docker-compose.prod.yml ps
    echo ""
    echo "查看日志命令："
    echo "  docker-compose -f docker-compose.prod.yml logs -f"
    echo ""
    echo "停止服务命令："
    echo "  docker-compose -f docker-compose.prod.yml down"
}

# 主函数
main() {
    ENV=${1:-prod}

    log_info "开始部署 MikkoBlog (环境: $ENV)"

    check_requirements
    create_directories

    if [ ! -f ".env.production" ]; then
        generate_jwt_secret
        log_warning "请编辑 .env.production 文件，配置您的域名和其他设置"
    fi

    stop_services
    start_services
    wait_for_services
    init_database
    show_deployment_info
}

# 执行主函数
main "$@"
