#!/bin/bash

# 测试部署状态的脚本
# 使用方法: ./scripts/test-deployment.sh [服务器IP]

SERVER_IP=${1:-"172.245.81.59"}

echo "🔍 测试部署状态 - 服务器: $SERVER_IP"
echo "=================================="

# 测试前端访问
echo "📱 测试前端访问..."
if curl -s -f "http://$SERVER_IP" > /dev/null; then
    echo "✅ 前端访问正常"
else
    echo "❌ 前端访问失败"
fi

# 测试后端健康检查
echo "🔧 测试后端健康检查..."
if curl -s -f "http://$SERVER_IP:8000/api/healthz" > /dev/null; then
    echo "✅ 后端健康检查正常"
else
    echo "❌ 后端健康检查失败"
fi

# 测试API访问
echo "🌐 测试API访问..."
if curl -s -f "http://$SERVER_IP/api/healthz" > /dev/null; then
    echo "✅ API访问正常"
else
    echo "❌ API访问失败"
fi

# 测试管理页面
echo "⚙️  测试管理页面..."
if curl -s -f "http://$SERVER_IP/admin" > /dev/null; then
    echo "✅ 管理页面访问正常"
else
    echo "❌ 管理页面访问失败"
fi

echo "=================================="
echo "🎯 测试完成！"