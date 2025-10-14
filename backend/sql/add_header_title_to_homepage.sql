-- 为 home_page_settings 表添加 header_title 字段
-- 这个脚本用于更新现有的数据库表结构

-- 检查表是否存在，如果存在则添加字段
SET @table_exists = (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'home_page_settings'
);

-- 如果表存在，则添加字段
SET @sql = IF(@table_exists > 0,
    'ALTER TABLE home_page_settings ADD COLUMN header_title VARCHAR(255) DEFAULT NULL',
    'SELECT "Table home_page_settings does not exist, skipping column addition" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
