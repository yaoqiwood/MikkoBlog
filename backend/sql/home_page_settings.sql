-- 首页设置表
CREATE TABLE IF NOT EXISTS home_page_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    header_title VARCHAR(255) DEFAULT NULL,
    banner_image_url TEXT,
    background_image_url TEXT,
    show_music_player INTEGER DEFAULT 0,
    music_url TEXT,
    show_live2d INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
