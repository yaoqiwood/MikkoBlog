-- 添加欢迎模态框类型设置字段
-- 执行时间: 2024-01-15

-- 检查表是否存在，如果存在则添加字段
SET @table_exists = (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'home_page_settings'
);

-- 如果表存在，则添加字段
SET @sql = IF(@table_exists > 0,
    'ALTER TABLE home_page_settings ADD COLUMN welcome_modal_type VARCHAR(20) DEFAULT "bible" COMMENT "欢迎模态框类型: bible(圣经话语) 或 quotes(世界名人格言)"',
    'SELECT "Table home_page_settings does not exist, skipping column addition" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 如果表存在，更新现有记录的默认值
SET @sql2 = IF(@table_exists > 0,
    'UPDATE home_page_settings SET welcome_modal_type = "bible" WHERE welcome_modal_type IS NULL',
    'SELECT "Table home_page_settings does not exist, skipping update" as message'
);

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
