#!/bin/bash

# 简化的服务器设置脚本
# 使用方法: curl -fsSL https://raw.githubusercontent.com/yaoqiwood/MikkoBlog/cicd-deploy/scripts/simple-server-setup.sh | bash

echo "🚀 开始服务器设置..."
echo "=================================="

# 变量
REPO_URL="https://github.com/yaoqiwood/MikkoBlog.git"
BRANCH_NAME="cicd-deploy"
PROJECT_DIR="/opt/mikko-blog"

# 1. 更新系统
echo "🔄 更新系统软件包..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. 安装Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 安装Docker..."
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "✅ Docker安装完成"
else
    echo "✅ Docker已安装"
fi

# 3. 创建项目目录
echo "📁 创建项目目录..."
sudo mkdir -p "$PROJECT_DIR"
sudo chown $USER:$USER "$PROJECT_DIR"

# 4. 克隆项目
echo "📥 克隆项目..."
cd "$PROJECT_DIR"
if [ ! -d ".git" ]; then
    git clone -b "$BRANCH_NAME" "$REPO_URL" .
else
    git pull origin "$BRANCH_NAME"
fi

# 5. 设置环境变量
echo "⚙️  设置环境变量..."
if [ ! -f ".env" ]; then
    echo "创建 .env 文件..."
    cp env.example .env
    echo "✅ 已创建 .env 文件"
    echo "📝 请编辑 .env 文件，设置数据库密码等配置:"
    echo "   nano .env"
    echo ""
    echo "必需的配置项:"
    echo "   MYSQL_ROOT_PASSWORD=你的数据库root密码"
    echo "   MYSQL_DATABASE=mikko_blog"
    echo "   MYSQL_USER=mikko"
    echo "   MYSQL_PASSWORD=你的数据库用户密码"
    echo ""
    read -p "按 Enter 继续，或 Ctrl+C 退出编辑配置..."
fi

# 6. 设置脚本权限
echo "🔒 设置脚本权限..."
chmod +x scripts/*.sh

echo "🎉 服务器设置完成！"
echo "=================================="
echo "下一步:"
echo "1. 编辑 .env 文件: nano .env"
echo "2. 运行部署脚本: ./scripts/manual-deploy.sh"
echo "=================================="
