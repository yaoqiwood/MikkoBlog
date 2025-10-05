-- 插入正确的site设置数据，确保UTF-8编码
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_setting (category, key_name, key_value, key_type, description, is_editable, is_public, sort_order) VALUES
('site', 'description', '个人技术博客', 'string', '网站描述', 1, 1, 1),
('site', 'keywords', '技术,博客,编程', 'string', '网站关键词', 1, 1, 2);
