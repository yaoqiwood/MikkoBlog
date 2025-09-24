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
