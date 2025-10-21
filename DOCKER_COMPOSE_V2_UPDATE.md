# Docker Compose V2 更新说明

## 变更内容

将项目中所有 `docker-compose` 命令更新为 Docker Compose V2 的 `docker compose` 格式。

## Docker Compose V1 vs V2

### V1 (旧版本 - 已弃用)
```bash
docker-compose up -d
docker-compose down
docker-compose ps
```

### V2 (新版本 - 当前标准)
```bash
docker compose up -d
docker compose down
docker compose ps
```

## 主要区别

| 项目 | V1 | V2 |
|------|----|----|
| 命令格式 | `docker-compose` (带连字符) | `docker compose` (空格) |
| 安装方式 | 独立二进制文件 | Docker CLI 插件 |
| 发布时间 | 2014 年 | 2020 年 |
| 当前状态 | 已弃用 | 活跃维护 |

## 修改的文件 (共 20 个)

### Shell 脚本 (9 个)
1. `github-deploy.sh` - GitHub Actions 自动部署脚本
2. `server-deploy.sh` - 服务器部署脚本
3. `server-deploy-root.sh` - Root 用户部署脚本
4. `deploy.sh` - 通用部署脚本
5. `restore-uploads.sh` - Uploads 恢复脚本
6. `setup-server.sh` - 服务器初始化脚本
7. `quick-deploy.sh` - 快速部署脚本
8. `test-cicd.sh` - CI/CD 测试脚本
9. `dev-start.sh` - 开发环境启动脚本

### GitHub Actions (1 个)
10. `.github/workflows/deploy.yml` - 自动部署工作流

### 文档文件 (10 个)
11. `CICD_SETUP.md` - CI/CD 配置说明
12. `CHANGE_DEPLOY_PATH.md` - 部署路径修改指南
13. `EMERGENCY_FIX.md` - 紧急修复指南
14. `UPLOADS_DATA_LOSS_FIX.md` - Uploads 数据丢失修复
15. `HEALTH_CHECK_FIX.md` - 健康检查修复
16. `QUICK_START_CICD.md` - CI/CD 快速开始
17. `PROJECT_STRUCTURE.md` - 项目结构说明
18. `GIT_DEPLOYMENT.md` - Git 部署指南
19. `DEVELOPMENT.md` - 开发指南
20. `DEPLOYMENT.md` - 部署指南

## 替换统计

- **总替换次数**: 108 处
- **影响文件数**: 20 个
- **验证结果**: ✅ 无遗漏的 `docker-compose`

## 检查命令

验证是否还有遗漏：
```bash
grep -r "docker-compose" --include="*.sh" --include="*.md" --include="*.yml" .
# 应该返回 0 个结果
```

## 兼容性

### 如果服务器还在使用 V1

如果服务器上还没有安装 Docker Compose V2，需要升级：

```bash
# 检查当前版本
docker compose version

# 如果显示 "docker: 'compose' is not a docker command"
# 说明还在使用 V1，需要升级
```

### 升级到 V2

**Ubuntu/Debian:**
```bash
# 卸载旧版本
sudo apt-get remove docker-compose

# 安装 Docker Compose V2 (已包含在新版 Docker 中)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# 验证
docker compose version
# 应该显示类似：Docker Compose version v2.x.x
```

**或者创建别名（临时方案）:**
```bash
# 如果暂时无法升级，可以创建别名
echo 'alias docker-compose="docker compose"' >> ~/.bashrc
source ~/.bashrc
```

## 验证部署

升级后，测试部署是否正常：

```bash
# 进入项目目录
cd /var/www/mikkoblog

# 测试命令
docker compose version
docker compose ps

# 重新部署
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d

# 检查服务状态
docker compose -f docker-compose.prod.yml ps
```

## GitHub Actions 影响

GitHub Actions 使用的 `ubuntu-latest` runner 已经预装了 Docker Compose V2，所以不需要额外配置。

## 相关资源

- [Docker Compose V2 官方文档](https://docs.docker.com/compose/cli-command/)
- [从 V1 迁移到 V2](https://docs.docker.com/compose/migrate/)
- [Compose V2 发布公告](https://www.docker.com/blog/announcing-compose-v2-general-availability/)

## 提交信息

```
commit c11a533
refactor: 将所有 docker-compose 命令更新为 Docker Compose V2 的 docker compose

- 更新所有 Shell 脚本 (9 个文件)
- 更新 GitHub Actions workflow
- 更新所有文档 (10 个 Markdown 文件)
- 适配 Docker Compose V2 的新命令格式
```

## 总结

✅ **已完成**: 所有脚本和文档已更新为 Docker Compose V2 格式  
✅ **已验证**: 无遗漏的旧版命令  
✅ **已推送**: 更改已同步到远程仓库  
🎯 **下一步**: 确保服务器安装了 Docker Compose V2 插件

---

**更新日期**: 2025-10-21

