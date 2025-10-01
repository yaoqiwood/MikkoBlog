-- 插入主页设置默认图片记录（UTF8MB4编码）
-- 用于恢复系统默认设置

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

INSERT INTO system_defaults (category, key_name, key_value, description, data_type, is_editable, is_public, sort_order, created_at, updated_at) VALUES
-- 主页设置默认图片
('homepage', 'default_banner_image', '', '默认用户卡片Banner图片', 'url', TRUE, TRUE, 1, NOW(), NOW()),
('homepage', 'default_background_image', '', '默认博客全背景图片', 'url', TRUE, TRUE, 2, NOW(), NOW()),
('homepage', 'default_show_music_player', 'false', '默认是否显示音乐模块', 'boolean', TRUE, TRUE, 3, NOW(), NOW()),
('homepage', 'default_music_url', '', '默认音乐地址', 'url', TRUE, TRUE, 4, NOW(), NOW()),
('homepage', 'default_show_live2d', 'false', '默认是否显示Live2D看板娘', 'boolean', TRUE, TRUE, 5, NOW(), NOW())
ON DUPLICATE KEY UPDATE
    key_value = VALUES(key_value),
    description = VALUES(description),
    data_type = VALUES(data_type),
    is_editable = VALUES(is_editable),
    is_public = VALUES(is_public),
    sort_order = VALUES(sort_order),
    updated_at = NOW();
