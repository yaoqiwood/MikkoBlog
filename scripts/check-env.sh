#!/bin/bash

# 检查环境变量配置的脚本
echo "🔍 检查环境变量配置..."
echo "=================================="

# 检查 .env 文件是否存在
if [ -f ".env" ]; then
    echo "✅ .env 文件存在"
    echo "📋 .env 文件内容（隐藏敏感信息）:"
    grep -E "^[A-Z_]+" .env | sed 's/=.*/=***/' || echo "没有找到环境变量"
else
    echo "❌ .env 文件不存在"
    echo "📋 检查 env.example 文件:"
    if [ -f "env.example" ]; then
        echo "✅ env.example 文件存在"
        echo "📋 env.example 文件内容:"
        cat env.example
    else
        echo "❌ env.example 文件也不存在"
    fi
fi

echo "=================================="
echo "🎯 环境变量检查完成！"
