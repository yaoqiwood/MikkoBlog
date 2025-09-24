-- 附件表（主要用于存储图片信息和访问链接）
CREATE TABLE IF NOT EXISTS attachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    filename VARCHAR(255) NOT NULL COMMENT '原始文件名',
    original_name VARCHAR(255) NOT NULL COMMENT '原始文件名（包含扩展名）',
    file_path VARCHAR(500) NOT NULL COMMENT '文件存储路径',
    file_url VARCHAR(500) NOT NULL COMMENT '文件访问URL',
    file_size BIGINT NOT NULL COMMENT '文件大小（字节）',
    file_type VARCHAR(100) NOT NULL COMMENT '文件类型（MIME类型）',
    file_extension VARCHAR(20) NOT NULL COMMENT '文件扩展名',
    file_category ENUM('image', 'document', 'video', 'audio', 'other') DEFAULT 'image' COMMENT '文件分类',
    width INT NULL COMMENT '图片宽度（仅图片文件）',
    height INT NULL COMMENT '图片高度（仅图片文件）',
    alt_text VARCHAR(255) NULL COMMENT '图片替代文本',
    title VARCHAR(255) NULL COMMENT '文件标题',
    description TEXT NULL COMMENT '文件描述',
    tags VARCHAR(500) NULL COMMENT '标签（逗号分隔）',
    is_public BOOLEAN DEFAULT TRUE COMMENT '是否公开访问',
    is_featured BOOLEAN DEFAULT FALSE COMMENT '是否为精选文件',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    view_count INT DEFAULT 0 COMMENT '查看次数',
    uploaded_by INT NOT NULL COMMENT '上传者ID',
    related_type VARCHAR(50) NULL COMMENT '关联类型（如：post, user, comment等）',
    related_id INT NULL COMMENT '关联ID',
    status ENUM('active', 'deleted', 'hidden') DEFAULT 'active' COMMENT '文件状态',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL COMMENT '删除时间',
    INDEX idx_uploaded_by (uploaded_by),
    INDEX idx_file_category (file_category),
    INDEX idx_status (status),
    INDEX idx_related (related_type, related_id),
    INDEX idx_created_at (created_at),
    INDEX idx_file_type (file_type),
    FOREIGN KEY (uploaded_by) REFERENCES user(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 插入示例数据
INSERT INTO attachments (filename, original_name, file_path, file_url, file_size, file_type, file_extension, file_category, width, height, alt_text, title, description, tags, is_public, is_featured, uploaded_by, related_type, related_id) VALUES
('avatar_001', 'avatar_001.jpg', '/uploads/avatars/avatar_001.jpg', '/uploads/avatars/avatar_001.jpg', 45678, 'image/jpeg', 'jpg', 'image', 150, 150, '用户头像', '默认用户头像', '系统默认用户头像', 'avatar,default,user', TRUE, FALSE, 1, 'user', 1),
('blog_banner_001', 'blog_banner_001.png', '/uploads/images/blog_banner_001.png', '/uploads/images/blog_banner_001.png', 123456, 'image/png', 'png', 'image', 1200, 400, '博客横幅图片', '博客首页横幅', '博客首页使用的横幅图片', 'banner,blog,homepage', TRUE, TRUE, 1, 'post', NULL),
('post_cover_001', 'post_cover_001.jpg', '/uploads/images/post_cover_001.jpg', '/uploads/images/post_cover_001.jpg', 234567, 'image/jpeg', 'jpg', 'image', 800, 600, '文章封面图', '技术文章封面', '一篇关于Vue3的技术文章封面图', 'cover,post,vue3,tech', TRUE, FALSE, 1, 'post', 1),
('logo_001', 'logo_001.png', '/uploads/images/logo_001.png', '/uploads/images/logo_001.png', 34567, 'image/png', 'png', 'image', 200, 200, '网站Logo', 'MikkoBlog Logo', '网站主Logo图片', 'logo,brand,website', TRUE, TRUE, 1, 'system', NULL),
('icon_001', 'icon_001.ico', '/uploads/images/icon_001.ico', '/uploads/images/icon_001.ico', 12345, 'image/x-icon', 'ico', 'image', 32, 32, '网站图标', '网站Favicon', '浏览器标签页图标', 'icon,favicon,website', TRUE, FALSE, 1, 'system', NULL);
