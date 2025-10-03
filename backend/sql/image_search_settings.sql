-- 图片搜索配置相关的系统默认参数
-- 插入图片搜索配置

INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order) VALUES
-- 图片搜索基础配置
('image_search', 'default_tags', '["设计", "艺术"]', '默认搜索标签（JSON数组格式）', 'json', 1, 0, 1),
('image_search', 'default_orientation', 'landscape', '默认图片方向（landscape/portrait/squarish）', 'string', 1, 0, 2),
('image_search', 'default_count', '5', '默认搜索图片数量', 'number', 1, 0, 3),
('image_search', 'enable_unsplash', 'false', '是否启用Unsplash API', 'boolean', 1, 0, 4),
('image_search', 'unsplash_access_key', '', 'Unsplash API访问密钥', 'string', 1, 0, 5),

-- 专栏封面生成配置
('image_search', 'column_cover_tags', '{"技术": ["科技", "编程"], "编程": ["编程", "代码"], "开发": ["开发", "科技"], "设计": ["设计", "艺术"], "艺术": ["艺术", "设计"], "摄影": ["艺术", "自然"], "旅行": ["旅行", "风景"], "美食": ["食物"], "音乐": ["音乐", "艺术"], "运动": ["运动"], "教育": ["教育"], "商务": ["商务"], "医疗": ["医疗"], "建筑": ["建筑", "城市"], "自然": ["自然", "风景"]}', '专栏名称到标签的映射配置（JSON格式）', 'json', 1, 0, 6),

-- 图片质量和尺寸配置
('image_search', 'image_quality', 'regular', '图片质量（raw/full/regular/small/thumb）', 'string', 1, 0, 7),
('image_search', 'max_image_size', '5242880', '最大图片大小（字节，默认5MB）', 'number', 1, 0, 8),
('image_search', 'preferred_width', '800', '首选图片宽度（像素）', 'number', 1, 0, 9),
('image_search', 'preferred_height', '600', '首选图片高度（像素）', 'number', 1, 0, 10),

-- 备用图片源配置
('image_search', 'fallback_enabled', 'true', '是否启用备用图片源', 'boolean', 1, 0, 11),
('image_search', 'fallback_base_url', 'https://picsum.photos', '备用图片源基础URL', 'url', 1, 0, 12),

-- 下载和缓存配置
('image_search', 'download_timeout', '30', '图片下载超时时间（秒）', 'number', 1, 0, 13),
('image_search', 'ssl_verify', 'false', '是否验证SSL证书', 'boolean', 1, 0, 14),
('image_search', 'auto_retry', 'true', '下载失败时是否自动重试', 'boolean', 1, 0, 15),
('image_search', 'retry_count', '3', '最大重试次数', 'number', 1, 0, 16);
