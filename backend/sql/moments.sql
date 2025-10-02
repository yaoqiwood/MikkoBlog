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
