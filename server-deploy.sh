#!/bin/bash

# MikkoBlog 服务器端部署脚本
# 在服务器上运行此脚本来部署应用

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
PROJECT_DIR="/opt/mikkoblog"
REPO_URL="https://github.com/yourusername/MikkoBlog.git"  # 请修改为您的仓库地址
BRANCH="main"

# 检查用户权限
check_user() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "检测到root用户，将使用root权限运行"
        log_warning "建议使用普通用户运行，如果必须使用root，请确保了解风险"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "已取消部署"
            exit 0
        fi
    else
        log_info "使用普通用户运行: $(whoami)"
    fi
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

    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi

    log_success "系统要求检查通过"
}

# 克隆或更新代码
update_code() {
    log_info "更新代码..."

    if [ -d "$PROJECT_DIR" ]; then
        log_info "项目目录已存在，拉取最新代码..."
        cd "$PROJECT_DIR"
        git fetch origin
        git reset --hard origin/$BRANCH
        git clean -fd
    else
        log_info "克隆项目代码..."
        if [ "$EUID" -eq 0 ]; then
            # root用户直接创建目录
            mkdir -p /opt
            git clone -b $BRANCH $REPO_URL $PROJECT_DIR
        else
            # 普通用户需要sudo权限
            sudo mkdir -p /opt
            sudo chown $USER:$USER /opt
            git clone -b $BRANCH $REPO_URL $PROJECT_DIR
        fi
        cd "$PROJECT_DIR"
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

# 创建环境配置文件
create_env_config() {
    log_info "创建环境配置文件..."

    if [ ! -f ".env.production" ]; then
        log_info "创建生产环境配置文件..."
        cat > .env.production << EOF
# 生产环境配置
# 请根据您的服务器实际情况修改以下配置

# 数据库配置
DB_HOST=db
DB_PORT=3306
DB_NAME=mikkoBlog
DB_USER=mikko
DB_PASSWORD=mikko_pass

# JWT配置 - 请修改为强密码
JWT_SECRET=$(openssl rand -base64 32)
JWT_ALGORITHM=HS256
JWT_EXPIRES_MINUTES=1440

# 管理员配置
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=admin123

# 服务器配置
SERVER_ENVIRONMENT=production
SERVER_PORT=8000

# CORS配置 - 请修改为您的域名
CORS_ALLOW_ORIGINS=http://localhost,http://localhost:80

# 图片搜索配置
UNSPLASH_ACCESS_KEY=demo_key

# 前端配置 - 生产环境将自动使用当前域名
# VITE_API_BASE_URL=https://mikkocat.top
EOF
        log_warning "已创建 .env.production 文件，请编辑其中的配置"
    else
        log_info ".env.production 文件已存在，跳过创建"
    fi
}

# 停止现有服务
stop_services() {
    log_info "停止现有服务..."

    if [ -f "docker-compose.prod.yml" ]; then
        docker-compose -f docker-compose.prod.yml down || true
    fi

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
    timeout 60 bash -c 'until curl -f http://localhost:8000/health 2>/dev/null; do sleep 2; done'

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
                docker exec -i mikko_mysql mysql -umikko -pmikko_pass mikkoBlog < "$sql_file" || true
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
    echo ""
    echo "更新应用命令："
    echo "  cd $PROJECT_DIR && ./server-deploy.sh"
}

# 主函数
main() {
    log_info "开始部署 MikkoBlog"

    check_user
    check_requirements
    update_code
    create_directories
    create_env_config
    stop_services
    start_services
    wait_for_services
    init_database
    show_deployment_info
}

# 执行主函数
main "$@"
