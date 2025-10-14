#!/bin/bash

# 手动部署脚本
# 使用方法: ./scripts/manual-deploy.sh

echo "🚀 开始手动部署 MikkoBlog..."
echo "=================================="

# 检查是否在正确的目录
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "⚠️  警告: .env 文件不存在，从 env.example 创建..."
    if [ -f "env.example" ]; then
        cp env.example .env
        echo "✅ 已创建 .env 文件，请编辑其中的配置"
        echo "📝 请编辑 .env 文件，设置正确的数据库密码等配置"
        echo "   例如: nano .env"
        read -p "按 Enter 继续，或 Ctrl+C 退出编辑配置..."
    else
        echo "❌ 错误: env.example 文件也不存在"
        exit 1
    fi
fi

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose -f docker-compose.prod.yml down

# 清理未使用的镜像
echo "🧹 清理未使用的镜像..."
docker image prune -f

# 构建新镜像
echo "🔨 构建新镜像..."
docker-compose -f docker-compose.prod.yml build --no-cache

# 启动服务
echo "🚀 启动服务..."
docker-compose -f docker-compose.prod.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "📋 检查服务状态..."
docker-compose -f docker-compose.prod.yml ps

# 检查容器日志
echo "📝 检查容器日志..."
echo "=== 前端日志 ==="
docker logs mikko_frontend_prod --tail=20

echo "=== 后端日志 ==="
docker logs mikko_backend_prod --tail=20

echo "=== MySQL日志 ==="
docker logs mikko_mysql_prod --tail=10

# 测试服务
echo "🧪 测试服务..."
echo "测试前端访问..."
curl -I http://localhost || echo "前端访问失败"

echo "测试后端健康检查..."
curl -I http://localhost:8000/api/healthz || echo "后端健康检查失败"

echo "测试API代理..."
curl -I http://localhost/api/healthz || echo "API代理失败"

echo "=================================="
echo "🎉 手动部署完成！"
echo "📱 前端地址: http://localhost"
echo "⚙️  管理页面: http://localhost/admin"
echo "🔧 后端API: http://localhost:8000"
echo "=================================="
