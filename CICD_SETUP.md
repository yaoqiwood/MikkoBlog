# GitHub Actions CI/CD 配置说明

本文档说明如何配置 GitHub Actions 实现自动部署到服务器。

## 前置条件

### 服务器端准备

1. **安装必要软件**
   ```bash
   # 安装 Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER

   # 安装 Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker compose
   sudo chmod +x /usr/local/bin/docker compose

   # 安装 Git
   sudo apt update
   sudo apt install git -y
   ```

2. **创建项目目录**
   ```bash
   sudo mkdir -p /opt/mikkoblog
   sudo chown $USER:$USER /opt/mikkoblog
   ```

3. **克隆项目代码**
   ```bash
   cd /opt
   git clone https://github.com/yaoqiwood/MikkoBlog.git mikkoblog
   cd mikkoblog
   git checkout cicd-deploy
   ```

4. **配置环境文件**
   ```bash
   # 复制环境配置模板
   cp config-templates/env.production.template .env.production

   # 编辑环境配置
   nano .env.production
   ```

5. **生成 SSH 密钥对**
   ```bash
   # 生成 SSH 密钥对（如果还没有）
   ssh-keygen -t rsa -b 4096 -C "github-actions@yourdomain.com"

   # 将公钥添加到 authorized_keys
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

   # 显示私钥内容（需要添加到 GitHub Secrets）
   cat ~/.ssh/id_rsa
   ```

### GitHub 仓库配置

1. **配置 GitHub Secrets**

   在 GitHub 仓库中，进入 `Settings` -> `Secrets and variables` -> `Actions`，添加以下 secrets：

   | Secret 名称 | 说明 | 示例值 |
   |------------|------|--------|
   | `SERVER_HOST` | 服务器 IP 地址或域名 | `192.168.1.100` 或 `yourdomain.com` |
   | `SERVER_USER` | SSH 用户名 | `ubuntu` 或 `root` |
   | `SERVER_PORT` | SSH 端口 | `22` |
   | `SERVER_SSH_KEY` | SSH 私钥内容 | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
   | `PROJECT_PATH` | 项目在服务器上的路径 | `/var/www/mikkoblog` |

2. **验证配置**

   提交代码到 `cicd-deploy` 分支，GitHub Actions 会自动触发部署。

## 工作流程说明

### 触发条件

- 当有代码推送到 `cicd-deploy` 分支时
- 手动触发（在 GitHub Actions 页面点击 "Run workflow"）

### 部署步骤

1. **代码检出** - 从 GitHub 仓库检出最新代码
2. **SSH 连接测试** - 验证与服务器的连接
3. **部署执行** - 在服务器上执行部署脚本
4. **部署验证** - 检查服务是否正常运行
5. **状态通知** - 显示部署结果

### 部署脚本功能

`github-deploy.sh` 脚本会执行以下操作：

1. 检查系统要求（Docker、Docker Compose、Git）
2. 更新代码到最新版本
3. 创建必要的目录
4. 停止现有服务
5. 构建和启动新服务
6. 等待服务就绪
7. 执行健康检查
8. 显示部署信息

## 故障排除

### 常见问题

1. **SSH 连接失败**
   - 检查 `SERVER_HOST`、`SERVER_USER`、`SERVER_PORT` 是否正确
   - 确认 SSH 私钥格式正确
   - 检查服务器防火墙设置

2. **部署失败**
   - 检查服务器上是否有足够的磁盘空间
   - 确认 Docker 和 Docker Compose 已正确安装
   - 查看 GitHub Actions 日志获取详细错误信息

3. **服务启动失败**
   - 检查端口是否被占用
   - 查看 Docker 容器日志：`docker compose -f docker-compose.prod.yml logs`
   - 检查环境配置文件是否正确

### 查看日志

```bash
# 在服务器上查看部署日志
cd /opt/mikkoblog
docker compose -f docker-compose.prod.yml logs -f

# 查看特定服务日志
docker compose -f docker-compose.prod.yml logs -f backend
docker compose -f docker-compose.prod.yml logs -f frontend
```

### 手动部署

如果需要手动部署，可以在服务器上运行：

```bash
cd /opt/mikkoblog
./github-deploy.sh
```

## 安全建议

1. **使用非 root 用户** - 建议使用普通用户而不是 root 用户运行部署
2. **限制 SSH 访问** - 配置防火墙只允许必要的 IP 访问 SSH 端口
3. **定期更新密钥** - 定期轮换 SSH 密钥
4. **监控部署** - 设置监控和告警来跟踪部署状态

## 自定义配置

### 修改部署脚本

可以编辑 `github-deploy.sh` 脚本来添加自定义的部署步骤：

```bash
# 在脚本中添加自定义命令
echo "执行自定义部署步骤..."
# 你的自定义命令
```

### 添加通知

可以在 GitHub Actions 工作流中添加通知功能，比如发送邮件或 Slack 消息：

```yaml
- name: Send notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 支持

如果遇到问题，请：

1. 查看 GitHub Actions 日志
2. 检查服务器上的 Docker 日志
3. 确认所有 Secrets 配置正确
4. 参考本文档的故障排除部分
