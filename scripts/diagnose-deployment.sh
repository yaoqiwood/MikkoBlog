#!/bin/bash

# 详细的部署诊断脚本
# 使用方法: ./scripts/diagnose-deployment.sh [服务器IP]

SERVER_IP=${1:-"172.245.81.59"}

echo "🔍 详细部署诊断 - 服务器: $SERVER_IP"
echo "=================================="

# 检查端口连通性
echo "🔌 检查端口连通性..."
echo "端口 80 (前端):"
nc -z -w5 $SERVER_IP 80 && echo "✅ 端口 80 开放" || echo "❌ 端口 80 关闭"

echo "端口 8000 (后端):"
nc -z -w5 $SERVER_IP 8000 && echo "✅ 端口 8000 开放" || echo "❌ 端口 8000 关闭"

echo "端口 3306 (MySQL):"
nc -z -w5 $SERVER_IP 3306 && echo "✅ 端口 3306 开放" || echo "❌ 端口 3306 关闭"

echo ""

# 检查HTTP响应
echo "🌐 检查HTTP响应..."
echo "前端响应:"
curl -I -s --connect-timeout 10 "http://$SERVER_IP" | head -1 || echo "❌ 前端无响应"

echo "后端健康检查响应:"
curl -I -s --connect-timeout 10 "http://$SERVER_IP:8000/health" | head -1 || echo "❌ 后端无响应"

echo ""

# 检查具体的错误信息
echo "📋 详细错误信息..."
echo "前端错误:"
curl -s --connect-timeout 10 "http://$SERVER_IP" 2>&1 | head -3 || echo "无法获取前端错误信息"

echo "后端错误:"
curl -s --connect-timeout 10 "http://$SERVER_IP:8000/health" 2>&1 | head -3 || echo "无法获取后端错误信息"

echo "=================================="
echo "🎯 诊断完成！"
