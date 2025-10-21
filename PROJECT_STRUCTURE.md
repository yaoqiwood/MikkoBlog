# MikkoBlog 项目文件结构

## 📁 项目根目录

```
MikkoBlog/
├── backend/                          # 后端服务 (FastAPI + Python)
├── frontend/                         # 前端服务 (Vue 3 + Vite)
├── nginx/                           # Nginx 配置文件
├── uploads/                         # 上传文件存储
├── docker-compose.yml               # Docker Compose 配置
├── LIVE2D_WIDGET_README.md          # Live2D 看板娘说明
├── music-player-integration.md      # 音乐播放器集成说明
├── PROJECT_STRUCTURE.md             # 项目结构文档 (本文件)
├── readme.md                        # 项目说明文档
└── SCROLLBAR_FIX.md                 # 滚动条修复说明
```

## 🐍 后端结构 (backend/)

```
backend/
├── app/                             # 主应用目录
│   ├── __pycache__/                 # Python 缓存文件
│   ├── api/                         # API 路由
│   │   ├── __pycache__/
│   │   └── routers/                 # 路由模块
│   │       ├── __pycache__/
│   │       ├── admin.py             # 管理员相关路由
│   │       ├── attachments.py       # 附件管理路由
│   │       ├── auth.py              # 认证相关路由
│   │       ├── columns.py           # 专栏管理路由
│   │       ├── comments.py          # 评论管理路由
│   │       ├── health.py            # 健康检查路由
│   │       ├── homepage.py          # 首页设置路由
│   │       ├── image_search.py      # 图片搜索路由
│   │       ├── local_music.py       # 本地音乐管理路由
│   │       ├── moments.py           # 动态管理路由
│   │       ├── music.py             # 音乐相关路由
│   │       ├── posts.py             # 文章管理路由
│   │       ├── postStats.py         # 文章统计路由
│   │       ├── stats.py             # 统计数据路由
│   │       ├── system.py            # 系统管理路由
│   │       ├── system_setting.py    # 系统设置路由
│   │       ├── tagCloud.py          # 标签云路由
│   │       └── upload.py            # 文件上传路由
│   ├── core/                        # 核心配置
│   │   ├── __pycache__/
│   │   ├── config.py                # 应用配置
│   │   └── security.py              # 安全相关功能
│   ├── db/                          # 数据库相关
│   │   ├── __pycache__/
│   │   └── session.py               # 数据库会话管理
│   ├── main.py                      # 应用入口文件
│   ├── models/                      # 数据模型
│   │   ├── __pycache__/
│   │   ├── attachment.py            # 附件模型
│   │   ├── columns.py               # 专栏模型
│   │   ├── comment.py               # 评论模型
│   │   ├── homepage.py              # 首页设置模型
│   │   ├── local_music.py           # 本地音乐模型
│   │   ├── moments.py               # 动态模型
│   │   ├── music.py                 # 音乐模型
│   │   ├── post.py                  # 文章模型
│   │   ├── postStats.py             # 文章统计模型
│   │   ├── system_setting.py        # 系统设置模型
│   │   ├── system.py                # 系统模型
│   │   ├── tagCloud.py              # 标签云模型
│   │   └── user.py                  # 用户模型
│   ├── scheduler/                   # 定时任务
│   │   ├── __pycache__/
│   │   └── tag_cloud_scheduler.py   # 标签云定时任务
│   └── services/                    # 业务服务
│       ├── __pycache__/
│       ├── image_search.py          # 图片搜索服务
│       └── tagCloud.py              # 标签云服务
├── config/                          # 配置文件
│   └── config.yaml                  # 主配置文件
├── sql/                             # 数据库初始化脚本
│   ├── add_header_title_to_homepage.sql
│   ├── add_welcome_modal_type_setting.sql
│   ├── ai_settings_utf8.sql
│   ├── ai_settings.sql
│   ├── attachments.sql
│   ├── columns.sql
│   ├── create_system_table_sqlite.sql
│   ├── create_system_table.sql
│   ├── home_page_settings.sql
│   ├── homepage_default_images_utf8mb4.sql
│   ├── homepage_default_images.sql
│   ├── homepage_header_title_implementation.md
│   ├── image_search_settings.sql
│   ├── insert_system_defaults.sql
│   ├── local_music.sql
│   ├── moments_implementation.md
│   ├── moments.sql
│   ├── music_playlist.sql
│   ├── post_stats_api_usage.md
│   ├── post_stats.sql
│   ├── posts_api_with_stats.md
│   ├── site_settings_utf8.sql
│   ├── system_defaults_simple.sql
│   ├── system_defaults.sql
│   ├── system_setting.sql
│   ├── tag_cloud.sql
│   └── user_profiles.sql
├── uploads/                         # 上传文件存储
│   ├── images/                      # 图片文件
│   │   ├── 20250922_151557_b4dc48e8.png
│   │   ├── 20250922_152037_412728c6.jpg
│   │   ├── 20250922_153219_73bf4417.png
│   │   ├── 20250922_153225_a080f225.png
│   │   ├── 20250923_004705_78763e49.jpg
│   │   ├── 20250923_020952_91843c1f.png
│   │   ├── 20250926_165511_fa9ecc65.jpg
│   │   ├── 20250926_165853_6e139463.jpg
│   │   ├── 20250926_165912_6cc02d0.jpg
│   │   ├── 20251001_090841_1a218894.jpg
│   │   ├── 20251001_111403_5ae4cdd5.jpeg
│   │   ├── 20251001_111433_b13b85a7.jpeg
│   │   ├── 20251001_144416_c2c9fc2e.jpeg
│   │   ├── 20251002_112502_5baf5c56.jpeg
│   │   ├── 20251002_114240_8507689f.png
│   │   ├── 20251002_114531_0126de37.png
│   │   ├── 20251002_114633_cc173b61.svg
│   │   ├── 20251002_203239_bf29c592.jpg
│   │   ├── 20251002_203242_06ec1708.jpg
│   │   ├── 20251002_203244_70a27031.jpg
│   │   ├── 20251002_203247_6246c9d2.jpg
│   │   ├── 20251002_203249_4640fcb3.jpg
│   │   ├── 20251002_204140_d8c41943.jpg
│   │   ├── 20251002_204143_d7a54efa.jpg
│   │   ├── 20251003_110312_aabcd621.jpg
│   │   ├── 20251003_110321_ac03eb35.jpg
│   │   ├── 2e39bf1daf684254894c1969838ba7bf.png
│   │   ├── 6202235e61104d1b977c524a298fc539.jpg
│   │   ├── 7ed3573e182a4363bff5034026cc02d0.png
│   │   ├── a5f4984e007546febeb982c812445191.png
│   │   ├── c699f803518b467886e01ae243b619b6.png
│   │   ├── e41d1f3cdbda444ca1efcd6f1ee4385f.png
│   │   ├── e431f010573b4464a7a7e37bc586aec7.png
│   │   ├── e9eb80414ced4b0b9646cf71c349af4c.jpg
│   │   └── f323e06bc7054e659baf91d4512f6f1f.png
│   └── music/                        # 音乐文件
│       ├── 09af8378-36ee-4fd3-8bc2-c91dfab8112f.mp3
│       ├── aa903c30-eeea-45ea-842b-cecf75b2f6df.mp3
│       ├── b4703e57-6d76-4b1b-8fe2-59d03cde1801.mp3
│       ├── c098a477-d9e3-4633-99b6-716f5fe90aac.mp3
│       └── covers/
│           └── [音乐封面文件]
├── backend.log                       # 后端日志文件
├── Dockerfile                        # 后端 Docker 配置
├── requirements.txt                  # Python 依赖包
├── test_homepage_title.py            # 首页标题测试
└── test_posts_api.py                 # 文章 API 测试
```

