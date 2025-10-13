#!/bin/bash

# MikkoBlog 部署测试脚本
# 使用方法: ./scripts/test-deployment.sh [server-ip]

set -e

# 获取服务器IP
SERVER_IP=${1:-"localhost"}

echo "🧪 开始测试 MikkoBlog 部署..."
echo "📍 测试服务器: $SERVER_IP"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试函数
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}

    echo -n "🔍 测试 $description... "

    if response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null); then
        if [ "$response" = "$expected_status" ]; then
            echo -e "${GREEN}✅ 成功 (HTTP $response)${NC}"
            return 0
        else
            echo -e "${RED}❌ 失败 (HTTP $response, 期望 $expected_status)${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ 连接失败${NC}"
        return 1
    fi
}

# 测试Docker容器状态
echo "🐳 检查Docker容器状态..."
if command -v docker-compose &> /dev/null; then
    cd /opt/mikko-blog 2>/dev/null || echo "⚠️  未在项目目录中，跳过容器检查"

    if [ -f "docker-compose.prod.yml" ]; then
        echo "📊 容器状态："
        docker-compose -f docker-compose.prod.yml ps
        echo ""
    fi
else
    echo "⚠️  Docker Compose 未安装，跳过容器检查"
fi

# 测试后端API
echo "🔧 测试后端API..."
test_endpoint "http://$SERVER_IP:8000/health" "后端健康检查"
test_endpoint "http://$SERVER_IP:8000/docs" "API文档页面"
test_endpoint "http://$SERVER_IP:8000/api/users/" "用户API" 200

echo ""

# 测试前端
echo "🌐 测试前端..."
test_endpoint "http://$SERVER_IP" "前端首页"
test_endpoint "http://$SERVER_IP/admin" "管理后台"

echo ""

# 测试API代理
echo "🔄 测试API代理..."
test_endpoint "http://$SERVER_IP/api/users/" "前端API代理"

echo ""

# 测试数据库连接
echo "🗄️  测试数据库连接..."
if command -v docker-compose &> /dev/null && [ -f "/opt/mikko-blog/docker-compose.prod.yml" ]; then
    cd /opt/mikko-blog
    if docker-compose -f docker-compose.prod.yml exec -T db mysql -u root -p${MYSQL_ROOT_PASSWORD:-root_pass} -e "SELECT 1;" &>/dev/null; then
        echo -e "🔍 测试数据库连接... ${GREEN}✅ 成功${NC}"
    else
        echo -e "🔍 测试数据库连接... ${RED}❌ 失败${NC}"
    fi
else
    echo "⚠️  跳过数据库测试（需要Docker环境）"
fi

echo ""

# 性能测试
echo "⚡ 性能测试..."
echo -n "🔍 测试响应时间... "
response_time=$(curl -s -o /dev/null -w "%{time_total}" "http://$SERVER_IP" 2>/dev/null || echo "0")
if (( $(echo "$response_time < 2.0" | bc -l) )); then
    echo -e "${GREEN}✅ 快速 (${response_time}s)${NC}"
else
    echo -e "${YELLOW}⚠️  较慢 (${response_time}s)${NC}"
fi

echo ""

# 总结
echo "📋 测试总结："
echo "   🌐 前端地址: http://$SERVER_IP"
echo "   🔧 后端API: http://$SERVER_IP:8000"
echo "   📚 API文档: http://$SERVER_IP:8000/docs"
echo "   ⚙️  管理后台: http://$SERVER_IP/admin"
echo ""

echo "🎉 部署测试完成！"
echo ""
echo "💡 如果测试失败，请检查："
echo "   1. 服务器防火墙设置"
echo "   2. Docker容器状态"
echo "   3. 服务日志: docker-compose -f docker-compose.prod.yml logs"
echo "   4. 环境变量配置"
