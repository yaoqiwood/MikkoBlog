-- 创建点赞追踪表，记录用户IP和点赞信息
CREATE TABLE IF NOT EXISTS `post_like_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '文章ID',
  `user_ip` varchar(45) NOT NULL COMMENT '用户IP地址',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_user_ip` (`post_id`, `user_ip`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_ip` (`user_ip`),
  CONSTRAINT `fk_post_like_tracking_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章点赞追踪表';
