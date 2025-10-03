-- 创建系统默认参数表 (SQLite版本)
CREATE TABLE IF NOT EXISTS system_defaults (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category VARCHAR(50) NOT NULL,
    key_name VARCHAR(100) NOT NULL,
    key_value TEXT,
    description VARCHAR(255),
    data_type VARCHAR(20) DEFAULT 'string' CHECK (data_type IN ('string', 'number', 'boolean', 'json', 'url')),
    is_editable INTEGER DEFAULT 1,
    is_public INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(category, key_name)
);
