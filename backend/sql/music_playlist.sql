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
