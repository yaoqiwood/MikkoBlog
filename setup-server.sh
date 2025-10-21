#!/bin/bash

# MikkoBlog 服务器快速设置脚本
# 此脚本用于在服务器上快速配置 CI/CD 环境

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
REPO_URL="https://github.com/yaoqiwood/MikkoBlog.git"
BRANCH="cicd-deploy"

# 检查是否为 root 用户
check_user() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "检测到 root 用户，建议使用普通用户运行此脚本"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "已取消设置"
            exit 0
        fi
    fi
}

# 更新系统包
update_system() {
    log_info "更新系统包..."
    sudo apt update
    sudo apt upgrade -y
    log_success "系统包更新完成"
}

# 安装必要软件
install_requirements() {
    log_info "安装必要软件..."

    # 安装基础工具
    sudo apt install -y curl wget git nano htop

    # 安装 Docker
    if ! command -v docker &> /dev/null; then
        log_info "安装 Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        log_success "Docker 安装完成"
    else
        log_info "Docker 已安装"
    fi

    # 安装 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_info "安装 Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        log_success "Docker Compose 安装完成"
    else
        log_info "Docker Compose 已安装"
    fi

    log_success "必要软件安装完成"
}

# 创建项目目录
setup_project_directory() {
    log_info "设置项目目录..."

    if [ ! -d "$PROJECT_DIR" ]; then
        sudo mkdir -p "$PROJECT_DIR"
        sudo chown $USER:$USER "$PROJECT_DIR"
        log_success "项目目录创建完成: $PROJECT_DIR"
    else
        log_info "项目目录已存在: $PROJECT_DIR"
    fi
}

# 克隆项目代码
clone_project() {
    log_info "克隆项目代码..."

    if [ -d "$PROJECT_DIR/.git" ]; then
        log_info "项目代码已存在，更新到最新版本..."
        cd "$PROJECT_DIR"
        git fetch origin
        git reset --hard origin/$BRANCH
        git clean -fd
    else
        log_info "克隆项目代码..."
        git clone -b $BRANCH $REPO_URL "$PROJECT_DIR"
        cd "$PROJECT_DIR"
    fi

    log_success "项目代码准备完成"
}

# 生成 SSH 密钥
generate_ssh_key() {
    log_info "检查 SSH 密钥..."

    if [ ! -f ~/.ssh/id_rsa ]; then
        log_info "生成 SSH 密钥对..."
        ssh-keygen -t rsa -b 4096 -C "github-actions@$(hostname)" -f ~/.ssh/id_rsa -N ""
        log_success "SSH 密钥生成完成"
    else
        log_info "SSH 密钥已存在"
    fi

    # 添加公钥到 authorized_keys
    if ! grep -q "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        log_success "SSH 公钥已添加到 authorized_keys"
    else
        log_info "SSH 公钥已在 authorized_keys 中"
    fi
}

# 创建环境配置文件
create_env_config() {
    log_info "创建环境配置文件..."

    cd "$PROJECT_DIR"

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
# VITE_API_BASE_URL=https://yourdomain.com
EOF
        log_success "环境配置文件创建完成"
    else
        log_info "环境配置文件已存在"
    fi
}

# 设置文件权限
set_permissions() {
    log_info "设置文件权限..."

    cd "$PROJECT_DIR"

    # 设置脚本执行权限
    chmod +x github-deploy.sh
    chmod +x server-deploy.sh
    chmod +x deploy.sh

    # 创建必要的目录
    mkdir -p nginx/ssl
    mkdir -p backend/uploads/images
    mkdir -p backend/uploads/music
    mkdir -p backend/uploads/music/covers

    log_success "文件权限设置完成"
}

# 显示配置信息
show_config_info() {
    log_success "服务器设置完成！"
    echo ""
    echo "📋 配置信息："
    echo "  项目目录: $PROJECT_DIR"
    echo "  仓库地址: $REPO_URL"
    echo "  分支: $BRANCH"
    echo ""
    echo "🔑 SSH 私钥（需要添加到 GitHub Secrets）:"
    echo "---"
    cat ~/.ssh/id_rsa
    echo "---"
    echo ""
    echo "📝 需要在 GitHub 仓库中配置以下 Secrets："
    echo "  SERVER_HOST: $(hostname -I | awk '{print $1}')"
    echo "  SERVER_USER: $(whoami)"
    echo "  SERVER_PORT: 22"
    echo "  SERVER_SSH_KEY: [上面的私钥内容]"
    echo "  PROJECT_PATH: $PROJECT_DIR"
    echo ""
    echo "🚀 下一步："
    echo "  1. 将上面的私钥内容添加到 GitHub Secrets"
    echo "  2. 配置其他必要的 Secrets"
    echo "  3. 推送代码到 cicd-deploy 分支触发部署"
    echo ""
    echo "📖 详细配置说明请查看: CICD_SETUP.md"
}

# 主函数
main() {
    log_info "开始设置 MikkoBlog 服务器环境"

    check_user
    update_system
    install_requirements
    setup_project_directory
    clone_project
    generate_ssh_key
    create_env_config
    set_permissions
    show_config_info

    log_success "服务器设置完成！"
}

# 执行主函数
main "$@"
