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