## 🎨 前端结构 (frontend/)

```
frontend/
├── backend/                          # 后端上传文件副本
│   └── uploads/
│       └── music/                    # 音乐文件
├── dist/                             # 构建输出目录
│   └── assets/                       # 构建后的静态资源
│       ├── AttachmentManagement-1Fv8Fuy1.css
│       ├── AttachmentManagement-Bgp_aTjf.js
│       ├── ColumnsManagement-CIx0nqZ4.css
│       ├── ColumnsManagement-CvEphOMX.js
│       ├── HomepageSettings-4i6Gljrh.css
│       ├── HomepageSettings-rxKP4_DH.js
│       ├── index-CbQRcPjJ.js
│       ├── index-CIHgxqVY.css
│       ├── ionicons-BP-3J37-.ttf
│       ├── ionicons-CIIvoz24.woff2
│       ├── ionicons-E4jYJjsE.svg
│       ├── ionicons-fsCmv2gq.woff
│       ├── MarkdownEditor-DdvgzegD.css
│       ├── MarkdownEditor-DHucw_hC.js
│       ├── MomentsManagement-CiIbirJJ.css
│       ├── MomentsManagement-DWSvoKFH.js
│       ├── MusicManagement-Dy_24vVm.js
│       ├── MusicManagement-K23EPPhA.css
│       ├── PostEditor-03XfIqlk.js
│       ├── PostEditor-sqEZHO0k.css
│       ├── PostManagement-DyqdPIW5.js
│       ├── PostManagement-YZqQ2q3T.css
│       ├── ProfileSettings-BvpZHnkQ.js
│       ├── ProfileSettings-BwClXwu9.css
│       ├── Settings-BN1BqPfY.css
│       ├── Settings-G4BGZzq7.js
│       ├── SystemDefaultSettings-BHfiqbMO.js
│       ├── SystemDefaultSettings-wbqcD36A.css
│       ├── index.html
│       └── vite.svg
├── node_modules/                     # Node.js 依赖包
├── public/                           # 静态资源
│   ├── live2d-static-api/            # Live2D 静态资源
│   └── vite.svg                      # Vite 图标
├── src/                              # 源代码目录
│   ├── components/                   # 组件目录
│   │   ├── blogHome/                 # 博客首页组件
│   │   │   ├── About/                # 关于页面组件
│   │   │   │   └── AboutContent.vue
│   │   │   ├── Columns/              # 专栏相关组件
│   │   │   │   ├── ColumnDetail.vue
│   │   │   │   └── ColumnsContent.vue
│   │   │   ├── Header/               # 头部组件
│   │   │   │   └── BlogHeader.vue
│   │   │   ├── Home/                 # 首页内容组件
│   │   │   │   └── HomeContent.vue
│   │   │   ├── ImagePreview/         # 图片预览组件
│   │   │   │   └── ImagePreviewModal.vue
│   │   │   ├── Sidebar/              # 侧边栏组件
│   │   │   │   ├── LeftSidebar.vue
│   │   │   │   └── RightSidebar.vue
│   │   │   └── README.md             # 组件说明文档
│   │   ├── GlobalLoading.vue         # 全局加载组件
│   │   ├── HelloWorld.vue            # 示例组件
│   │   ├── MarkdownEditor.vue        # Markdown 编辑器
│   │   ├── MusicPlayer.vue           # 音乐播放器
│   │   ├── MusicUploadManager.vue    # 音乐上传管理
│   │   └── WelcomeModal.vue          # 欢迎模态框
│   ├── data/                         # 静态数据
│   │   ├── bible-verses.json         # 圣经经文数据
│   │   └── famous-quotes.json        # 名人名言数据
│   ├── pages/                        # 页面组件
│   │   ├── admin/                    # 管理后台页面
│   │   │   ├── AdminLayout.vue       # 管理后台布局
│   │   │   ├── AISettings.vue        # AI 设置
│   │   │   ├── AttachmentManagement.vue    # 附件管理
│   │   │   ├── ColumnsManagement.vue       # 专栏管理
│   │   │   ├── CommentManagement.vue       # 评论管理
│   │   │   ├── Dashboard.vue               # 仪表板
│   │   │   ├── HomepageSettings.vue        # 首页设置
│   │   │   ├── HomepageSettings_README.md  # 首页设置说明
│   │   │   ├── ImageSearchSettings.vue     # 图片搜索设置
│   │   │   ├── MomentsManagement.vue       # 动态管理
│   │   │   ├── MusicManagement.vue         # 音乐管理
│   │   │   ├── PostEditor.vue              # 文章编辑器
│   │   │   ├── PostManagement.vue          # 文章管理
│   │   │   ├── ProfileSettings.vue         # 个人资料设置
│   │   │   ├── Settings.vue                # 系统设置
│   │   │   ├── SystemDefaultSettings.vue   # 系统默认设置
│   │   │   ├── TagCloudManagement.vue      # 标签云管理
│   │   │   └── UserManagement.vue          # 用户管理
│   │   ├── ArticleList.vue           # 文章列表页
│   │   ├── BlogDetail.vue            # 博客详情页
│   │   ├── BlogHome.vue              # 博客首页
│   │   ├── CookieTest.vue            # Cookie 测试页
│   │   ├── FullscreenTest.vue        # 全屏测试页
│   │   ├── Home.vue                  # 首页
│   │   ├── LoadingTest.vue           # 加载测试页
│   │   ├── Login.vue                 # 登录页
│   │   ├── NotFound.vue              # 404 页面
│   │   ├── NotFoundDemo.vue          # 404 演示页
│   │   ├── Test404.vue               # 404 测试页
│   │   └── TestViewUI.vue            # ViewUI 测试页
│   ├── router/                       # 路由配置
│   │   └── index.js                  # 路由定义
│   ├── App.vue                       # 根组件
│   ├── main.js                       # 应用入口
│   └── style.css                     # 全局样式
├── assets/                           # 静态资源
│   └── vue.svg                       # Vue 图标
├── index.html                        # HTML 模板
├── package.json                      # 项目依赖
├── package-lock.json                 # 依赖锁定文件
├── vite.config.js                    # Vite 配置
├── eslint.config.js                  # ESLint 配置
└── README.md                         # 前端说明文档
```

