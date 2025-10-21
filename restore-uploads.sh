#!/bin/bash

# 从旧部署路径恢复 uploads 目录的脚本

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

# 路径配置
OLD_PATH="/var/www/mikkoblog"
NEW_PATH="/opt/mikkoblog"

log_info "开始恢复 uploads 目录..."

# 检查旧路径是否存在
if [ ! -d "$OLD_PATH" ]; then
    log_error "旧部署路径不存在: $OLD_PATH"
    exit 1
fi

# 检查新路径是否存在
if [ ! -d "$NEW_PATH" ]; then
    log_error "新部署路径不存在: $NEW_PATH"
    exit 1
fi

# 检查旧路径是否有 uploads 目录
if [ ! -d "$OLD_PATH/backend/uploads" ]; then
    log_warning "旧路径中没有找到 backend/uploads 目录"
else
    log_info "从 $OLD_PATH/backend/uploads 复制到 $NEW_PATH/backend/uploads"

    # 创建目标目录
    mkdir -p "$NEW_PATH/backend/uploads"

    # 复制文件（保留权限和时间戳）
    rsync -av --progress "$OLD_PATH/backend/uploads/" "$NEW_PATH/backend/uploads/"

    log_success "backend/uploads 目录恢复完成"
fi

# 检查是否有顶层 uploads 目录
if [ -d "$OLD_PATH/uploads" ]; then
    log_info "从 $OLD_PATH/uploads 复制到 $NEW_PATH/uploads"

    # 创建目标目录
    mkdir -p "$NEW_PATH/uploads"

    # 复制文件（保留权限和时间戳）
    rsync -av --progress "$OLD_PATH/uploads/" "$NEW_PATH/uploads/"

    log_success "uploads 目录恢复完成"
fi

# 设置正确的权限
log_info "设置目录权限..."
if [ -d "$NEW_PATH/backend/uploads" ]; then
    chmod -R 755 "$NEW_PATH/backend/uploads"
    log_success "backend/uploads 权限设置完成"
fi

if [ -d "$NEW_PATH/uploads" ]; then
    chmod -R 755 "$NEW_PATH/uploads"
    log_success "uploads 权限设置完成"
fi

# 显示统计信息
log_info "恢复完成！统计信息："
if [ -d "$NEW_PATH/backend/uploads/images" ]; then
    IMAGE_COUNT=$(find "$NEW_PATH/backend/uploads/images" -type f | wc -l)
    log_info "  图片文件数: $IMAGE_COUNT"
fi

if [ -d "$NEW_PATH/backend/uploads/music" ]; then
    MUSIC_COUNT=$(find "$NEW_PATH/backend/uploads/music" -type f -name "*.mp3" | wc -l)
    log_info "  音乐文件数: $MUSIC_COUNT"
fi

log_success "✅ uploads 目录恢复完成！"
log_info ""
log_info "下一步："
log_info "1. 重启 Docker 服务："
log_info "   cd $NEW_PATH"
log_info "   docker compose -f docker-compose.prod.yml restart"
log_info ""
log_info "2. 检查文件是否可以访问："
log_info "   curl -I https://www.mikkocat.top/uploads/images/20251017_140746_99a8c1c3.jpg"
