-- 标签云表
CREATE TABLE IF NOT EXISTS tag_cloud (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '标签名称',
    count INT DEFAULT 1 COMMENT '使用次数',
    size VARCHAR(20) DEFAULT 'medium' COMMENT '标签大小: small, medium, large',
    color VARCHAR(20) DEFAULT '#ff6b6b' COMMENT '标签颜色',
    category VARCHAR(50) DEFAULT 'general' COMMENT '标签分类',
    source VARCHAR(50) DEFAULT 'manual' COMMENT '来源: manual, auto, trending',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否激活',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    last_fetched_at TIMESTAMP NULL COMMENT '最后获取时间',
    UNIQUE KEY uk_name (name),
    INDEX idx_category (category),
    INDEX idx_source (source),
    INDEX idx_is_active (is_active),
    INDEX idx_count (count DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云表';

-- 标签云获取历史表
CREATE TABLE IF NOT EXISTS tag_cloud_fetch_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fetch_date DATE NOT NULL COMMENT '获取日期',
    source VARCHAR(50) NOT NULL COMMENT '数据源',
    total_tags INT DEFAULT 0 COMMENT '获取的标签总数',
    new_tags INT DEFAULT 0 COMMENT '新增标签数',
    updated_tags INT DEFAULT 0 COMMENT '更新标签数',
    status ENUM('success', 'failed', 'partial') DEFAULT 'success' COMMENT '获取状态',
    error_message TEXT NULL COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_fetch_date_source (fetch_date, source),
    INDEX idx_fetch_date (fetch_date DESC),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云获取历史表';

-- 插入默认标签
INSERT INTO tag_cloud (name, count, size, color, category, source) VALUES
('Vue.js', 15, 'large', '#4fc08d', 'frontend', 'manual'),
('JavaScript', 20, 'large', '#f7df1e', 'frontend', 'manual'),
('Python', 18, 'large', '#3776ab', 'backend', 'manual'),
('React', 12, 'medium', '#61dafb', 'frontend', 'manual'),
('Node.js', 10, 'medium', '#339933', 'backend', 'manual'),
('CSS', 8, 'medium', '#1572b6', 'frontend', 'manual'),
('HTML', 6, 'small', '#e34f26', 'frontend', 'manual'),
('MySQL', 5, 'small', '#4479a1', 'database', 'manual'),
('Git', 4, 'small', '#f05032', 'tools', 'manual'),
('Docker', 3, 'small', '#2496ed', 'devops', 'manual')
ON DUPLICATE KEY UPDATE count = count + 1;
