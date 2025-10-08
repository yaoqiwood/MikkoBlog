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
