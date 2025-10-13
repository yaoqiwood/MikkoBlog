#!/bin/bash

# 测试Docker构建脚本
# 使用方法: ./scripts/test-build.sh

set -e

echo "🧪 测试Docker构建..."

# 检查文件是否存在
echo "📁 检查必要文件..."
if [ ! -f "frontend/Dockerfile" ]; then
    echo "❌ frontend/Dockerfile 不存在"
    exit 1
fi

if [ ! -f "frontend/nginx.conf" ]; then
    echo "❌ frontend/nginx.conf 不存在"
    exit 1
fi

if [ ! -f "backend/Dockerfile" ]; then
    echo "❌ backend/Dockerfile 不存在"
    exit 1
fi

echo "✅ 所有必要文件存在"

# 测试前端构建
echo "🔨 测试前端Docker构建..."
cd frontend
if docker build -t mikko-blog-frontend:test .; then
    echo "✅ 前端构建成功"
else
    echo "❌ 前端构建失败"
    exit 1
fi
cd ..

# 测试后端构建
echo "🔨 测试后端Docker构建..."
if docker build -t mikko-blog-backend:test -f backend/Dockerfile .; then
    echo "✅ 后端构建成功"
else
    echo "❌ 后端构建失败"
    exit 1
fi

# 清理测试镜像
echo "🧹 清理测试镜像..."
docker rmi mikko-blog-frontend:test mikko-blog-backend:test 2>/dev/null || true

echo "🎉 所有构建测试通过！"
