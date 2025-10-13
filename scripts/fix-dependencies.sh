#!/bin/bash

# 修复依赖兼容性脚本
# 使用方法: ./scripts/fix-dependencies.sh

set -e

echo "🔧 修复依赖兼容性问题..."

cd frontend

# 备份原始package.json
if [ -f "package.json" ]; then
    cp package.json package.json.backup
    echo "✅ 已备份原始package.json"
fi

# 降级关键依赖到兼容Node.js 18的版本
echo "📦 降级依赖版本..."

# 使用npm来降级特定包
npm install --save-dev vite@^5.4.10 @vitejs/plugin-vue@^5.1.4
npm install marked@^15.0.0

echo "✅ 依赖降级完成"

# 显示当前版本
echo "📋 当前关键依赖版本："
echo "Vite: $(npm list vite --depth=0)"
echo "@vitejs/plugin-vue: $(npm list @vitejs/plugin-vue --depth=0)"
echo "marked: $(npm list marked --depth=0)"

echo ""
echo "🧪 测试构建..."
if npm run build; then
    echo "✅ 构建成功！"
    echo ""
    echo "🎉 依赖修复完成！"
    echo "现在可以推送代码到GitHub了。"
else
    echo "❌ 构建仍然失败"
    echo "正在恢复原始package.json..."
    if [ -f "package.json.backup" ]; then
        mv package.json.backup package.json
        npm install
    fi
    exit 1
fi

cd ..
