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

