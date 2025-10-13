#!/bin/bash

# MikkoBlog 部署脚本
# 使用方法: ./scripts/deploy.sh

set -e

echo "🚀 开始部署 MikkoBlog..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 检查环境变量文件
if [ ! -f .env ]; then
    echo "❌ 未找到 .env 文件，请复制 env.example 并配置"
    echo "cp env.example .env"
    exit 1
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p backend/uploads/images
mkdir -p backend/uploads/music
mkdir -p nginx/ssl

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose -f docker-compose.prod.yml down || true

# 拉取最新代码
echo "📥 拉取最新代码..."
git pull origin main

# 构建镜像
echo "🔨 构建Docker镜像..."
docker-compose -f docker-compose.prod.yml build --no-cache

# 启动服务
echo "🚀 启动服务..."
docker-compose -f docker-compose.prod.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.prod.yml ps

# 检查健康状态
echo "🏥 检查服务健康状态..."
if docker-compose -f docker-compose.prod.yml exec -T backend curl -f http://localhost:8000/health 2>/dev/null; then
    echo "✅ 后端服务健康检查通过"
else
    echo "⚠️  后端服务健康检查失败，请检查日志"
fi

if docker-compose -f docker-compose.prod.yml exec -T frontend curl -f http://localhost:80 2>/dev/null; then
    echo "✅ 前端服务健康检查通过"
else
    echo "⚠️  前端服务健康检查失败，请检查日志"
fi

# 清理未使用的镜像
echo "🧹 清理未使用的Docker镜像..."
docker image prune -f

echo "🎉 部署完成！"
echo "📊 服务状态："
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🌐 访问地址："
echo "   前端: http://your-server-ip"
echo "   后端API: http://your-server-ip:8000"
echo "   API文档: http://your-server-ip:8000/docs"
