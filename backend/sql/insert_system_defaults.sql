-- 插入系统默认参数数据
INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order, created_at, updated_at) VALUES
-- 用户相关默认值
('user', 'default_avatar', 'https://via.placeholder.com/150x150/87ceeb/ffffff?text=Avatar', '默认用户头像', 'url', TRUE, TRUE, 1, NOW(), NOW()),
('user', 'default_nickname', '匿名用户', '默认用户昵称', 'string', TRUE, TRUE, 2, NOW(), NOW()),
('user', 'default_bio', '这个人很懒，什么都没有留下...', '默认个人简介', 'string', TRUE, TRUE, 3, NOW(), NOW()),

-- 博客相关默认值
('blog', 'default_title', 'MikkoBlog', '默认博客标题', 'string', TRUE, TRUE, 1, NOW(), NOW()),
('blog', 'default_subtitle', '一个简洁优雅的博客系统', '默认博客副标题', 'string', TRUE, TRUE, 2, NOW(), NOW()),
('blog', 'default_motto', 'Stay hungry, stay foolish', '默认个人格言', 'string', TRUE, TRUE, 3, NOW(), NOW()),
('blog', 'default_theme', 'anime', '默认主题', 'string', TRUE, TRUE, 4, NOW(), NOW()),
('blog', 'posts_per_page', '10', '每页显示文章数', 'number', TRUE, TRUE, 5, NOW(), NOW()),
('blog', 'enable_comments', 'true', '是否启用评论', 'boolean', TRUE, TRUE, 6, NOW(), NOW()),

-- 系统配置
('system', 'site_name', 'MikkoBlog', '网站名称', 'string', TRUE, TRUE, 1, NOW(), NOW()),
('system', 'site_description', '一个基于Vue3和FastAPI的现代化博客系统', '网站描述', 'string', TRUE, TRUE, 2, NOW(), NOW()),
('system', 'site_keywords', '博客,技术,编程,Vue3,FastAPI', '网站关键词', 'string', TRUE, TRUE, 3, NOW(), NOW()),
('system', 'admin_email', 'admin@example.com', '管理员邮箱', 'string', TRUE, FALSE, 4, NOW(), NOW()),
('system', 'maintenance_mode', 'false', '维护模式', 'boolean', TRUE, TRUE, 5, NOW(), NOW()),

-- 上传相关
('upload', 'max_file_size', '5242880', '最大文件大小（字节）', 'number', TRUE, FALSE, 1, NOW(), NOW()),
('upload', 'allowed_image_types', 'jpg,jpeg,png,gif,webp', '允许的图片类型', 'string', TRUE, FALSE, 2, NOW(), NOW()),
('upload', 'upload_path', '/uploads', '上传路径', 'string', TRUE, FALSE, 3, NOW(), NOW()),
('upload', 'avatar_path', '/uploads/avatars', '头像上传路径', 'string', TRUE, FALSE, 4, NOW(), NOW()),

-- 社交链接默认值
('social', 'github_url', '', 'GitHub链接', 'url', TRUE, TRUE, 1, NOW(), NOW()),
('social', 'twitter_url', '', 'Twitter链接', 'url', TRUE, TRUE, 2, NOW(), NOW()),
('social', 'weibo_url', '', '微博链接', 'url', TRUE, TRUE, 3, NOW(), NOW()),
('social', 'website_url', '', '个人网站链接', 'url', TRUE, TRUE, 4, NOW(), NOW()),

-- 邮件配置
('email', 'smtp_host', '', 'SMTP服务器', 'string', TRUE, FALSE, 1, NOW(), NOW()),
('email', 'smtp_port', '587', 'SMTP端口', 'number', TRUE, FALSE, 2, NOW(), NOW()),
('email', 'smtp_username', '', 'SMTP用户名', 'string', TRUE, FALSE, 3, NOW(), NOW()),
('email', 'smtp_password', '', 'SMTP密码', 'string', TRUE, FALSE, 4, NOW(), NOW()),
('email', 'from_email', 'noreply@mikkoblog.com', '发件人邮箱', 'string', TRUE, FALSE, 5, NOW(), NOW()),

-- 缓存配置
('cache', 'redis_host', 'localhost', 'Redis主机', 'string', TRUE, FALSE, 1, NOW(), NOW()),
('cache', 'redis_port', '6379', 'Redis端口', 'number', TRUE, FALSE, 2, NOW(), NOW()),
('cache', 'cache_ttl', '3600', '缓存过期时间（秒）', 'number', TRUE, FALSE, 3, NOW(), NOW()),

-- 安全配置
('security', 'jwt_secret', 'your-secret-key', 'JWT密钥', 'string', TRUE, FALSE, 1, NOW(), NOW()),
('security', 'jwt_expires_minutes', '1440', 'JWT过期时间（分钟）', 'number', TRUE, FALSE, 2, NOW(), NOW()),
('security', 'password_min_length', '8', '密码最小长度', 'number', TRUE, TRUE, 3, NOW(), NOW()),
('security', 'max_login_attempts', '5', '最大登录尝试次数', 'number', TRUE, FALSE, 4, NOW(), NOW()),

-- 前端配置
('frontend', 'loading_text', '加载中...', '加载提示文字', 'string', TRUE, TRUE, 1, NOW(), NOW()),
('frontend', 'no_more_data_text', '没有更多内容了', '无更多数据提示', 'string', TRUE, TRUE, 2, NOW(), NOW()),
('frontend', 'error_404_title', '页面未找到', '404错误标题', 'string', TRUE, TRUE, 3, NOW(), NOW()),
('frontend', 'error_404_message', '抱歉，您访问的页面不存在', '404错误信息', 'string', TRUE, TRUE, 4, NOW(), NOW()),

-- 统计配置
('analytics', 'enable_analytics', 'false', '是否启用统计', 'boolean', TRUE, TRUE, 1, NOW(), NOW()),
('analytics', 'google_analytics_id', '', 'Google Analytics ID', 'string', TRUE, TRUE, 2, NOW(), NOW()),
('analytics', 'baidu_analytics_id', '', '百度统计ID', 'string', TRUE, TRUE, 3, NOW(), NOW());
