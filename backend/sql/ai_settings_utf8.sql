-- 重新插入AI设置数据，确保UTF-8编码
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_setting (category, key_name, key_value, key_type, description, is_editable, is_public, sort_order) VALUES
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
