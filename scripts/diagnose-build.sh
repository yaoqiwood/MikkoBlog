#!/bin/bash

# Docker构建诊断脚本
# 使用方法: ./scripts/diagnose-build.sh

set -e

echo "🔍 Docker构建诊断..."

# 检查Docker版本
echo "📋 Docker版本信息："
docker --version
docker-compose --version

# 检查Node.js版本要求
echo ""
echo "📋 检查Node.js版本兼容性..."
echo "当前package.json中的依赖："
if [ -f "frontend/package.json" ]; then
    echo "Vite版本："
    grep -A 1 -B 1 "vite" frontend/package.json || echo "未找到vite"
    echo ""
    echo "@vitejs/plugin-vue版本："
    grep -A 1 -B 1 "@vitejs/plugin-vue" frontend/package.json || echo "未找到@vitejs/plugin-vue"
fi

# 检查Dockerfile内容
echo ""
echo "📋 检查Dockerfile配置..."
if [ -f "frontend/Dockerfile" ]; then
    echo "前端Dockerfile中的Node.js版本："
    grep "FROM node" frontend/Dockerfile
else
    echo "❌ frontend/Dockerfile 不存在"
fi

# 测试本地Node.js版本
echo ""
echo "📋 本地Node.js版本："
if command -v node &> /dev/null; then
    node --version
    npm --version
else
    echo "❌ Node.js 未安装"
fi

# 检查前端构建
echo ""
echo "🔨 测试前端本地构建..."
if [ -f "frontend/package.json" ]; then
    cd frontend
    echo "安装依赖..."
    if npm ci; then
        echo "✅ 依赖安装成功"
        echo "尝试构建..."
        if npm run build; then
            echo "✅ 本地构建成功"
        else
            echo "❌ 本地构建失败"
        fi
    else
        echo "❌ 依赖安装失败"
    fi
    cd ..
else
    echo "❌ frontend/package.json 不存在"
fi

echo ""
echo "🎯 建议："
echo "1. 确保使用Node.js 20+版本"
echo "2. 检查package.json中的依赖版本"
echo "3. 如果本地构建失败，先修复本地环境"
echo "4. 确保Dockerfile使用正确的Node.js版本"