## 🐳 Docker 配置

```
nginx/                                # Nginx 配置目录
└── ssl/                              # SSL 证书目录

uploads/                              # 根目录上传文件
└── images/                           # 图片文件
    ├── 20251002_202950_bd8d1fea.jpg
    └── 20251002_203026_cc050876.jpg
```

## 📋 配置文件说明

### 后端配置文件
- `backend/config/config.yaml` - 主配置文件
- `backend/requirements.txt` - Python 依赖
- `backend/Dockerfile` - 后端容器配置

### 前端配置文件
- `frontend/package.json` - 项目依赖和脚本
- `frontend/vite.config.js` - 构建工具配置
- `frontend/eslint.config.js` - ESLint 配置
- `frontend/README.md` - 前端说明文档

### 部署配置文件
- `docker-compose.yml` - Docker Compose 配置
- `nginx/` - Nginx 配置目录

### 文档文件
- `LIVE2D_WIDGET_README.md` - Live2D 看板娘说明
- `music-player-integration.md` - 音乐播放器集成说明
- `SCROLLBAR_FIX.md` - 滚动条修复说明
- `readme.md` - 项目说明文档

## 🔧 主要功能模块

### 后端 API 模块
- **认证系统** - 用户登录、注册、权限管理
- **文章管理** - 文章的增删改查、发布状态管理
- **评论系统** - 评论的增删改查、审核功能
- **附件管理** - 文件上传、图片管理、音乐管理
- **专栏管理** - 专栏的创建和管理
- **动态管理** - 说说/动态的发布和管理
- **系统设置** - 网站配置、主题设置
- **统计数据** - 访问统计、文章统计
- **标签云** - 标签的自动生成和管理
- **图片搜索** - 集成图片搜索 API
- **音乐功能** - 音乐播放和管理

