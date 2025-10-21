# 🚀 CI/CD 快速开始指南

本指南将帮助您快速配置 GitHub Actions CI/CD 自动部署。

## 📋 前置条件

- 一台 Linux 服务器（Ubuntu/CentOS 等）
- GitHub 仓库
- 基本的 Linux 命令行知识

## ⚡ 快速设置（5分钟）

### 1. 在服务器上运行设置脚本

```bash
# 下载并运行设置脚本
curl -fsSL https://raw.githubusercontent.com/yaoqiwood/MikkoBlog/cicd-deploy/setup-server.sh | bash
```

或者手动执行：

```bash
# 克隆项目
git clone https://github.com/yaoqiwood/MikkoBlog.git
cd MikkoBlog
git checkout cicd-deploy

# 运行设置脚本
chmod +x setup-server.sh
./setup-server.sh
```

### 2. 配置 GitHub Secrets

在 GitHub 仓库中，进入 `Settings` -> `Secrets and variables` -> `Actions`，添加：

| Secret 名称 | 值 | 说明 |
|------------|---|------|
| `SERVER_HOST` | `你的服务器IP` | 如：`192.168.1.100` |
| `SERVER_USER` | `服务器用户名` | 如：`ubuntu` |
| `SERVER_PORT` | `22` | SSH 端口 |
| `SERVER_SSH_KEY` | `私钥内容` | 运行设置脚本后显示的私钥 |
| `PROJECT_PATH` | `/opt/mikkoblog` | 项目路径 |

### 3. 触发部署

推送代码到 `cicd-deploy` 分支：

```bash
git add .
git commit -m "触发自动部署"
git push origin cicd-deploy
```

## 🔍 验证部署

1. 访问 GitHub Actions 页面查看部署状态
2. 访问 `http://你的服务器IP` 查看前端
3. 访问 `http://你的服务器IP:8000/health` 检查后端

## 📚 详细文档

- [完整配置说明](CICD_SETUP.md) - 详细的配置步骤和故障排除
- [项目结构说明](PROJECT_STRUCTURE.md) - 了解项目结构

## 🛠️ 常用命令

```bash
# 查看部署日志
cd /opt/mikkoblog
docker-compose -f docker-compose.prod.yml logs -f

# 手动部署
cd /opt/mikkoblog
./github-deploy.sh

# 停止服务
cd /opt/mikkoblog
docker-compose -f docker-compose.prod.yml down

# 重启服务
cd /opt/mikkoblog
docker-compose -f docker-compose.prod.yml restart
```

## ❓ 遇到问题？

1. 查看 [故障排除指南](CICD_SETUP.md#故障排除)
2. 检查 GitHub Actions 日志
3. 检查服务器上的 Docker 日志

## 🎉 完成！

现在每当您推送代码到 `cicd-deploy` 分支时，GitHub Actions 会自动部署到您的服务器！
