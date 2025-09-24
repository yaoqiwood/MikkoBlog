-- 系统默认参数表（简化版）
CREATE TABLE IF NOT EXISTS system_defaults (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50) NOT NULL COMMENT '参数分类',
    key_name VARCHAR(100) NOT NULL COMMENT '参数键名',
    key_value TEXT COMMENT '参数值',
    description VARCHAR(255) COMMENT '参数描述',
    data_type ENUM('string', 'number', 'boolean', 'json', 'url') DEFAULT 'string' COMMENT '数据类型',
    is_editable BOOLEAN DEFAULT TRUE COMMENT '是否可编辑',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开（前端可访问）',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_category_key (category, key_name)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 插入默认数据
INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order) VALUES
-- 用户相关默认值
('user', 'default_avatar', 'https://via.placeholder.com/150x150/87ceeb/ffffff?text=Avatar', '默认用户头像', 'url', TRUE, TRUE, 1),
('user', 'default_nickname', '匿名用户', '默认用户昵称', 'string', TRUE, TRUE, 2),
('user', 'default_bio', '这个人很懒，什么都没有留下...', '默认个人简介', 'string', TRUE, TRUE, 3),

-- 博客相关默认值
('blog', 'default_title', 'MikkoBlog', '默认博客标题', 'string', TRUE, TRUE, 1),
('blog', 'default_subtitle', '一个简洁优雅的博客系统', '默认博客副标题', 'string', TRUE, TRUE, 2),
('blog', 'default_motto', 'Stay hungry, stay foolish', '默认个人格言', 'string', TRUE, TRUE, 3),
('blog', 'default_theme', 'anime', '默认主题', 'string', TRUE, TRUE, 4),
('blog', 'posts_per_page', '10', '每页显示文章数', 'number', TRUE, TRUE, 5),
('blog', 'enable_comments', 'true', '是否启用评论', 'boolean', TRUE, TRUE, 6),

-- 系统配置
('system', 'site_name', 'MikkoBlog', '网站名称', 'string', TRUE, TRUE, 1),
('system', 'site_description', '一个基于Vue3和FastAPI的现代化博客系统', '网站描述', 'string', TRUE, TRUE, 2),
('system', 'site_keywords', '博客,技术,编程,Vue3,FastAPI', '网站关键词', 'string', TRUE, TRUE, 3),
('system', 'admin_email', 'admin@example.com', '管理员邮箱', 'string', TRUE, FALSE, 4),
('system', 'maintenance_mode', 'false', '维护模式', 'boolean', TRUE, TRUE, 5),

-- 上传相关
('upload', 'max_file_size', '5242880', '最大文件大小（字节）', 'number', TRUE, FALSE, 1),
('upload', 'allowed_image_types', 'jpg,jpeg,png,gif,webp', '允许的图片类型', 'string', TRUE, FALSE, 2),
('upload', 'upload_path', '/uploads', '上传路径', 'string', TRUE, FALSE, 3),
('upload', 'avatar_path', '/uploads/avatars', '头像上传路径', 'string', TRUE, FALSE, 4),

-- 社交链接默认值
('social', 'github_url', '', 'GitHub链接', 'url', TRUE, TRUE, 1),
('social', 'twitter_url', '', 'Twitter链接', 'url', TRUE, TRUE, 2),
('social', 'weibo_url', '', '微博链接', 'url', TRUE, TRUE, 3),
('social', 'website_url', '', '个人网站链接', 'url', TRUE, TRUE, 4),

-- 前端配置
('frontend', 'loading_text', '加载中...', '加载提示文字', 'string', TRUE, TRUE, 1),
('frontend', 'no_more_data_text', '没有更多内容了', '无更多数据提示', 'string', TRUE, TRUE, 2),
('frontend', 'error_404_title', '页面未找到', '404错误标题', 'string', TRUE, TRUE, 3),
('frontend', 'error_404_message', '抱歉，您访问的页面不存在', '404错误信息', 'string', TRUE, TRUE, 4);
