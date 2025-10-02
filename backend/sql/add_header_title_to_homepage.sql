-- 为 home_page_settings 表添加 header_title 字段
-- 这个脚本用于更新现有的数据库表结构

-- 添加 header_title 字段
ALTER TABLE home_page_settings ADD COLUMN header_title VARCHAR(255) DEFAULT NULL;

-- 可选：为现有记录设置默认值
-- UPDATE home_page_settings SET header_title = 'MikkoBlog' WHERE header_title IS NULL;
