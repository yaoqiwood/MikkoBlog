CREATE TABLE IF NOT EXISTS system_defaults (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50) NOT NULL,
    key_name VARCHAR(100) NOT NULL,
    key_value TEXT,
    description VARCHAR(255),
    data_type ENUM('string', 'number', 'boolean', 'json', 'url') DEFAULT 'string',
    is_editable BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_category_key (category, key_name)
);
