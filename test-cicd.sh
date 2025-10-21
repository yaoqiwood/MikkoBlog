#!/bin/bash

# CI/CD 配置测试脚本
# 此脚本用于测试 GitHub Actions CI/CD 配置是否正确

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

# 检查文件是否存在
check_files() {
    log_info "检查必要文件..."

    local files=(
        ".github/workflows/deploy.yml"
        "github-deploy.sh"
        "docker-compose.prod.yml"
        "CICD_SETUP.md"
        "setup-server.sh"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            log_success "✓ $file 存在"
        else
            log_error "✗ $file 不存在"
            return 1
        fi
    done
}

# 检查 GitHub Actions 工作流语法
check_workflow_syntax() {
    log_info "检查 GitHub Actions 工作流语法..."

    if command -v yamllint &> /dev/null; then
        yamllint .github/workflows/deploy.yml
        log_success "✓ 工作流语法检查通过"
    else
        log_warning "yamllint 未安装，跳过语法检查"
    fi
}

# 检查 Docker Compose 配置
check_docker_compose() {
    log_info "检查 Docker Compose 配置..."

    if command -v docker-compose &> /dev/null; then
        docker-compose -f docker-compose.prod.yml config > /dev/null
        log_success "✓ Docker Compose 配置有效"
    else
        log_warning "Docker Compose 未安装，跳过配置检查"
    fi
}

# 检查脚本权限
check_script_permissions() {
    log_info "检查脚本权限..."

    local scripts=(
        "github-deploy.sh"
        "setup-server.sh"
        "test-cicd.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            log_success "✓ $script 有执行权限"
        else
            log_warning "✗ $script 没有执行权限"
            chmod +x "$script"
            log_info "已为 $script 添加执行权限"
        fi
    done
}

# 检查环境配置模板
check_env_template() {
    log_info "检查环境配置模板..."

    if [ -f "config-templates/env.production.template" ]; then
        log_success "✓ 环境配置模板存在"
    else
        log_warning "✗ 环境配置模板不存在"
    fi
}

# 显示配置摘要
show_config_summary() {
    log_info "配置摘要："
    echo ""
    echo "📁 项目结构："
    echo "  .github/workflows/deploy.yml  - GitHub Actions 工作流"
    echo "  github-deploy.sh              - 服务器部署脚本"
    echo "  setup-server.sh               - 服务器快速设置脚本"
    echo "  docker-compose.prod.yml       - 生产环境 Docker 配置"
    echo "  CICD_SETUP.md                 - 详细配置说明"
    echo ""
    echo "🔧 工作流触发条件："
    echo "  - 推送到 cicd-deploy 分支"
    echo "  - 手动触发"
    echo ""
    echo "📋 需要配置的 GitHub Secrets："
    echo "  SERVER_HOST     - 服务器 IP 或域名"
    echo "  SERVER_USER     - SSH 用户名"
    echo "  SERVER_PORT     - SSH 端口 (默认: 22)"
    echo "  SERVER_SSH_KEY  - SSH 私钥"
    echo "  PROJECT_PATH    - 项目路径 (默认: /opt/mikkoblog)"
    echo ""
    echo "🚀 下一步："
    echo "  1. 在服务器上运行: ./setup-server.sh"
    echo "  2. 配置 GitHub Secrets"
    echo "  3. 推送代码到 cicd-deploy 分支"
    echo "  4. 查看 GitHub Actions 执行结果"
}

# 主函数
main() {
    log_info "开始测试 CI/CD 配置..."

    check_files
    check_workflow_syntax
    check_docker_compose
    check_script_permissions
    check_env_template

    log_success "CI/CD 配置测试完成！"
    echo ""
    show_config_summary
}

# 执行主函数
main "$@"
