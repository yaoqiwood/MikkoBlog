# SSH 密钥配置指南

## 问题说明

之前遇到的错误：
```
Error loading key "(stdin)": error in libcrypto
```

这个错误是因为：
1. ❌ 使用了 `webfactory/ssh-agent` 但后续使用 `appleboy/ssh-action` 造成冲突
2. ❌ SSH 私钥格式可能不正确或在添加到 GitHub Secrets 时被损坏

## 已修复的问题

✅ 移除了 `webfactory/ssh-agent` 步骤
✅ 在所有 `appleboy/ssh-action` 步骤中添加了 `key` 参数

## 如何正确配置 SSH 密钥

### 步骤 1：在服务器上生成 OpenSSH 格式的密钥

```bash
# 生成新的 SSH 密钥对（OpenSSH 格式）
ssh-keygen -t ed25519 -C "github-actions@mikkoblog" -f ~/.ssh/github_actions_key -N ""

# 或者使用 RSA 格式（如果服务器不支持 ed25519）
ssh-keygen -t rsa -b 4096 -C "github-actions@mikkoblog" -f ~/.ssh/github_actions_key -N ""
```

### 步骤 2：将公钥添加到 authorized_keys

```bash
# 添加公钥到 authorized_keys
cat ~/.ssh/github_actions_key.pub >> ~/.ssh/authorized_keys

# 设置正确的权限
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### 步骤 3：获取私钥内容

```bash
# 显示私钥内容（需要完整复制，包括开头和结尾）
cat ~/.ssh/github_actions_key
```

**重要提示：**
- ✅ 必须包含 `-----BEGIN OPENSSH PRIVATE KEY-----` 开头
- ✅ 必须包含 `-----END OPENSSH PRIVATE KEY-----` 结尾
- ✅ 保留所有换行符
- ✅ 不要有多余的空格或字符

### 步骤 4：添加到 GitHub Secrets

1. 进入你的 GitHub 仓库
2. 点击 `Settings` -> `Secrets and variables` -> `Actions`
3. 点击 `New repository secret`
4. 名称：`SERVER_SSH_KEY`
5. 值：完整复制私钥内容（从 BEGIN 到 END，包括所有内容）

**复制私钥时的注意事项：**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
... (中间的所有行) ...
AAAAAAAAAAAAAAAAAAAA=
-----END OPENSSH PRIVATE KEY-----
```

### 步骤 5：配置其他 Secrets

确保以下 Secrets 都已正确配置：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `SERVER_HOST` | 服务器 IP 地址或域名 | `192.168.1.100` |
| `SERVER_USER` | SSH 用户名 | `ubuntu` |
| `SERVER_PORT` | SSH 端口 | `22` |
| `SERVER_SSH_KEY` | SSH 私钥（完整内容） | `-----BEGIN OPENSSH...` |
| `PROJECT_PATH` | 项目路径 | `/opt/mikkoblog` |

## 测试 SSH 连接

在本地测试 SSH 连接是否正常：

```bash
# 使用私钥测试连接
ssh -i ~/.ssh/github_actions_key -p 22 username@your-server-ip

# 如果连接成功，说明密钥配置正确
```

## 故障排除

### 如果私钥是旧的 RSA PEM 格式

如果你的私钥开头是 `-----BEGIN RSA PRIVATE KEY-----`，需要转换为 OpenSSH 格式：

```bash
# 转换 PEM 格式到 OpenSSH 格式
ssh-keygen -p -m OpenSSH -f ~/.ssh/old_key
```

### 验证私钥格式

```bash
# 检查私钥格式
head -n 1 ~/.ssh/github_actions_key

# 应该看到以下之一：
# -----BEGIN OPENSSH PRIVATE KEY-----  (推荐)
# -----BEGIN RSA PRIVATE KEY-----      (旧格式，可能有问题)
```

### 如果仍然有问题

1. **重新生成密钥**：删除旧密钥，按照上述步骤重新生成
2. **检查服务器日志**：`sudo tail -f /var/log/auth.log` 查看 SSH 认证日志
3. **验证权限**：确保 `~/.ssh` 目录是 700，`authorized_keys` 是 600

## 安全建议

1. ✅ 使用 `ed25519` 算法（更安全、更快）
2. ✅ 为 CI/CD 创建专用的密钥对，不要使用个人密钥
3. ✅ 定期轮换密钥（建议每 3-6 个月）
4. ✅ 不要在多个项目之间共享同一个密钥
5. ✅ 确保 GitHub Secrets 的访问权限受限

## 现在可以部署了！

修改完成后，提交代码到 `cicd-deploy` 分支：

```bash
git add .github/workflows/deploy.yml
git commit -m "fix: 修复 SSH 密钥加载问题，使用 appleboy/ssh-action 的 key 参数"
git push origin cicd-deploy
```

GitHub Actions 会自动触发部署流程。
