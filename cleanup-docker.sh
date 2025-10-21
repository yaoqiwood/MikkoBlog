#!/bin/bash

# Docker 和系统空间清理脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 显示当前磁盘使用情况
show_disk_usage() {
    log_info "当前磁盘使用情况："
    df -h / | tail -n 1
    echo ""
}

# 显示 Docker 磁盘使用情况
show_docker_usage() {
    log_info "Docker 磁盘使用情况："
    docker system df
    echo ""
}

# 清理停止的容器
cleanup_containers() {
    log_info "清理停止的容器..."
    
    STOPPED_CONTAINERS=$(docker ps -a -q -f status=exited)
    if [ -n "$STOPPED_CONTAINERS" ]; then
        docker rm $STOPPED_CONTAINERS
        log_success "已清理停止的容器"
    else
        log_info "没有停止的容器需要清理"
    fi
}

# 清理悬空镜像
cleanup_dangling_images() {
    log_info "清理悬空镜像（dangling images）..."
    
    DANGLING_IMAGES=$(docker images -f "dangling=true" -q)
    if [ -n "$DANGLING_IMAGES" ]; then
        docker rmi $DANGLING_IMAGES
        log_success "已清理悬空镜像"
    else
        log_info "没有悬空镜像需要清理"
    fi
}

# 清理未使用的镜像
cleanup_unused_images() {
    log_info "清理未使用的镜像..."
    
    docker image prune -a -f
    log_success "已清理未使用的镜像"
}

# 清理构建缓存
cleanup_build_cache() {
    log_info "清理 Docker 构建缓存..."
    
    docker builder prune -a -f
    log_success "已清理构建缓存"
}

# 清理未使用的卷
cleanup_volumes() {
    log_info "清理未使用的卷..."
    
    docker volume prune -f
    log_success "已清理未使用的卷"
}

# 清理未使用的网络
cleanup_networks() {
    log_info "清理未使用的网络..."
    
    docker network prune -f
    log_success "已清理未使用的网络"
}

# 清理系统缓存
cleanup_system_cache() {
    log_info "清理系统 APT 缓存..."
    
    sudo apt-get clean
    sudo apt-get autoclean
    sudo apt-get autoremove -y
    
    log_success "已清理系统缓存"
}

# 清理日志文件
cleanup_logs() {
    log_info "清理旧的日志文件..."
    
    # 清理系统日志（保留最近 7 天）
    sudo journalctl --vacuum-time=7d
    
    # 清理 Docker 日志
    if [ -d "/var/lib/docker/containers" ]; then
        sudo find /var/lib/docker/containers -name "*.log" -type f -exec truncate -s 0 {} \;
        log_success "已清理 Docker 容器日志"
    fi
    
    log_success "已清理日志文件"
}

# 显示清理后的结果
show_cleanup_result() {
    echo ""
    log_success "========================================="
    log_success "清理完成！"
    log_success "========================================="
    echo ""
    
    log_info "清理后的磁盘使用情况："
    df -h / | tail -n 1
    echo ""
    
    log_info "清理后的 Docker 磁盘使用情况："
    docker system df
}

# 主函数
main() {
    echo ""
    log_info "========================================"
    log_info "Docker 和系统空间清理工具"
    log_info "========================================"
    echo ""
    
    # 显示清理前状态
    show_disk_usage
    show_docker_usage
    
    # 执行清理
    log_warning "开始清理，这可能需要几分钟..."
    echo ""
    
    cleanup_containers
    cleanup_dangling_images
    cleanup_build_cache
    cleanup_volumes
    cleanup_networks
    cleanup_system_cache
    cleanup_logs
    
    # 显示清理后状态
    show_cleanup_result
    
    echo ""
    log_info "建议："
    log_info "1. 如果空间仍然不足，可以运行："
    log_info "   docker image prune -a  # 清理所有未使用的镜像"
    log_info "2. 定期运行此脚本以保持系统清洁"
    log_info "3. 考虑增加服务器磁盘空间"
    echo ""
}

# 运行主函数
main "$@"

