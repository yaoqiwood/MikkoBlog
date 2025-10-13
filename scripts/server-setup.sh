#!/bin/bash

# 服务器初始化脚本
# 在服务器上运行此脚本来设置部署环境

set -e

echo "🔧 开始设置服务器环境..."

# 更新系统
echo "📦 更新系统包..."
sudo apt update && sudo apt upgrade -y

# 安装Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 安装Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    echo "✅ Docker 已安装"
fi

# 安装Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 安装Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose 已安装"
fi

# 安装Git
if ! command -v git &> /dev/null; then
    echo "📥 安装Git..."
    sudo apt install git -y
else
    echo "✅ Git 已安装"
fi

# 创建项目目录
echo "📁 创建项目目录..."
sudo mkdir -p /opt/mikko-blog
sudo chown $USER:$USER /opt/mikko-blog

# 克隆项目（如果还没有）
if [ ! -d "/opt/mikko-blog/.git" ]; then
    echo "📥 克隆项目..."
    cd /opt/mikko-blog
    git clone https://github.com/your-username/MikkoBlog.git .
else
    echo "✅ 项目已存在"
fi

# 设置环境变量
echo "⚙️  设置环境变量..."
cd /opt/mikko-blog
if [ ! -f .env ]; then
    cp env.example .env
    echo "📝 请编辑 .env 文件配置数据库密码等设置"
    echo "nano .env"
fi

# 设置脚本权限
echo "🔐 设置脚本权限..."
chmod +x scripts/*.sh

# 创建systemd服务（可选）
echo "🔧 创建systemd服务..."
sudo tee /etc/systemd/system/mikko-blog.service > /dev/null <<EOF
[Unit]
Description=MikkoBlog Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/mikko-blog
ExecStart=/opt/mikko-blog/scripts/deploy.sh
ExecStop=/usr/bin/docker-compose -f /opt/mikko-blog/docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
sudo systemctl daemon-reload

echo "🎉 服务器环境设置完成！"
echo ""
echo "📋 接下来的步骤："
echo "1. 编辑环境变量: nano /opt/mikko-blog/.env"
echo "2. 运行部署脚本: cd /opt/mikko-blog && ./scripts/deploy.sh"
echo "3. 设置GitHub Secrets（见README）"
echo "4. 推送代码到main分支触发自动部署"
echo ""
echo "🔧 有用的命令："
echo "   查看服务状态: docker-compose -f docker-compose.prod.yml ps"
echo "   查看日志: docker-compose -f docker-compose.prod.yml logs -f"
echo "   重启服务: docker-compose -f docker-compose.prod.yml restart"
