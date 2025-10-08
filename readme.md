# 📝MikkoBlog
## 相关技术 FastAPI + Vue3 Blog

一个基于 **FastAPI + Vue3 + MySQL** 的现代化个人博客系统，支持 **Markdown 编辑、全文检索、图片上传、后台管理**，既能做个人作品集展示，也适合实际部署使用。
前后端是分开的

---

## ✨ 功能特点

### 🖊️ 写作 & 内容管理
- Markdown 编辑器（支持实时预览、代码高亮）
- 文章分类、标签管理
- 草稿 / 发布状态切换
- 图片上传 & 图床接口（支持封面图/插图）
- 自动生成文章摘要

### 🔍 检索 & 推荐
- 标题 / 正文关键词搜索
- 向量检索（MySQL + PGVector / FAISS，可选）
- 热门文章、相关文章推荐

### 🎨 前端展示
- 基于 **Vue 3 + Vite + Tailwind CSS**
- 响应式页面（桌面 / 移动端适配）
- 文章详情页、列表页、标签页
- 图片展示 / 封面展示
- 读者评论（可选后续功能）

### 🔑 用户 & 管理
- 管理后台（文章 CRUD、用户管理）
- 登录鉴权（JWT）
- 管理员 / 普通用户角色分级
- Swagger API 文档

### ⚙️ 工程化
- **后端**：FastAPI + SQLModel + MySQL
- **前端**：Vue 3 + Vite + Tailwind
- **部署**：Docker Compose / Caddy / Cloudflare
- **CI/CD**：GitHub Actions 自动化部署

---

## 🛠️ 技术栈

### 后端
- [FastAPI](https://fastapi.tiangolo.com/) - 高性能异步 Web 框架
- [SQLModel](https://sqlmodel.tiangolo.com/) - ORM + Pydantic 模型
- [MySQL 8](https://www.mysql.com/) - 数据存储
- [FAISS / PGVector] - 向量检索（可选扩展）
- [Uvicorn](https://www.uvicorn.org/) - ASGI 服务器
- [Passlib] - 密码哈希
- [JWT] - 登录鉴权

### 前端
- [Vue 3](https://vuejs.org/) + [Vite](https://vitejs.dev/)
- [Tailwind CSS](https://tailwindcss.com/) - 快速美观 UI
- [Editor.md](https://pandao.github.io/editor.md/) / `vue3-markdown-editor` - Markdown 编辑器
- Axios - 前后端通信

### 部署
- Docker + Docker Compose
- Caddy (反向代理 & HTTPS)
- Cloudflare DNS + CDN
- GitHub Actions (CI/CD)

---

## 📌 项目进度

- [x] FastAPI 后端基础 CRUD
- [x] MySQL 集成
- [x] JWT 登录 / 注册
- [x] Vue3 前端框架初始化
- [x] 加入 iview
- [x] Markdown 编辑器集成
- [x] 前端展示页（文章列表 / 详情）
- [ ] Live2D 看板娘展示
- [x] 管理后台页面
- [x] 搜索接口 & 前端调用
- [x] 管理评论系统
- [ ] 音乐播放插件
- [ ] CI/CD 自动部署

---

## 🚀 快速启动

### 后端
```bash
cd backend
docker compose up -d
