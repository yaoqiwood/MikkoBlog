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
