-- AI设置相关系统默认值
-- 添加AI名称和API Key字段到系统设置

INSERT INTO system_defaults (category, key_name, key_value, description, is_editable, is_public, sort_order, data_type, created_at, updated_at) VALUES
('AISettings', 'ai_provider', 'openai', 'AI服务提供商', true, false, 1, 'string', NOW(), NOW()),
('AISettings', 'ai_model', 'gpt-3.5-turbo', 'AI模型名称', true, false, 2, 'string', NOW(), NOW()),
('AISettings', 'ai_api_key', '', 'AI API密钥', true, false, 3, 'string', NOW(), NOW()),
('AISettings', 'ai_base_url', 'https://api.openai.com/v1', 'AI API基础URL', true, false, 4, 'url', NOW(), NOW()),
('AISettings', 'ai_max_tokens', '1000', 'AI最大token数', true, false, 5, 'number', NOW(), NOW()),
('AISettings', 'ai_temperature', '0.7', 'AI温度参数', true, false, 6, 'number', NOW(), NOW()),
('AISettings', 'ai_prompt_template', '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]', 'AI提示词模板', true, false, 7, 'string', NOW(), NOW());