### 前端页面模块
- **博客首页** - 文章展示、侧边栏、导航
- **文章详情** - 文章内容、评论、相关文章
- **管理后台** - 完整的后台管理系统
- **用户认证** - 登录、注册、权限控制
- **响应式设计** - 适配各种设备尺寸
- **Live2D 看板娘** - 虚拟助手功能
- **音乐播放器** - 音乐播放和管理
- **图片预览** - 图片查看和预览功能

## 🚀 部署架构

```
用户请求 → Nginx → 静态文件 (前端)
                    ↓
                API 请求 → FastAPI (后端)
                    ↓
                数据库请求 → MySQL
```

## 📊 技术栈

### 后端技术
- **FastAPI** - Web 框架
- **SQLModel** - ORM 框架
- **MySQL** - 数据库
- **Uvicorn** - ASGI 服务器
- **Python 3.11** - 编程语言

### 前端技术
- **Vue 3** - 前端框架
- **Vite** - 构建工具
- **Axios** - HTTP 客户端
- **Element Plus** - UI 组件库
- **Node.js 20** - 运行环境

### 部署技术
- **Docker** - 容器化
- **Docker Compose** - 容器编排
- **Nginx** - 反向代理

## 📝 特殊功能说明

### Live2D 看板娘
- 集成在 `frontend/index.html` 中
- 使用 CDN 方式加载
- 支持自定义配置和交互

### 音乐播放器
- 支持本地音乐上传和管理
- 集成音乐 API 搜索功能
- 提供音乐播放器组件

### 图片搜索
- 集成图片搜索 API
- 支持标签搜索和随机图片
- 提供图片管理功能

### 数据存储
- 静态数据存储在 `frontend/src/data/` 目录
- 包含圣经经文和名人名言数据
- 支持 JSON 格式的数据文件
