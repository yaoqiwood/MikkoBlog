-- 添加欢迎模态框类型设置字段
-- 执行时间: 2024-01-15

-- 添加 welcome_modal_type 字段到 home_page_settings 表
ALTER TABLE home_page_settings
ADD COLUMN welcome_modal_type VARCHAR(20) DEFAULT 'bible' COMMENT '欢迎模态框类型: bible(圣经话语) 或 quotes(世界名人格言)';

-- 更新现有记录的默认值
UPDATE home_page_settings
SET welcome_modal_type = 'bible'
WHERE welcome_modal_type IS NULL;
