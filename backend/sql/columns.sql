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
