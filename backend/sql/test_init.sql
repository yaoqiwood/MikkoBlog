-- 用户表
-- 基于 SQLModel 的 User 模型创建

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `email` varchar(255) NOT NULL COMMENT '邮箱地址',
  `full_name` varchar(100) DEFAULT NULL COMMENT '全名',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否激活',
  `is_admin` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否管理员',
  `hashed_password` varchar(255) NOT NULL COMMENT '加密后的密码',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_admin` (`is_admin`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入默认管理员用户
INSERT INTO `users` (
  `email`,
  `full_name`,
  `is_active`,
  `is_admin`,
  `hashed_password`
) VALUES (
  'admin@mikko.blog',
  'Mikko Admin',
  1,
  1,
  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4j.8.1Z3.G'  -- 密码: admin123
) ON DUPLICATE KEY UPDATE
  `email` = VALUES(`email`),
  `full_name` = VALUES(`full_name`),
  `is_active` = VALUES(`is_active`),
  `is_admin` = VALUES(`is_admin`);
CREATE TABLE IF NOT EXISTS system_defaults (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50) NOT NULL,
    key_name VARCHAR(100) NOT NULL,
    key_value TEXT,
    description VARCHAR(255),
    data_type ENUM('string', 'number', 'boolean', 'json', 'url') DEFAULT 'string',
    is_editable BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_category_key (category, key_name)
);
-- 用户个人信息表
-- 用于存储博客用户的个人资料和对外展示信息

CREATE TABLE IF NOT EXISTS `user_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int(11) NOT NULL COMMENT '关联用户ID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱地址',
  `bio` text DEFAULT NULL COMMENT '个人简介',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `blog_title` varchar(100) DEFAULT NULL COMMENT '博客标题',
  `blog_subtitle` varchar(200) DEFAULT NULL COMMENT '博客副标题',
  `motto` varchar(200) DEFAULT NULL COMMENT '个人格言',
  `github_url` varchar(255) DEFAULT NULL COMMENT 'GitHub链接',
  `twitter_url` varchar(255) DEFAULT NULL COMMENT 'Twitter链接',
  `weibo_url` varchar(255) DEFAULT NULL COMMENT '微博链接',
  `website_url` varchar(255) DEFAULT NULL COMMENT '个人网站链接',
  `qq_number` varchar(20) DEFAULT NULL COMMENT 'QQ号码',
  `location` varchar(100) DEFAULT NULL COMMENT '所在地',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `gender` enum('male','female','other','private') DEFAULT 'private' COMMENT '性别',
  `is_public` tinyint(1) DEFAULT 1 COMMENT '是否公开个人信息',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_nickname` (`nickname`),
  KEY `idx_email` (`email`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_user_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户个人信息表';

-- 插入默认管理员个人信息
INSERT INTO `user_profiles` (
  `user_id`,
  `nickname`,
  `email`,
  `bio`,
  `avatar`,
  `blog_title`,
  `blog_subtitle`,
  `motto`,
  `github_url`,
  `qq_number`,
  `is_public`
) VALUES (
  1,
  'Suyeq',
  'admin@example.com',
  '热爱技术，喜欢分享。专注于前端开发和用户体验设计。',
  'https://via.placeholder.com/150x150/87ceeb/ffffff?text=S',
  '阑珊处',
  '技术分享与生活感悟',
  '一杯敬明天,一杯敬过往',
  'https://github.com/Suyeq233',
  '473721601',
  1
) ON DUPLICATE KEY UPDATE
  `nickname` = VALUES(`nickname`),
  `email` = VALUES(`email`),
  `bio` = VALUES(`bio`),
  `avatar` = VALUES(`avatar`),
  `blog_title` = VALUES(`blog_title`),
  `blog_subtitle` = VALUES(`blog_subtitle`),
  `motto` = VALUES(`motto`),
  `github_url` = VALUES(`github_url`),
  `qq_number` = VALUES(`qq_number`),
  `updated_at` = CURRENT_TIMESTAMP;

-- 创建用户统计信息表（可选，用于存储用户的各种统计数据）
CREATE TABLE IF NOT EXISTS `user_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `total_posts` int(11) DEFAULT 0 COMMENT '总文章数',
  `total_comments` int(11) DEFAULT 0 COMMENT '总评论数',
  `total_views` int(11) DEFAULT 0 COMMENT '总浏览量',
  `total_likes` int(11) DEFAULT 0 COMMENT '总点赞数',
  `followers_count` int(11) DEFAULT 0 COMMENT '粉丝数',
  `following_count` int(11) DEFAULT 0 COMMENT '关注数',
  `last_login_at` timestamp NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_active_at` timestamp NULL DEFAULT NULL COMMENT '最后活跃时间',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_total_posts` (`total_posts`),
  KEY `idx_total_views` (`total_views`),
  KEY `idx_last_active` (`last_active_at`),
  CONSTRAINT `fk_user_statistics_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户统计信息表';

-- 插入默认管理员统计信息
INSERT INTO `user_statistics` (
  `user_id`,
  `total_posts`,
  `total_comments`,
  `total_views`,
  `total_likes`,
  `followers_count`,
  `following_count`
) VALUES (
  1,
  14,
  37,
  1250,
  89,
  156,
  23
) ON DUPLICATE KEY UPDATE
  `total_posts` = VALUES(`total_posts`),
  `total_comments` = VALUES(`total_comments`),
  `total_views` = VALUES(`total_views`),
  `total_likes` = VALUES(`total_likes`),
  `followers_count` = VALUES(`followers_count`),
  `following_count` = VALUES(`following_count`),
  `updated_at` = CURRENT_TIMESTAMP;

-- 创建用户设置表（可选，用于存储用户的个性化设置）
CREATE TABLE IF NOT EXISTS `user_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `theme` enum('light','dark','auto') DEFAULT 'light' COMMENT '主题设置',
  `language` varchar(10) DEFAULT 'zh-CN' COMMENT '语言设置',
  `timezone` varchar(50) DEFAULT 'Asia/Shanghai' COMMENT '时区设置',
  `email_notifications` tinyint(1) DEFAULT 1 COMMENT '邮件通知',
  `comment_notifications` tinyint(1) DEFAULT 1 COMMENT '评论通知',
  `like_notifications` tinyint(1) DEFAULT 1 COMMENT '点赞通知',
  `follow_notifications` tinyint(1) DEFAULT 1 COMMENT '关注通知',
  `privacy_level` enum('public','friends','private') DEFAULT 'public' COMMENT '隐私级别',
  `allow_comments` tinyint(1) DEFAULT 1 COMMENT '允许评论',
  `allow_guest_comments` tinyint(1) DEFAULT 1 COMMENT '允许游客评论',
  `comment_moderation` tinyint(1) DEFAULT 0 COMMENT '评论审核',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  CONSTRAINT `fk_user_settings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户设置表';

-- 插入默认管理员设置
INSERT INTO `user_settings` (
  `user_id`,
  `theme`,
  `language`,
  `timezone`,
  `email_notifications`,
  `comment_notifications`,
  `like_notifications`,
  `follow_notifications`,
  `privacy_level`,
  `allow_comments`,
  `allow_guest_comments`,
  `comment_moderation`
) VALUES (
  1,
  'light',
  'zh-CN',
  'Asia/Shanghai',
  1,
  1,
  1,
  1,
  'public',
  1,
  1,
  0
) ON DUPLICATE KEY UPDATE
  `theme` = VALUES(`theme`),
  `language` = VALUES(`language`),
  `timezone` = VALUES(`timezone`),
  `email_notifications` = VALUES(`email_notifications`),
  `comment_notifications` = VALUES(`comment_notifications`),
  `like_notifications` = VALUES(`like_notifications`),
  `follow_notifications` = VALUES(`follow_notifications`),
  `privacy_level` = VALUES(`privacy_level`),
  `allow_comments` = VALUES(`allow_comments`),
  `allow_guest_comments` = VALUES(`allow_guest_comments`),
  `comment_moderation` = VALUES(`comment_moderation`),
  `updated_at` = CURRENT_TIMESTAMP;
-- 首页设置表
CREATE TABLE IF NOT EXISTS home_page_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    header_title VARCHAR(255) DEFAULT NULL,
    banner_image_url TEXT,
    background_image_url TEXT,
    show_music_player INTEGER DEFAULT 0,
    music_url TEXT,
    show_live2d INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 博主专栏表
CREATE TABLE `columns` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '专栏ID',
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '专栏名称',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '专栏描述',
  `cover_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '专栏封面图片URL',
  `sort_order` int DEFAULT '0' COMMENT '排序顺序，数字越小越靠前',
  `is_visible` tinyint(1) DEFAULT '1' COMMENT '是否可见 1:可见 0:隐藏',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否已删除 1:已删除 0:未删除',
  `user_id` int NOT NULL COMMENT '创建者用户ID',
  `post_count` int DEFAULT '0' COMMENT '专栏文章数量（冗余字段，便于查询）',
  `view_count` int DEFAULT '0' COMMENT '专栏浏览量',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_is_visible` (`is_visible`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_columns_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='博主专栏表';

-- 文章专栏关联表
CREATE TABLE `post_columns` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `post_id` int NOT NULL COMMENT '文章ID',
  `column_id` int NOT NULL COMMENT '专栏ID',
  `sort_order` int DEFAULT '0' COMMENT '在专栏中的排序顺序',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_column` (`post_id`, `column_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_column_id` (`column_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_post_columns_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_post_columns_column_id` FOREIGN KEY (`column_id`) REFERENCES `columns` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章专栏关联表';

-- 插入一些示例数据
INSERT INTO `columns` (`name`, `description`, `cover_image_url`, `sort_order`, `user_id`) VALUES
('Redis源码分析', 'Redis核心源码深度解析，从数据结构到网络模型', '/uploads/images/redis-cover.jpg', 1, 1),
('Java源码分析', 'Java核心类库源码解读，深入理解JVM原理', '/uploads/images/java-cover.jpg', 2, 1),
('Tomcat源码', 'Tomcat服务器源码分析，Web容器实现原理', '/uploads/images/tomcat-cover.jpg', 3, 1),
('前端技术栈', '现代前端开发技术分享，Vue、React、TypeScript等', '/uploads/images/frontend-cover.jpg', 4, 1),
('系统设计', '大型系统架构设计经验分享', '/uploads/images/system-design-cover.jpg', 5, 1);
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
    download_count INT NOT NULL DEFAULT 0 COMMENT '下载次数',
    view_count INT NOT NULL DEFAULT 0 COMMENT '查看次数',
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
-- 本地音乐管理表结构
-- 创建时间: 2025-10-07
-- 注意：执行前请先设置字符集：SET NAMES utf8mb4;

-- 1. 本地音乐文件表
CREATE TABLE `local_music` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL COMMENT '歌曲标题',
  `artist` varchar(255) NOT NULL COMMENT '艺术家',
  `album` varchar(255) DEFAULT NULL COMMENT '专辑名称',
  `duration` int DEFAULT NULL COMMENT '时长(秒)',
  `file_path` varchar(500) NOT NULL COMMENT '文件路径',
  `file_size` bigint DEFAULT NULL COMMENT '文件大小(字节)',
  `file_format` varchar(10) DEFAULT NULL COMMENT '文件格式(mp3,wav,ogg等)',
  `cover_image_url` varchar(500) DEFAULT NULL COMMENT '封面图片URL',
  `lyrics` text COMMENT '歌词',
  `genre` varchar(100) DEFAULT NULL COMMENT '音乐类型',
  `year` int DEFAULT NULL COMMENT '发行年份',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `upload_user_id` int NOT NULL COMMENT '上传用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artist` (`artist`),
  KEY `idx_genre` (`genre`),
  KEY `idx_upload_user` (`upload_user_id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='本地音乐文件表';

-- 2. 音乐播放列表表（重新设计）
CREATE TABLE `music_playlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '播放列表名称',
  `description` text COMMENT '播放列表描述',
  `cover_image_url` varchar(500) DEFAULT NULL COMMENT '封面图片URL',
  `is_public` tinyint(1) DEFAULT '1' COMMENT '是否公开',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `user_id` int NOT NULL COMMENT '创建用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐播放列表表';

-- 3. 播放列表-音乐关联表
CREATE TABLE `playlist_music` (
  `id` int NOT NULL AUTO_INCREMENT,
  `playlist_id` int NOT NULL COMMENT '播放列表ID',
  `music_id` int NOT NULL COMMENT '音乐ID',
  `position` int NOT NULL DEFAULT '0' COMMENT '在播放列表中的位置',
  `added_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加到播放列表的时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_playlist_music` (`playlist_id`, `music_id`),
  KEY `idx_playlist_id` (`playlist_id`),
  KEY `idx_music_id` (`music_id`),
  KEY `idx_position` (`position`),
  CONSTRAINT `fk_playlist_music_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `music_playlist` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_playlist_music_music` FOREIGN KEY (`music_id`) REFERENCES `local_music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='播放列表-音乐关联表';

-- 4. 音乐播放历史表
CREATE TABLE `music_play_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `music_id` int NOT NULL COMMENT '音乐ID',
  `playlist_id` int DEFAULT NULL COMMENT '播放列表ID',
  `played_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '播放时间',
  `duration_played` int DEFAULT NULL COMMENT '播放时长(秒)',
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否完整播放',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_music_id` (`music_id`),
  KEY `idx_played_at` (`played_at`),
  CONSTRAINT `fk_play_history_music` FOREIGN KEY (`music_id`) REFERENCES `local_music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐播放历史表';

-- 5. 音乐收藏表
CREATE TABLE `music_favorite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `music_id` int NOT NULL COMMENT '音乐ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_music` (`user_id`, `music_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_music_id` (`music_id`),
  CONSTRAINT `fk_favorite_music` FOREIGN KEY (`music_id`) REFERENCES `local_music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐收藏表';

-- 插入默认播放列表
INSERT INTO `music_playlist` (`name`, `description`, `is_public`, `user_id`) VALUES
('我的音乐', '默认播放列表', 1, 1),
('收藏音乐', '我喜欢的音乐', 1, 1),
('最近播放', '最近播放的音乐', 1, 1);
-- 音乐播放列表相关表结构
-- 创建时间: 2025-10-07
-- 注意：执行前请先设置字符集：SET NAMES utf8mb4;

-- 1. 音乐播放列表表
CREATE TABLE `music_playlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '播放列表名称',
  `description` text COMMENT '播放列表描述',
  `cover_image_url` varchar(500) DEFAULT NULL COMMENT '封面图片URL',
  `is_public` tinyint(1) DEFAULT '1' COMMENT '是否公开',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `user_id` int NOT NULL COMMENT '创建用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐播放列表表';

-- 2. 音乐曲目表
CREATE TABLE `music_track` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL COMMENT '歌曲标题',
  `artist` varchar(255) NOT NULL COMMENT '艺术家',
  `album` varchar(255) DEFAULT NULL COMMENT '专辑名称',
  `duration` int DEFAULT NULL COMMENT '时长(秒)',
  `file_url` varchar(500) DEFAULT NULL COMMENT '音频文件URL',
  `stream_url` varchar(500) DEFAULT NULL COMMENT '流媒体URL',
  `cover_image_url` varchar(500) DEFAULT NULL COMMENT '封面图片URL',
  `lyrics` text COMMENT '歌词',
  `genre` varchar(100) DEFAULT NULL COMMENT '音乐类型',
  `year` int DEFAULT NULL COMMENT '发行年份',
  `external_id` varchar(100) DEFAULT NULL COMMENT '外部平台ID(如网易云、QQ音乐等)',
  `platform` varchar(50) DEFAULT NULL COMMENT '来源平台',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artist` (`artist`),
  KEY `idx_genre` (`genre`),
  KEY `idx_external_id` (`external_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐曲目表';

-- 3. 播放列表-曲目关联表
CREATE TABLE `playlist_track` (
  `id` int NOT NULL AUTO_INCREMENT,
  `playlist_id` int NOT NULL COMMENT '播放列表ID',
  `track_id` int NOT NULL COMMENT '曲目ID',
  `position` int NOT NULL DEFAULT '0' COMMENT '在播放列表中的位置',
  `added_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加到播放列表的时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_playlist_track` (`playlist_id`, `track_id`),
  KEY `idx_playlist_id` (`playlist_id`),
  KEY `idx_track_id` (`track_id`),
  KEY `idx_position` (`position`),
  CONSTRAINT `fk_playlist_track_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `music_playlist` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_playlist_track_track` FOREIGN KEY (`track_id`) REFERENCES `music_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='播放列表-曲目关联表';

-- 4. 音乐播放历史表
CREATE TABLE `music_play_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `track_id` int NOT NULL COMMENT '曲目ID',
  `playlist_id` int DEFAULT NULL COMMENT '播放列表ID',
  `played_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '播放时间',
  `duration_played` int DEFAULT NULL COMMENT '播放时长(秒)',
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否完整播放',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_track_id` (`track_id`),
  KEY `idx_played_at` (`played_at`),
  CONSTRAINT `fk_play_history_track` FOREIGN KEY (`track_id`) REFERENCES `music_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐播放历史表';

-- 5. 音乐收藏表
CREATE TABLE `music_favorite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `track_id` int NOT NULL COMMENT '曲目ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_track` (`user_id`, `track_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_track_id` (`track_id`),
  CONSTRAINT `fk_favorite_track` FOREIGN KEY (`track_id`) REFERENCES `music_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐收藏表';

-- 插入默认播放列表
INSERT INTO `music_playlist` (`name`, `description`, `is_public`, `user_id`) VALUES
('默认播放列表', '系统默认播放列表', 1, 1),
('我的收藏', '收藏的音乐', 1, 1),
('最近播放', '最近播放的音乐', 1, 1);

-- 插入一些示例音乐数据（使用公开的音乐资源）
INSERT INTO `music_track` (`title`, `artist`, `album`, `duration`, `file_url`, `cover_image_url`, `genre`, `year`, `platform`) VALUES
('風の住む街', '磯村由纪子', '風の住む街', 285, 'https://music.163.com/song/media/outer/url?id=123456', 'https://p1.music.126.net/example.jpg', 'New Age', 2003, 'netease'),
('ヨスガノソラメインテーマ', '記', 'ヨスガノソラ', 180, 'https://music.163.com/song/media/outer/url?id=123457', 'https://p1.music.126.net/example2.jpg', 'Anime', 2010, 'netease'),
('蝶恋', '仙剑奇侠传', '仙剑奇侠传原声带', 240, 'https://music.163.com/song/media/outer/url?id=123458', 'https://p1.music.126.net/example3.jpg', 'Game Music', 2005, 'netease'),
('月光の雲海', '久石让', '天空之城', 200, 'https://music.163.com/song/media/outer/url?id=123459', 'https://p1.music.126.net/example4.jpg', 'Film Score', 1986, 'netease');
-- 说说表（类似朋友圈动态）
CREATE TABLE IF NOT EXISTS `moments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '发布用户ID',
  `content` varchar(150) NOT NULL COMMENT '说说内容，最多150字',
  `is_visible` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否可见',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_visible_deleted` (`is_visible`, `is_deleted`),
  CONSTRAINT `fk_moments_user_id` FOREIGN KEY (`user_id`) REFERENCES `user_profiles` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='说说动态表';

-- 说说图片关联表
CREATE TABLE IF NOT EXISTS `moments_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `moment_id` int NOT NULL COMMENT '说说ID',
  `attachment_id` int NOT NULL COMMENT '图片附件ID',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '图片排序',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_moment_attachment` (`moment_id`, `attachment_id`),
  KEY `idx_moment_id` (`moment_id`),
  KEY `idx_attachment_id` (`attachment_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_moments_images_moment_id` FOREIGN KEY (`moment_id`) REFERENCES `moments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_moments_images_attachment_id` FOREIGN KEY (`attachment_id`) REFERENCES `attachments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='说说图片关联表';
-- 创建 post_stats 表
CREATE TABLE `post_stats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `view_count` int NOT NULL DEFAULT '0' COMMENT '观看次数',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞次数',
  `share_count` int NOT NULL DEFAULT '0' COMMENT '分享次数',
  `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论次数',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `post_id` (`post_id`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_share_count` (`share_count`),
  KEY `idx_comment_count` (`comment_count`),
  CONSTRAINT `fk_post_stats_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章统计数据表';

-- 标签云表
CREATE TABLE IF NOT EXISTS tag_cloud (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '标签名称',
    count INT DEFAULT 1 COMMENT '使用次数',
    size VARCHAR(20) DEFAULT 'medium' COMMENT '标签大小: small, medium, large',
    color VARCHAR(20) DEFAULT '#ff6b6b' COMMENT '标签颜色',
    category VARCHAR(50) DEFAULT 'general' COMMENT '标签分类',
    source VARCHAR(50) DEFAULT 'manual' COMMENT '来源: manual, auto, trending',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否激活',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    last_fetched_at TIMESTAMP NULL COMMENT '最后获取时间',
    UNIQUE KEY uk_name (name),
    INDEX idx_category (category),
    INDEX idx_source (source),
    INDEX idx_is_active (is_active),
    INDEX idx_count (count DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云表';

-- 标签云获取历史表
CREATE TABLE IF NOT EXISTS tag_cloud_fetch_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fetch_date DATE NOT NULL COMMENT '获取日期',
    source VARCHAR(50) NOT NULL COMMENT '数据源',
    total_tags INT DEFAULT 0 COMMENT '获取的标签总数',
    new_tags INT DEFAULT 0 COMMENT '新增标签数',
    updated_tags INT DEFAULT 0 COMMENT '更新标签数',
    status ENUM('success', 'failed', 'partial') DEFAULT 'success' COMMENT '获取状态',
    error_message TEXT NULL COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_fetch_date_source (fetch_date, source),
    INDEX idx_fetch_date (fetch_date DESC),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云获取历史表';

-- 插入默认标签
INSERT INTO tag_cloud (name, count, size, color, category, source) VALUES
('Vue.js', 15, 'large', '#4fc08d', 'frontend', 'manual'),
('JavaScript', 20, 'large', '#f7df1e', 'frontend', 'manual'),
('Python', 18, 'large', '#3776ab', 'backend', 'manual'),
('React', 12, 'medium', '#61dafb', 'frontend', 'manual'),
('Node.js', 10, 'medium', '#339933', 'backend', 'manual'),
('CSS', 8, 'medium', '#1572b6', 'frontend', 'manual'),
('HTML', 6, 'small', '#e34f26', 'frontend', 'manual'),
('MySQL', 5, 'small', '#4479a1', 'database', 'manual'),
('Git', 4, 'small', '#f05032', 'tools', 'manual'),
('Docker', 3, 'small', '#2496ed', 'devops', 'manual')
ON DUPLICATE KEY UPDATE count = count + 1;
-- 创建系统设置表
CREATE TABLE IF NOT EXISTS `system_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL COMMENT '设置分类',
  `key_name` varchar(100) NOT NULL COMMENT '设置键名',
  `key_value` text COMMENT '设置值',
  `key_type` enum('string','number','boolean','json','url') NOT NULL DEFAULT 'string' COMMENT '值类型',
  `description` varchar(255) DEFAULT NULL COMMENT '设置描述',
  `is_editable` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否可编辑',
  `is_public` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否公开',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category_key` (`category`, `key_name`),
  KEY `idx_category` (`category`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统设置表';

-- 插入AI相关设置
INSERT INTO `system_setting` (`category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`) VALUES
('ai', 'provider', 'openai', 'string', 'AI服务提供商', 1, 0, 1),
('ai', 'model', 'gpt-3.5-turbo', 'string', 'AI模型名称', 1, 0, 2),
('ai', 'api_key', '', 'string', 'AI API密钥', 1, 0, 3),
('ai', 'base_url', 'https://api.openai.com/v1', 'url', 'AI API基础URL', 1, 0, 4),
('ai', 'max_tokens', '1000', 'number', 'AI最大token数', 1, 0, 5),
('ai', 'temperature', '0.7', 'number', 'AI温度参数', 1, 0, 6),
('ai', 'prompt_template', '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]', 'string', 'AI提示词模板', 1, 0, 7),
('ai', 'enabled', 'true', 'boolean', '是否启用AI功能', 1, 0, 8),
('ai', 'timeout', '30', 'number', 'AI请求超时时间(秒)', 1, 0, 9),
('ai', 'retry_count', '3', 'number', 'AI请求重试次数', 1, 0, 10);

-- 插入其他系统设置示例
INSERT INTO `system_setting` (`category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`) VALUES
('site', 'name', 'MikkoBlog', 'string', '网站名称', 1, 1, 1),
('site', 'description', '个人技术博客', 'string', '网站描述', 1, 1, 2),
('site', 'keywords', '技术,博客,编程', 'string', '网站关键词', 1, 1, 3),
('site', 'logo', '', 'url', '网站Logo', 1, 1, 4),
('site', 'favicon', '', 'url', '网站图标', 1, 1, 5),
('email', 'smtp_host', '', 'string', 'SMTP服务器', 1, 0, 1),
('email', 'smtp_port', '587', 'number', 'SMTP端口', 1, 0, 2),
('email', 'smtp_user', '', 'string', 'SMTP用户名', 1, 0, 3),
('email', 'smtp_password', '', 'string', 'SMTP密码', 1, 0, 4),
('email', 'smtp_ssl', 'true', 'boolean', '是否使用SSL', 1, 0, 5);
-- 重新插入AI设置数据，确保UTF-8编码
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_setting (category, key_name, key_value, key_type, description, is_editable, is_public, sort_order) VALUES
('ai', 'provider', 'openai', 'string', 'AI服务提供商', 1, 0, 1),
('ai', 'model', 'gpt-3.5-turbo', 'string', 'AI模型名称', 1, 0, 2),
('ai', 'api_key', '', 'string', 'AI API密钥', 1, 0, 3),
('ai', 'base_url', 'https://api.openai.com/v1', 'url', 'AI API基础URL', 1, 0, 4),
('ai', 'max_tokens', '1000', 'number', 'AI最大token数', 1, 0, 5),
('ai', 'temperature', '0.7', 'number', 'AI温度参数', 1, 0, 6),
('ai', 'prompt_template', '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]', 'string', 'AI提示词模板', 1, 0, 7),
('ai', 'enabled', 'true', 'boolean', '是否启用AI功能', 1, 0, 8),
('ai', 'timeout', '30', 'number', 'AI请求超时时间(秒)', 1, 0, 9),
('ai', 'retry_count', '3', 'number', 'AI请求重试次数', 1, 0, 10);
-- 图片搜索配置相关的系统默认参数
-- 插入图片搜索配置

INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order) VALUES
-- 图片搜索基础配置
('image_search', 'default_tags', '["设计", "艺术"]', '默认搜索标签（JSON数组格式）', 'json', 1, 0, 1),
('image_search', 'default_orientation', 'landscape', '默认图片方向（landscape/portrait/squarish）', 'string', 1, 0, 2),
('image_search', 'default_count', '5', '默认搜索图片数量', 'number', 1, 0, 3),
('image_search', 'enable_unsplash', 'false', '是否启用Unsplash API', 'boolean', 1, 0, 4),
('image_search', 'unsplash_access_key', '', 'Unsplash API访问密钥', 'string', 1, 0, 5),

-- 专栏封面生成配置
('image_search', 'column_cover_tags', '{"技术": ["科技", "编程"], "编程": ["编程", "代码"], "开发": ["开发", "科技"], "设计": ["设计", "艺术"], "艺术": ["艺术", "设计"], "摄影": ["艺术", "自然"], "旅行": ["旅行", "风景"], "美食": ["食物"], "音乐": ["音乐", "艺术"], "运动": ["运动"], "教育": ["教育"], "商务": ["商务"], "医疗": ["医疗"], "建筑": ["建筑", "城市"], "自然": ["自然", "风景"]}', '专栏名称到标签的映射配置（JSON格式）', 'json', 1, 0, 6),

-- 图片质量和尺寸配置
('image_search', 'image_quality', 'regular', '图片质量（raw/full/regular/small/thumb）', 'string', 1, 0, 7),
('image_search', 'max_image_size', '5242880', '最大图片大小（字节，默认5MB）', 'number', 1, 0, 8),
('image_search', 'preferred_width', '800', '首选图片宽度（像素）', 'number', 1, 0, 9),
('image_search', 'preferred_height', '600', '首选图片高度（像素）', 'number', 1, 0, 10),

-- 备用图片源配置
('image_search', 'fallback_enabled', 'true', '是否启用备用图片源', 'boolean', 1, 0, 11),
('image_search', 'fallback_base_url', 'https://picsum.photos', '备用图片源基础URL', 'url', 1, 0, 12),

-- 下载和缓存配置
('image_search', 'download_timeout', '30', '图片下载超时时间（秒）', 'number', 1, 0, 13),
('image_search', 'ssl_verify', 'false', '是否验证SSL证书', 'boolean', 1, 0, 14),
('image_search', 'auto_retry', 'true', '下载失败时是否自动重试', 'boolean', 1, 0, 15),
('image_search', 'retry_count', '3', '最大重试次数', 'number', 1, 0, 16);
-- 插入正确的site设置数据，确保UTF-8编码
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_setting (category, key_name, key_value, key_type, description, is_editable, is_public, sort_order) VALUES
('site', 'description', '个人技术博客', 'string', '网站描述', 1, 1, 1),
('site', 'keywords', '技术,博客,编程', 'string', '网站关键词', 1, 1, 2);
-- 系统默认参数表
-- 用于存储博客系统的各种默认配置和参数

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

-- 邮件配置
('email', 'smtp_host', '', 'SMTP服务器', 'string', TRUE, FALSE, 1),
('email', 'smtp_port', '587', 'SMTP端口', 'number', TRUE, FALSE, 2),
('email', 'smtp_username', '', 'SMTP用户名', 'string', TRUE, FALSE, 3),
('email', 'smtp_password', '', 'SMTP密码', 'string', TRUE, FALSE, 4),
('email', 'from_email', 'noreply@mikkoblog.com', '发件人邮箱', 'string', TRUE, FALSE, 5),

-- 缓存配置
('cache', 'redis_host', 'localhost', 'Redis主机', 'string', TRUE, FALSE, 1),
('cache', 'redis_port', '6379', 'Redis端口', 'number', TRUE, FALSE, 2),
('cache', 'cache_ttl', '3600', '缓存过期时间（秒）', 'number', TRUE, FALSE, 3),

-- 安全配置
('security', 'jwt_secret', 'your-secret-key', 'JWT密钥', 'string', TRUE, FALSE, 1),
('security', 'jwt_expires_minutes', '1440', 'JWT过期时间（分钟）', 'number', TRUE, FALSE, 2),
('security', 'password_min_length', '8', '密码最小长度', 'number', TRUE, TRUE, 3),
('security', 'max_login_attempts', '5', '最大登录尝试次数', 'number', TRUE, FALSE, 4),

-- 前端配置
('frontend', 'loading_text', '加载中...', '加载提示文字', 'string', TRUE, TRUE, 1),
('frontend', 'no_more_data_text', '没有更多内容了', '无更多数据提示', 'string', TRUE, TRUE, 2),
('frontend', 'error_404_title', '页面未找到', '404错误标题', 'string', TRUE, TRUE, 3),
('frontend', 'error_404_message', '抱歉，您访问的页面不存在', '404错误信息', 'string', TRUE, TRUE, 4),

-- 统计配置
('analytics', 'enable_analytics', 'false', '是否启用统计', 'boolean', TRUE, TRUE, 1),
('analytics', 'google_analytics_id', '', 'Google Analytics ID', 'string', TRUE, TRUE, 2),
('analytics', 'baidu_analytics_id', '', '百度统计ID', 'string', TRUE, TRUE, 3);

-- 创建索引
CREATE INDEX idx_category ON system_defaults(category);
CREATE INDEX idx_is_public ON system_defaults(is_public);
CREATE INDEX idx_sort_order ON system_defaults(sort_order);
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
-- 插入主页设置默认图片记录（UTF8MB4编码）
-- 用于恢复系统默认设置

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order, created_at, updated_at) VALUES
-- 主页设置默认图片
('homepage', 'default_banner_image', '', '默认用户卡片Banner图片', 'url', TRUE, TRUE, 1, NOW(), NOW()),
('homepage', 'default_background_image', '', '默认博客全背景图片', 'url', TRUE, TRUE, 2, NOW(), NOW()),
('homepage', 'default_show_music_player', 'false', '默认是否显示音乐模块', 'boolean', TRUE, TRUE, 3, NOW(), NOW()),
('homepage', 'default_music_url', '', '默认音乐地址', 'url', TRUE, TRUE, 4, NOW(), NOW()),
('homepage', 'default_show_live2d', 'false', '默认是否显示Live2D看板娘', 'boolean', TRUE, TRUE, 5, NOW(), NOW())
ON DUPLICATE KEY UPDATE
    key_value = VALUES(key_value),
    description = VALUES(description),
    data_type = VALUES(data_type),
    is_editable = VALUES(is_editable),
    is_public = VALUES(is_public),
    sort_order = VALUES(sort_order),
    updated_at = NOW();
-- 添加欢迎模态框类型设置字段
-- 执行时间: 2024-01-15

-- 添加 welcome_modal_type 字段到 home_page_settings 表
ALTER TABLE home_page_settings
ADD COLUMN welcome_modal_type VARCHAR(20) DEFAULT 'bible' COMMENT '欢迎模态框类型: bible(圣经话语) 或 quotes(世界名人格言)';

-- 更新现有记录的默认值
UPDATE home_page_settings
SET welcome_modal_type = 'bible'
WHERE welcome_modal_type IS NULL;
-- 为 home_page_settings 表添加 header_title 字段
-- 这个脚本用于更新现有的数据库表结构

-- 添加 header_title 字段
ALTER TABLE home_page_settings ADD COLUMN header_title VARCHAR(255) DEFAULT NULL;

-- 可选：为现有记录设置默认值
-- UPDATE home_page_settings SET header_title = 'MikkoBlog' WHERE header_title IS NULL;
