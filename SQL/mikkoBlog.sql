/*
 Navicat Premium Dump SQL

 Source Server         : 开发环境 mysql 测试 pass123 StrongPass123!
 Source Server Type    : MySQL
 Source Server Version : 80406 (8.4.6)
 Source Host           : localhost:3306
 Source Schema         : mikkoBlog

 Target Server Type    : MySQL
 Target Server Version : 80406 (8.4.6)
 File Encoding         : 65001

 Date: 13/10/2025 12:06:59
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for attachments
-- ----------------------------
DROP TABLE IF EXISTS `attachments`;
CREATE TABLE `attachments` (
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_url` varchar(255) NOT NULL,
  `file_size` int NOT NULL,
  `file_type` varchar(255) NOT NULL,
  `file_extension` varchar(255) NOT NULL,
  `file_category` enum('IMAGE','DOCUMENT','VIDEO','AUDIO','OTHER') NOT NULL,
  `width` int DEFAULT NULL,
  `height` int DEFAULT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL,
  `is_featured` tinyint(1) NOT NULL,
  `download_count` int NOT NULL,
  `view_count` int NOT NULL,
  `uploaded_by` int NOT NULL,
  `related_type` varchar(255) DEFAULT NULL,
  `related_id` int DEFAULT NULL,
  `status` enum('ACTIVE','DELETED','HIDDEN') NOT NULL,
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of attachments
-- ----------------------------
BEGIN;
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('e9eb80414ced4b0b9646cf71c349af4c.jpg', '1541758439222_.pic.jpg', 'uploads/images/e9eb80414ced4b0b9646cf71c349af4c.jpg', '/uploads/images/e9eb80414ced4b0b9646cf71c349af4c.jpg', 144971, 'image/jpeg', '.jpg', 'IMAGE', NULL, NULL, NULL, '1', '2', NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 6, '2025-09-24 14:29:27', '2025-09-27 02:37:06', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('a5f4984e007546febeb982c812445191.png', '2025-01-23 190513.png', 'uploads/images/a5f4984e007546febeb982c812445191.png', '/uploads/images/a5f4984e007546febeb982c812445191.png', 1929200, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'DELETED', 7, '2025-09-24 15:32:22', '2025-09-24 15:36:23', '2025-09-24 15:36:23');
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('e41d1f3cdbda444ca1efcd6f1ee4385f.png', '2025-01-23 190513.png', 'uploads/images/e41d1f3cdbda444ca1efcd6f1ee4385f.png', '/uploads/images/e41d1f3cdbda444ca1efcd6f1ee4385f.png', 1929200, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, '2025-01-23 190513', '头像', '头像 二次元 ', 1, 1, 0, 0, 1, NULL, NULL, 'ACTIVE', 8, '2025-09-24 15:36:53', '2025-09-24 15:36:53', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('e431f010573b4464a7a7e37bc586aec7.png', 'WechatIMG452.png', 'uploads/images/e431f010573b4464a7a7e37bc586aec7.png', '/uploads/images/e431f010573b4464a7a7e37bc586aec7.png', 427558, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 9, '2025-10-02 03:53:38', '2025-10-02 03:53:38', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('6202235e61104d1b977c524a298fc539.jpg', 'gvuy5dA.jpg', 'uploads/images/6202235e61104d1b977c524a298fc539.jpg', '/uploads/images/6202235e61104d1b977c524a298fc539.jpg', 340404, 'image/jpeg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 10, '2025-10-02 07:51:35', '2025-10-02 07:51:35', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('c699f803518b467886e01ae243b619b6.png', 'WX20231030-221250@2x.png', 'uploads/images/c699f803518b467886e01ae243b619b6.png', '/uploads/images/c699f803518b467886e01ae243b619b6.png', 233514, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 11, '2025-10-02 07:51:35', '2025-10-02 07:51:35', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('f323e06bc7054e659baf91d4512f6f1a.png', 'WechatIMG234.png', 'uploads/images/f323e06bc7054e659baf91d4512f6f1a.png', '/uploads/images/f323e06bc7054e659baf91d4512f6f1a.png', 383815, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 12, '2025-10-02 07:51:35', '2025-10-02 07:51:35', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('2e39bf1daf684254894c1969838ba7bf.png', 'WechatIMG233.png', 'uploads/images/2e39bf1daf684254894c1969838ba7bf.png', '/uploads/images/2e39bf1daf684254894c1969838ba7bf.png', 250038, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 13, '2025-10-02 07:51:35', '2025-10-02 07:51:35', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('7ed3573e182a4363bff5034026cc02d0.png', 'WX20230419-075536.png', 'uploads/images/7ed3573e182a4363bff5034026cc02d0.png', '/uploads/images/7ed3573e182a4363bff5034026cc02d0.png', 418545, 'image/png', '.png', 'IMAGE', NULL, NULL, NULL, NULL, NULL, NULL, 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 14, '2025-10-02 07:51:35', '2025-10-02 07:51:35', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203026_cc050876.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_203026_cc050876.jpg', '/uploads/images/20251002_203026_cc050876.jpg', 73129, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 15, '2025-10-02 12:30:26', '2025-10-02 12:30:26', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203239_bf29c592.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_203239_bf29c592.jpg', '/uploads/images/20251002_203239_bf29c592.jpg', 73388, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 16, '2025-10-02 12:32:39', '2025-10-02 12:32:39', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203242_06ec1708.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_203242_06ec1708.jpg', '/uploads/images/20251002_203242_06ec1708.jpg', 109311, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 17, '2025-10-02 12:32:43', '2025-10-02 12:32:43', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203244_70a27031.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_203244_70a27031.jpg', '/uploads/images/20251002_203244_70a27031.jpg', 72633, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 18, '2025-10-02 12:32:45', '2025-10-02 12:32:45', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203247_6246c9d2.jpg', '备用图片 - 科技, 编程.jpg', 'uploads/images/20251002_203247_6246c9d2.jpg', '/uploads/images/20251002_203247_6246c9d2.jpg', 58205, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 科技, 编程', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 19, '2025-10-02 12:32:47', '2025-10-02 12:32:47', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_203249_4640fcb3.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_203249_4640fcb3.jpg', '/uploads/images/20251002_203249_4640fcb3.jpg', 50323, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 20, '2025-10-02 12:32:50', '2025-10-02 12:32:50', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_204140_d8c41943.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_204140_d8c41943.jpg', '/uploads/images/20251002_204140_d8c41943.jpg', 51136, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 21, '2025-10-02 12:41:40', '2025-10-02 12:41:40', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251002_204143_d7a54efa.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251002_204143_d7a54efa.jpg', '/uploads/images/20251002_204143_d7a54efa.jpg', 61487, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 22, '2025-10-02 12:41:44', '2025-10-02 12:41:44', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251003_110312_aabcd621.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251003_110312_aabcd621.jpg', '/uploads/images/20251003_110312_aabcd621.jpg', 34999, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 23, '2025-10-03 03:03:12', '2025-10-03 03:03:12', NULL);
INSERT INTO `attachments` (`filename`, `original_name`, `file_path`, `file_url`, `file_size`, `file_type`, `file_extension`, `file_category`, `width`, `height`, `alt_text`, `title`, `description`, `tags`, `is_public`, `is_featured`, `download_count`, `view_count`, `uploaded_by`, `related_type`, `related_id`, `status`, `id`, `created_at`, `updated_at`, `deleted_at`) VALUES ('20251003_110321_ac03eb35.jpg', '备用图片 - 设计, 艺术.jpg', 'uploads/images/20251003_110321_ac03eb35.jpg', '/uploads/images/20251003_110321_ac03eb35.jpg', 33278, 'image/jpg', '.jpg', 'IMAGE', NULL, NULL, NULL, NULL, '自动生成 - 备用图片 - 设计, 艺术', 'source:fallback,author:Picsum Photos', 1, 0, 0, 0, 1, NULL, NULL, 'ACTIVE', 24, '2025-10-03 03:03:22', '2025-10-03 03:03:22', NULL);
COMMIT;

-- ----------------------------
-- Table structure for columns
-- ----------------------------
DROP TABLE IF EXISTS `columns`;
CREATE TABLE `columns` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '专栏ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '专栏名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '专栏描述',
  `cover_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '专栏封面图片URL',
  `sort_order` int DEFAULT '0' COMMENT '排序顺序，数字越小越靠前',
  `is_visible` tinyint(1) DEFAULT '1' COMMENT '是否可见 1:可见 0:隐藏',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否已删除 1:已删除 0:未删除',
  `user_id` int NOT NULL COMMENT '创建者用户ID',
  `post_count` int DEFAULT '0' COMMENT '专栏文章数量（冗余字段，便于查询）',
  `view_count` int DEFAULT '0' COMMENT '专栏浏览量',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_is_visible` (`is_visible`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_columns_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='博主专栏表';

-- ----------------------------
-- Records of columns
-- ----------------------------
BEGIN;
INSERT INTO `columns` (`id`, `name`, `description`, `cover_image_url`, `sort_order`, `is_visible`, `is_deleted`, `user_id`, `post_count`, `view_count`, `created_at`, `updated_at`) VALUES (1, 'Redis分析', 'Redis核心源码深度解析，从数据结构到网络模型', '/uploads/images/20251003_110321_ac03eb35.jpg', 1, 1, 0, 1, 0, 8, '2025-10-02 08:21:23', '2025-10-07 11:55:04');
INSERT INTO `columns` (`id`, `name`, `description`, `cover_image_url`, `sort_order`, `is_visible`, `is_deleted`, `user_id`, `post_count`, `view_count`, `created_at`, `updated_at`) VALUES (2, 'Java分析', 'Java核心类库源码解读，深入理解JVM原理', '/uploads/images/20251002_204143_d7a54efa.jpg', 2, 1, 0, 1, 0, 0, '2025-10-02 08:21:23', '2025-10-07 11:55:09');
INSERT INTO `columns` (`id`, `name`, `description`, `cover_image_url`, `sort_order`, `is_visible`, `is_deleted`, `user_id`, `post_count`, `view_count`, `created_at`, `updated_at`) VALUES (3, 'Tomcat', 'Tomcat服务器源码分析，Web容器实现原理', '/uploads/images/20251002_203244_70a27031.jpg', 3, 1, 0, 1, 0, 0, '2025-10-02 08:21:23', '2025-10-07 11:55:14');
INSERT INTO `columns` (`id`, `name`, `description`, `cover_image_url`, `sort_order`, `is_visible`, `is_deleted`, `user_id`, `post_count`, `view_count`, `created_at`, `updated_at`) VALUES (4, '前端技术栈', '现代前端开发技术分享，Vue、React、TypeScript等', '/uploads/images/20251002_203247_6246c9d2.jpg', 4, 1, 0, 1, 0, 0, '2025-10-02 08:21:23', '2025-10-02 12:32:47');
INSERT INTO `columns` (`id`, `name`, `description`, `cover_image_url`, `sort_order`, `is_visible`, `is_deleted`, `user_id`, `post_count`, `view_count`, `created_at`, `updated_at`) VALUES (5, '系统设计', '大型系统架构设计经验分享', '/uploads/images/20251002_203249_4640fcb3.jpg', 5, 1, 0, 1, 0, 0, '2025-10-02 08:21:23', '2025-10-02 12:32:50');
COMMIT;

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `author_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论者姓名',
  `author_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '评论者邮箱（可选）',
  `author_website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '评论者网站（可选）',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP地址',
  `location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '地域信息',
  `user_agent` text COLLATE utf8mb4_unicode_ci COMMENT '用户代理',
  `is_approved` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态（0/1）',
  `is_visible` tinyint(1) NOT NULL DEFAULT '1' COMMENT '可见性（0/1）',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '软删除标记（0/1）',
  `parent_id` int DEFAULT NULL COMMENT '父评论ID（支持回复）',
  `post_id` int NOT NULL COMMENT '关联文章ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_is_approved` (`is_approved`),
  KEY `idx_is_visible` (`is_visible`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `comment` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- ----------------------------
-- Records of comment
-- ----------------------------
BEGIN;
INSERT INTO `comment` (`id`, `content`, `author_name`, `author_email`, `author_website`, `ip_address`, `location`, `user_agent`, `is_approved`, `is_visible`, `is_deleted`, `parent_id`, `post_id`, `created_at`, `updated_at`) VALUES (1, '你傻逼', 'aa', NULL, NULL, NULL, NULL, NULL, 0, 1, 0, NULL, 1, '2025-09-23 09:07:17', '2025-09-23 09:07:17');
COMMIT;

-- ----------------------------
-- Table structure for home_page_settings
-- ----------------------------
DROP TABLE IF EXISTS `home_page_settings`;
CREATE TABLE `home_page_settings` (
  `banner_image_url` varchar(255) DEFAULT NULL,
  `background_image_url` varchar(255) DEFAULT NULL,
  `header_title` varchar(255) DEFAULT NULL,
  `show_music_player` tinyint(1) NOT NULL,
  `music_url` varchar(255) DEFAULT NULL,
  `show_live2d` tinyint(1) NOT NULL,
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `welcome_modal_type` varchar(20) DEFAULT 'bible' COMMENT 'æ¬¢è¿Žæ¨¡æ€æ¡†ç±»åž‹: bible(åœ£ç»è¯è¯­) æˆ– quotes(ä¸–ç•Œåäººæ ¼è¨€)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of home_page_settings
-- ----------------------------
BEGIN;
INSERT INTO `home_page_settings` (`banner_image_url`, `background_image_url`, `header_title`, `show_music_player`, `music_url`, `show_live2d`, `id`, `created_at`, `updated_at`, `welcome_modal_type`) VALUES ('/uploads/images/20251001_090841_1a218894.jpg', '/uploads/images/20251001_111433_b13b85a7.jpeg', 'Mikko 的技术小栈', 0, '', 0, 1, '2025-09-30 15:43:13', '2025-10-08 11:36:03', 'bible');
COMMIT;

-- ----------------------------
-- Table structure for moments
-- ----------------------------
DROP TABLE IF EXISTS `moments`;
CREATE TABLE `moments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` varchar(150) NOT NULL,
  `is_visible` tinyint(1) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL,
  `user_id` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `moments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_profiles` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of moments
-- ----------------------------
BEGIN;
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (1, '这是第一条测试说说！🎉 欢迎来到MikkoBlog的说说功能！', 1, 0, 1, '2025-10-02 03:19:13', '2025-10-02 03:19:13');
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (2, '第二条说说，测试多条数据的显示效果。支持最多150个字符的内容。', 1, 0, 1, '2025-10-02 03:19:13', '2025-10-02 03:19:13');
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (3, '这是一条隐藏的说说，用于测试可见性筛选功能。', 0, 0, 1, '2025-10-02 03:19:13', '2025-10-02 03:19:13');
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (4, '测试', 1, 0, 1, '2025-10-02 03:45:36', '2025-10-02 03:45:36');
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (5, '123', 1, 0, 1, '2025-10-02 03:53:42', '2025-10-02 03:53:42');
INSERT INTO `moments` (`id`, `content`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (6, '记录', 1, 0, 1, '2025-10-02 07:51:44', '2025-10-02 07:51:44');
COMMIT;

-- ----------------------------
-- Table structure for moments_images
-- ----------------------------
DROP TABLE IF EXISTS `moments_images`;
CREATE TABLE `moments_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `moment_id` int NOT NULL,
  `attachment_id` int NOT NULL,
  `sort_order` int NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `moment_id` (`moment_id`),
  KEY `attachment_id` (`attachment_id`),
  CONSTRAINT `moments_images_ibfk_1` FOREIGN KEY (`moment_id`) REFERENCES `moments` (`id`),
  CONSTRAINT `moments_images_ibfk_2` FOREIGN KEY (`attachment_id`) REFERENCES `attachments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of moments_images
-- ----------------------------
BEGIN;
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (1, 5, 9, 0, '2025-10-02 03:53:42');
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (2, 6, 10, 0, '2025-10-02 07:51:44');
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (3, 6, 11, 1, '2025-10-02 07:51:44');
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (4, 6, 12, 2, '2025-10-02 07:51:44');
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (5, 6, 13, 3, '2025-10-02 07:51:44');
INSERT INTO `moments_images` (`id`, `moment_id`, `attachment_id`, `sort_order`, `created_at`) VALUES (6, 6, 14, 4, '2025-10-02 07:51:44');
COMMIT;

-- ----------------------------
-- Table structure for music_playlist
-- ----------------------------
DROP TABLE IF EXISTS `music_playlist`;
CREATE TABLE `music_playlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '播放列表名称',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '播放列表描述',
  `cover_image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面图片URL',
  `is_public` tinyint(1) DEFAULT '1' COMMENT '是否公开',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `user_id` int NOT NULL COMMENT '创建用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐播放列表表';

-- ----------------------------
-- Records of music_playlist
-- ----------------------------
BEGIN;
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (1, '默认播放列表', '系统默认播放列表', NULL, 1, 1, 1, '2025-10-07 01:01:08', '2025-10-08 08:28:51');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (5, '更新后的播放列表', '这是一个测试播放列表', NULL, 0, 0, 1, '2025-10-08 16:08:28', '2025-10-08 16:16:55');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (6, '前端测试播放列表', '测试前端修复', NULL, 1, 0, 1, '2025-10-08 16:13:04', '2025-10-08 16:13:27');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (7, '测试', 'null', NULL, 0, 0, 1, '2025-10-08 16:13:32', '2025-10-08 16:16:51');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (8, '默认私有播放列表', '测试默认私有', NULL, 1, 0, 1, '2025-10-08 16:15:51', '2025-10-08 16:16:48');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (9, '新的公开播放列表', '测试公开', NULL, 0, 0, 1, '2025-10-08 16:15:55', '2025-10-08 16:16:50');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (10, '测速', 'null', NULL, 0, 0, 1, '2025-10-08 16:17:01', '2025-10-08 16:28:54');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (11, '测试', '', NULL, 0, 0, 1, '2025-10-08 16:17:14', '2025-10-08 16:28:56');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (12, '测试空描述', '', NULL, 0, 0, 1, '2025-10-08 16:19:33', '2025-10-08 16:29:02');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (13, '测试无描述参数', '', NULL, 0, 0, 1, '2025-10-08 16:19:38', '2025-10-08 16:28:58');
INSERT INTO `music_playlist` (`id`, `name`, `description`, `cover_image_url`, `is_public`, `is_active`, `user_id`, `created_at`, `updated_at`) VALUES (14, '测试 1', '', NULL, 0, 0, 1, '2025-10-08 16:25:19', '2025-10-08 16:29:00');
COMMIT;

-- ----------------------------
-- Table structure for music_track
-- ----------------------------
DROP TABLE IF EXISTS `music_track`;
CREATE TABLE `music_track` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '歌曲标题',
  `artist` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '艺术家',
  `album` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '专辑名称',
  `duration` int DEFAULT NULL COMMENT '时长(秒)',
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '音频文件URL',
  `stream_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '流媒体URL',
  `cover_image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面图片URL',
  `lyrics` text COLLATE utf8mb4_unicode_ci COMMENT '歌词',
  `genre` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '音乐类型',
  `year` int DEFAULT NULL COMMENT '发行年份',
  `external_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '外部平台ID',
  `platform` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '来源平台',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artist` (`artist`),
  KEY `idx_genre` (`genre`),
  KEY `idx_external_id` (`external_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='音乐曲目表';

-- ----------------------------
-- Records of music_track
-- ----------------------------
BEGIN;
INSERT INTO `music_track` (`id`, `title`, `artist`, `album`, `duration`, `file_url`, `stream_url`, `cover_image_url`, `lyrics`, `genre`, `year`, `external_id`, `platform`, `is_active`, `created_at`, `updated_at`) VALUES (12, 'Funk No.1 - TOKYO GROOVE JYOSHI (feat. Juna Serita & Harumo Imai) - Juna Serita', 'Funk No.1', '', NULL, '/uploads/music/aa903c30-eeea-45ea-842b-cecf75b2f6df.mp3', NULL, NULL, '', '', NULL, NULL, 'local', 1, '2025-10-07 23:39:21', '2025-10-07 23:39:21');
COMMIT;

-- ----------------------------
-- Table structure for playlist_track
-- ----------------------------
DROP TABLE IF EXISTS `playlist_track`;
CREATE TABLE `playlist_track` (
  `id` int NOT NULL AUTO_INCREMENT,
  `playlist_id` int NOT NULL COMMENT '播放列表ID',
  `track_id` int NOT NULL COMMENT '曲目ID',
  `position` int NOT NULL DEFAULT '0' COMMENT '在播放列表中的位置',
  `added_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加到播放列表的时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_playlist_track` (`playlist_id`,`track_id`),
  KEY `idx_playlist_id` (`playlist_id`),
  KEY `idx_track_id` (`track_id`),
  KEY `idx_position` (`position`),
  CONSTRAINT `fk_playlist_track_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `music_playlist` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_playlist_track_track` FOREIGN KEY (`track_id`) REFERENCES `music_track` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='播放列表-曲目关联表';

-- ----------------------------
-- Records of playlist_track
-- ----------------------------
BEGIN;
INSERT INTO `playlist_track` (`id`, `playlist_id`, `track_id`, `position`, `added_at`) VALUES (4, 1, 12, 0, '2025-10-07 23:39:21');
COMMIT;

-- ----------------------------
-- Table structure for post
-- ----------------------------
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `summary` varchar(500) DEFAULT NULL,
  `cover_image_url` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) NOT NULL,
  `is_visible` int DEFAULT '1',
  `is_deleted` int DEFAULT '0',
  `user_id` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of post
-- ----------------------------
BEGIN;
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (1, '我的测试文章', '测试一下![image.png](http://localhost:8000/uploads/images/20250923_020952_91843c1f.png)', '测试一下', '', 1, 1, 0, 1, '2025-09-23 01:46:47', '2025-09-23 03:37:39');
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (2, '', '', '', '', 0, 1, 1, 1, '2025-09-23 03:31:32', '2025-09-23 03:32:04');
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (3, '', '', '', '', 0, 1, 1, 1, '2025-09-23 03:32:08', '2025-09-23 03:32:12');
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (4, '第二篇测试文章', '这是第二篇测试文章的内容，用于测试相关博文功能。', '第二篇测试文章的摘要', NULL, 1, 1, 0, 1, '2025-10-06 12:14:09', '2025-10-06 12:14:09');
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (5, '第三篇测试文章', '这是第三篇测试文章的内容，同样用于测试相关博文功能。', '第三篇测试文章的摘要', NULL, 1, 1, 0, 1, '2025-10-06 12:14:13', '2025-10-06 12:14:13');
INSERT INTO `post` (`id`, `title`, `content`, `summary`, `cover_image_url`, `is_published`, `is_visible`, `is_deleted`, `user_id`, `created_at`, `updated_at`) VALUES (6, 'RAG技术介绍：检索增强生成的核心原理', '# RAG技术介绍：检索增强生成的核心原理\n\n## 什么是RAG？\n\nRAG（Retrieval-Augmented Generation，检索增强生成）是一种结合了信息检索和文本生成的AI技术。它通过从外部知识库中检索相关信息，然后将这些信息与用户查询结合，生成更准确、更相关的回答。\n\n![RAG架构示意图](http://localhost:8000/uploads/images/20250923_020952_91843c1f.png)\n\n## RAG的核心组件\n\n### 1. 检索器（Retriever）\n\n检索器负责从知识库中找到与用户查询最相关的文档片段。常用的检索方法包括：\n\n- **密集检索**：使用向量相似度搜索\n- **稀疏检索**：基于关键词匹配的传统方法\n- **混合检索**：结合密集和稀疏检索的优势\n\n### 2. 生成器（Generator）\n\n生成器基于检索到的信息和用户查询，生成最终的回答。通常使用大型语言模型（LLM）作为生成器。\n\n### 3. 知识库（Knowledge Base）\n\n知识库存储用于检索的文档集合，可以是：\n\n- 结构化数据（数据库）\n- 非结构化文本（文档、网页）\n- 多媒体内容（图片、音频）\n\n## RAG的工作流程\n\n1. **查询理解**：分析用户查询的意图和关键信息\n2. **文档检索**：从知识库中检索相关文档\n3. **相关性排序**：对检索结果进行排序和筛选\n4. **上下文构建**：将检索到的信息组织成上下文\n5. **生成回答**：基于上下文生成最终回答\n6. **返回结果**：将生成的回答返回给用户\n\n## RAG的优势\n\n### 1. 知识更新及时\n\n与传统的预训练模型不同，RAG可以通过更新知识库来获取最新信息，而不需要重新训练整个模型。\n\n### 2. 减少幻觉问题\n\n通过提供真实的外部信息作为上下文，RAG可以显著减少模型生成虚假信息的可能性。\n\n### 3. 可解释性强\n\nRAG系统可以明确显示用于生成回答的源文档，提高了系统的透明度和可信度。\n\n### 4. 领域适应性好\n\n通过更换知识库，RAG可以轻松适应不同的专业领域。\n\n## RAG的应用场景\n\n### 1. 智能问答系统\n\n- 企业内部知识库问答\n- 客户服务机器人\n- 教育辅导系统\n\n### 2. 文档处理\n\n- 法律文档分析\n- 医疗报告解读\n- 技术文档查询\n\n### 3. 内容创作\n\n- 新闻写作辅助\n- 学术论文生成\n- 营销文案创作\n\n## RAG的技术挑战\n\n### 1. 检索质量\n\n如何确保检索到的信息与用户查询高度相关，是RAG系统面临的主要挑战之一。\n\n### 2. 上下文长度限制\n\n大多数LLM都有上下文长度限制，如何在有限的空间内包含最相关的信息是一个难题。\n\n### 3. 实时性要求\n\n对于需要实时响应的应用，检索和生成的速度都需要优化。\n\n### 4. 多模态支持\n\n如何将文本、图像、音频等多种模态的信息整合到RAG系统中。\n\n## RAG的未来发展\n\n### 1. 多模态RAG\n\n未来的RAG系统将能够处理文本、图像、音频等多种类型的信息，提供更丰富的交互体验。\n\n### 2. 自适应检索\n\n系统将能够根据用户的历史行为和偏好，动态调整检索策略。\n\n### 3. 实时学习\n\nRAG系统将能够在运行过程中持续学习和改进，提高检索和生成的质量。\n\n## 总结\n\nRAG技术代表了AI应用的一个重要发展方向，它通过结合检索和生成的优势，为构建更智能、更可靠的AI系统提供了新的可能性。随着技术的不断发展，RAG将在更多领域发挥重要作用，推动AI技术的普及和应用。\n\n---\n\n*本文介绍了RAG技术的基本概念、工作原理、优势挑战以及应用场景。RAG技术正在改变我们与AI系统交互的方式，为构建更智能的应用提供了强大的技术基础。*', 'RAG（检索增强生成）技术是一种结合信息检索和文本生成的AI技术。本文深入介绍了RAG的核心组件、工作流程、优势挑战、应用场景以及未来发展趋势。', NULL, 1, 1, 0, 1, '2025-10-06 12:21:23', '2025-10-06 12:21:23');
COMMIT;

-- ----------------------------
-- Table structure for post_columns
-- ----------------------------
DROP TABLE IF EXISTS `post_columns`;
CREATE TABLE `post_columns` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `post_id` int NOT NULL COMMENT '文章ID',
  `column_id` int NOT NULL COMMENT '专栏ID',
  `sort_order` int DEFAULT '0' COMMENT '在专栏中的排序顺序',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_column` (`post_id`,`column_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_column_id` (`column_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_post_columns_column_id` FOREIGN KEY (`column_id`) REFERENCES `columns` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_post_columns_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章专栏关联表';

-- ----------------------------
-- Records of post_columns
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for post_stats
-- ----------------------------
DROP TABLE IF EXISTS `post_stats`;
CREATE TABLE `post_stats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `view_count` int NOT NULL DEFAULT '0' COMMENT '观看次数',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞次数',
  `share_count` int NOT NULL DEFAULT '0' COMMENT '分享次数',
  `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论次数',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `post_id` (`post_id`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_share_count` (`share_count`),
  KEY `idx_comment_count` (`comment_count`),
  CONSTRAINT `fk_post_stats_post_id` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章统计数据表';

-- ----------------------------
-- Records of post_stats
-- ----------------------------
BEGIN;
INSERT INTO `post_stats` (`id`, `post_id`, `view_count`, `like_count`, `share_count`, `comment_count`, `created_at`, `updated_at`) VALUES (1, 1, 1, 0, 0, 0, '2025-10-06 12:41:33', '2025-10-06 12:41:33');
INSERT INTO `post_stats` (`id`, `post_id`, `view_count`, `like_count`, `share_count`, `comment_count`, `created_at`, `updated_at`) VALUES (2, 6, 17, 0, 0, 0, '2025-10-06 12:43:37', '2025-10-06 12:43:37');
INSERT INTO `post_stats` (`id`, `post_id`, `view_count`, `like_count`, `share_count`, `comment_count`, `created_at`, `updated_at`) VALUES (3, 5, 1, 0, 0, 0, '2025-10-08 09:36:36', '2025-10-08 09:36:36');
COMMIT;

-- ----------------------------
-- Table structure for system_defaults
-- ----------------------------
DROP TABLE IF EXISTS `system_defaults`;
CREATE TABLE `system_defaults` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key_value` text COLLATE utf8mb4_unicode_ci,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_type` enum('string','number','boolean','json','url') COLLATE utf8mb4_unicode_ci DEFAULT 'string',
  `is_editable` tinyint(1) DEFAULT '1',
  `is_public` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category_key` (`category`,`key_name`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of system_defaults
-- ----------------------------
BEGIN;
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (56, 'user', 'default_avatar', 'http://localhost:5173/uploads/images/e41d1f3cdbda444ca1efcd6f1ee4385f.png', '默认用户头像', 'url', 1, 1, 1, '2025-09-24 09:59:27', '2025-09-25 00:55:17');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (57, 'user', 'default_nickname', '匿名用户', '默认用户昵称', 'string', 1, 1, 2, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (58, 'user', 'default_bio', '这个人很懒，什么都没有留下...', '默认个人简介', 'string', 1, 1, 3, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (59, 'blog', 'default_title', 'MikkoBlog', '默认博客标题', 'string', 1, 1, 1, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (60, 'blog', 'default_subtitle', '一个简洁优雅的博客系统', '默认博客副标题', 'string', 1, 1, 2, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (61, 'blog', 'default_motto', 'Stay hungry, stay foolish', '默认个人格言', 'string', 1, 1, 3, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (62, 'blog', 'default_theme', 'anime', '默认主题', 'string', 1, 1, 4, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (63, 'blog', 'posts_per_page', '10', '每页显示文章数', 'number', 1, 1, 5, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (64, 'blog', 'enable_comments', 'true', '是否启用评论', 'boolean', 1, 1, 6, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (65, 'system', 'site_name', 'MikkoBlog', '网站名称', 'string', 1, 1, 1, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (66, 'system', 'site_description', '一个基于Vue3和FastAPI的现代化博客系统', '网站描述', 'string', 1, 1, 2, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (67, 'system', 'site_keywords', '博客,技术,编程,Vue3,FastAPI', '网站关键词', 'string', 1, 1, 3, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (68, 'frontend', 'loading_text', '加载中...', '加载提示文字', 'string', 1, 1, 1, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (69, 'frontend', 'no_more_data_text', '没有更多内容了', '无更多数据提示', 'string', 1, 1, 2, '2025-09-24 09:59:27', '2025-09-24 09:59:27');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (70, 'system', 'admin_email', 'admin@example.com', '管理员邮箱', 'string', 1, 0, 4, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (71, 'system', 'maintenance_mode', 'false', '维护模式', 'boolean', 1, 1, 5, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (72, 'upload', 'max_file_size', '5242880', '最大文件大小（字节）', 'number', 1, 0, 1, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (73, 'upload', 'allowed_image_types', 'jpg,jpeg,png,gif,webp', '允许的图片类型', 'string', 1, 0, 2, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (74, 'upload', 'upload_path', '/uploads', '上传路径', 'string', 1, 0, 3, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (75, 'upload', 'avatar_path', '/uploads/avatars', '头像上传路径', 'string', 1, 0, 4, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (76, 'social', 'github_url', '', 'GitHub链接', 'url', 1, 1, 1, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (77, 'social', 'twitter_url', '', 'Twitter链接', 'url', 1, 1, 2, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (78, 'social', 'weibo_url', '', '微博链接', 'url', 1, 1, 3, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (79, 'social', 'website_url', '', '个人网站链接', 'url', 1, 1, 4, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (80, 'frontend', 'error_404_title', '页面未找到', '404错误标题', 'string', 1, 1, 3, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (81, 'frontend', 'error_404_message', '抱歉，您访问的页面不存在', '404错误信息', 'string', 1, 1, 4, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (82, 'security', 'password_min_length', '8', '密码最小长度', 'number', 1, 1, 3, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (83, 'analytics', 'enable_analytics', 'false', '是否启用统计', 'boolean', 1, 1, 1, '2025-09-24 09:59:47', '2025-09-24 09:59:47');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (94, 'homepage', 'default_banner_image', '/uploads/images/20251001_090841_1a218894.jpg', '默认用户卡片Banner图片', 'url', 1, 1, 1, '2025-10-01 06:30:51', '2025-10-01 06:32:35');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (95, 'homepage', 'default_background_image', '/uploads/images/20251001_111433_b13b85a7.jpeg', '默认博客全背景图片', 'url', 1, 1, 2, '2025-10-01 06:30:51', '2025-10-01 06:32:40');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (96, 'homepage', 'default_show_music_player', 'false', '默认是否显示音乐模块', 'boolean', 1, 1, 3, '2025-10-01 06:30:51', '2025-10-01 06:30:51');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (97, 'homepage', 'default_music_url', '', '默认音乐地址', 'url', 1, 1, 4, '2025-10-01 06:30:51', '2025-10-01 06:30:51');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (98, 'homepage', 'default_show_live2d', 'false', '默认是否显示Live2D看板娘', 'boolean', 1, 1, 5, '2025-10-01 06:30:51', '2025-10-01 06:30:51');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (99, 'homepage', 'banner_image_url', '/uploads/images/20251001_090841_1a218894.jpg', 'homepage setting banner_image_url', 'url', 1, 1, 0, '2025-10-01 06:35:16', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (100, 'homepage', 'background_image_url', '/uploads/images/20251001_111433_b13b85a7.jpeg', 'homepage setting background_image_url', 'url', 1, 1, 0, '2025-10-01 06:35:16', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (101, 'homepage', 'show_music_player', '0', 'homepage setting show_music_player', 'boolean', 1, 1, 0, '2025-10-01 06:35:16', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (102, 'homepage', 'music_url', '', 'homepage setting music_url', 'url', 1, 1, 0, '2025-10-01 06:35:16', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (103, 'homepage', 'show_live2d', '0', 'homepage setting show_live2d', 'boolean', 1, 1, 0, '2025-10-01 06:35:16', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (104, 'homepage', 'header_title', 'Mikko 的技术小栈', 'homepage setting header_title', 'string', 1, 1, 0, '2025-10-02 01:54:40', '2025-10-08 11:36:03');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (105, 'ImageSearch', 'default_tags', '二次元，风景，美女', '默认搜索标签', 'string', 1, 0, 0, '2025-10-02 23:53:26', '2025-10-03 00:15:48');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (106, 'ImageSearch', 'default_orientation', 'landscape', '默认图片方向', 'string', 1, 0, 1, '2025-10-02 23:53:26', '2025-10-02 23:53:26');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (107, 'ImageSearch', 'column_cover_tags', '', '专栏封面标签', 'string', 1, 0, 2, '2025-10-02 23:53:26', '2025-10-03 00:09:46');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (108, 'ImageSearch', 'search_count', '10', '搜索数量', 'number', 1, 0, 3, '2025-10-02 23:53:26', '2025-10-02 23:53:26');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (109, 'ImageSearch', 'enable_unsplash', 'true', '启用Unsplash', 'boolean', 1, 0, 4, '2025-10-02 23:53:26', '2025-10-02 23:53:26');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (110, 'ImageSearch', 'unsplash_access_key', '', 'Unsplash API Key', 'string', 1, 0, 5, '2025-10-02 23:53:26', '2025-10-02 23:53:26');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (111, 'ImageSearch', 'auto_generate_tags', 'true', '自动生成标签', 'boolean', 1, 0, 6, '2025-10-02 23:53:26', '2025-10-02 23:53:26');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (112, 'ImageSearch', 'tag_mapping_rules', '', '标签映射规则', 'string', 1, 0, 7, '2025-10-02 23:53:26', '2025-10-03 00:01:19');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (113, 'AISettings', 'ai_provider', 'openai', 'AIæœåŠ¡æä¾›å•†', 'string', 1, 0, 1, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (114, 'AISettings', 'ai_model', 'gpt-3.5-turbo', 'AIæ¨¡åž‹åç§°', 'string', 1, 0, 2, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (115, 'AISettings', 'ai_api_key', '', 'AI APIå¯†é’¥', 'string', 1, 0, 3, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (116, 'AISettings', 'ai_base_url', 'https://api.openai.com/v1', 'AI APIåŸºç¡€URL', 'url', 1, 0, 4, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (117, 'AISettings', 'ai_max_tokens', '1000', 'AIæœ€å¤§tokenæ•°', 'number', 1, 0, 5, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (118, 'AISettings', 'ai_temperature', '0.7', 'AIæ¸©åº¦å‚æ•°', 'number', 1, 0, 6, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
INSERT INTO `system_defaults` (`id`, `category`, `key_name`, `key_value`, `description`, `data_type`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (119, 'AISettings', 'ai_prompt_template', 'è¯·ç”Ÿæˆ20ä¸ªä¸Ž\"{keywords}\"ç›¸å…³çš„çƒ­é—¨æŠ€æœ¯æ ‡ç­¾ï¼Œä»¥JSONæ ¼å¼è¿”å›žï¼Œæ ¼å¼ä¸ºï¼š[{\"name\": \"æ ‡ç­¾å\", \"category\": \"åˆ†ç±»\", \"count\": æ•°é‡}]', 'AIæç¤ºè¯æ¨¡æ¿', 'string', 1, 0, 7, '2025-10-05 00:37:41', '2025-10-05 00:37:41');
COMMIT;

-- ----------------------------
-- Table structure for system_setting
-- ----------------------------
DROP TABLE IF EXISTS `system_setting`;
CREATE TABLE `system_setting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'è®¾ç½®åˆ†ç±»',
  `key_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'è®¾ç½®é”®å',
  `key_value` text COLLATE utf8mb4_unicode_ci COMMENT 'è®¾ç½®å€¼',
  `key_type` enum('string','number','boolean','json','url') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string' COMMENT 'å€¼ç±»åž‹',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'è®¾ç½®æè¿°',
  `is_editable` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'æ˜¯å¦å¯ç¼–è¾‘',
  `is_public` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'æ˜¯å¦å…¬å¼€',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT 'æŽ’åº',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'æ›´æ–°æ—¶é—´',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category_key` (`category`,`key_name`),
  KEY `idx_category` (`category`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ç³»ç»Ÿè®¾ç½®è¡¨';

-- ----------------------------
-- Records of system_setting
-- ----------------------------
BEGIN;
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (14, 'site', 'logo', '', 'url', '网站Logo', 1, 1, 4, '2025-10-05 08:31:54', '2025-10-05 08:56:51');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (15, 'site', 'favicon', '', 'url', '网站图标', 1, 1, 5, '2025-10-05 08:31:54', '2025-10-05 08:56:53');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (16, 'email', 'smtp_host', '', 'string', 'SMTP服务器', 1, 0, 1, '2025-10-05 08:31:54', '2025-10-05 08:58:41');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (17, 'email', 'smtp_port', '587', 'number', 'SMTP端口', 1, 0, 2, '2025-10-05 08:31:54', '2025-10-05 08:58:45');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (18, 'email', 'smtp_user', '', 'string', 'SMTP用户名', 1, 0, 3, '2025-10-05 08:31:54', '2025-10-05 08:58:48');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (19, 'email', 'smtp_password', '', 'string', 'SMTP密码', 1, 0, 4, '2025-10-05 08:31:54', '2025-10-05 08:58:51');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (20, 'email', 'smtp_ssl', 'true', 'boolean', '是否启用SSL', 1, 0, 5, '2025-10-05 08:31:54', '2025-10-05 08:58:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (21, 'ai', 'provider', 'deepseek', 'string', 'AI服务提供商', 1, 0, 1, '2025-10-05 08:49:11', '2025-10-05 23:51:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (22, 'ai', 'model', 'deepseek-chat', 'string', 'AI模型名称', 1, 0, 2, '2025-10-05 08:49:11', '2025-10-05 23:51:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (23, 'ai', 'api_key', 'sk-5ee325af1ab544fa8345c298af498f75', 'string', 'AI API密钥', 1, 0, 3, '2025-10-05 08:49:11', '2025-10-05 23:57:36');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (24, 'ai', 'base_url', 'https://api.deepseek.com/v1', 'url', 'AI API基础URL', 1, 0, 4, '2025-10-05 08:49:11', '2025-10-05 23:51:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (25, 'ai', 'max_tokens', '1000', 'number', 'AI最大token数', 1, 0, 5, '2025-10-05 08:49:11', '2025-10-05 08:49:11');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (26, 'ai', 'temperature', '0.7', 'number', 'AI温度参数', 1, 0, 6, '2025-10-05 08:49:11', '2025-10-05 08:49:11');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (27, 'ai', 'prompt_template', '请生成20个与\"{keywords}\"相关的热门技术标签，以JSON格式返回，格式为：[{\"name\": \"标签名\", \"category\": \"分类\", \"count\": 数量}]', 'string', 'AI提示词模板', 1, 0, 7, '2025-10-05 08:49:11', '2025-10-06 04:30:53');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (28, 'ai', 'enabled', 'true', 'boolean', '是否启用AI功能', 1, 0, 8, '2025-10-05 08:49:11', '2025-10-05 08:49:11');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (29, 'ai', 'timeout', '30', 'number', 'AI请求超时时间(秒)', 1, 0, 9, '2025-10-05 08:49:11', '2025-10-05 08:49:11');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (30, 'ai', 'retry_count', '3', 'number', 'AI请求重试次数', 1, 0, 10, '2025-10-05 08:49:11', '2025-10-05 08:49:11');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (31, 'site', 'description', '个人技术博客', 'string', '网站描述', 1, 1, 1, '2025-10-05 08:56:41', '2025-10-05 08:56:41');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (32, 'site', 'keywords', '技术,博客,编程', 'string', '网站关键词', 1, 1, 2, '2025-10-05 08:56:41', '2025-10-05 08:56:41');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (33, 'ai', 'search_keywords', '[\"AI 大模型应用开发\", \"机器学习\", \"深度学习\", \"神经网络\", \"Vue\", \"React\", \"Python\", \"Web开发\", \"Java\"]', 'json', 'AI搜索关键词', 1, 0, 1, '2025-10-06 04:30:53', '2025-10-06 04:32:22');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (34, 'schedule', 'schedule_frequency', 'weekly', 'string', '调度配置 - schedule_frequency', 1, 0, 0, '2025-10-06 09:33:56', '2025-10-06 09:33:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (35, 'schedule', 'schedule_time', '02:00', 'string', '调度配置 - schedule_time', 1, 0, 0, '2025-10-06 09:33:56', '2025-10-06 09:33:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (36, 'schedule', 'schedule_day', 'monday', 'string', '调度配置 - schedule_day', 1, 0, 0, '2025-10-06 09:33:56', '2025-10-06 09:33:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (37, 'schedule', 'next_run_time', '2025-10-13T02:00:00', 'string', '调度配置 - next_run_time', 1, 0, 0, '2025-10-06 09:33:56', '2025-10-06 09:33:56');
INSERT INTO `system_setting` (`id`, `category`, `key_name`, `key_value`, `key_type`, `description`, `is_editable`, `is_public`, `sort_order`, `created_at`, `updated_at`) VALUES (38, 'music', 'auto_play', 'false', 'boolean', '进入博客时是否自动播放音乐', 1, 1, 0, '2025-10-08 02:57:25', '2025-10-08 10:51:22');
COMMIT;

-- ----------------------------
-- Table structure for tag_cloud
-- ----------------------------
DROP TABLE IF EXISTS `tag_cloud`;
CREATE TABLE `tag_cloud` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签名称',
  `count` int DEFAULT '1' COMMENT '使用次数',
  `size` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'medium' COMMENT '标签大小: small, medium, large',
  `color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#ff6b6b' COMMENT '标签颜色',
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'general' COMMENT '标签分类',
  `source` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'manual' COMMENT '来源: manual, auto, trending',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否激活',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_fetched_at` timestamp NULL DEFAULT NULL COMMENT '最后获取时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`),
  KEY `idx_category` (`category`),
  KEY `idx_source` (`source`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_count` (`count` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云表';

-- ----------------------------
-- Records of tag_cloud
-- ----------------------------
BEGIN;
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (100, 'PyTorch', 15600, 'large', '#8e44ad', '深度学习', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (101, 'TensorFlow', 14200, 'large', '#e91e63', '机器学习', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (102, 'LLM', 13800, 'large', '#16a085', 'AI 大模型', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (103, 'Next.js', 12500, 'large', '#fce4ec', 'Web开发', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (104, 'Spring Boot', 11800, 'large', '#e74c3c', 'Java', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (105, 'Transformers', 11200, 'large', '#f8bbd9', '神经网络', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (106, 'FastAPI', 9800, 'large', '#27ae60', 'Python', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (107, '微前端', 9200, 'large', '#fce4ec', 'Web开发', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (108, 'LangChain', 8700, 'large', '#f7dc6f', 'AI 大模型应用', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (109, 'TypeScript', 8500, 'large', '#fce4ec', 'Web开发', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (110, '计算机视觉', 8200, 'large', '#8e44ad', '深度学习', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (111, 'Nuxt.js', 7600, 'large', '#8e44ad', 'Vue', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (112, 'Prompt Engineering', 7300, 'large', '#16a085', 'AI 大模型', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (113, 'Scikit-learn', 7100, 'large', '#e91e63', '机器学习', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (114, 'React Native', 6800, 'large', '#8e44ad', 'React', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (115, '卷积神经网络', 6500, 'large', '#f8bbd9', '神经网络', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (116, '微服务', 6200, 'large', '#e74c3c', 'Java', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (117, '生成式AI', 5900, 'large', '#f7dc6f', 'AI 大模型应用', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (118, 'Pandas', 5600, 'large', '#27ae60', 'Python', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
INSERT INTO `tag_cloud` (`id`, `name`, `count`, `size`, `color`, `category`, `source`, `is_active`, `created_at`, `updated_at`, `last_fetched_at`) VALUES (119, 'Vite', 5300, 'large', '#8e44ad', 'Vue', 'auto', 1, '2025-10-06 09:17:47', '2025-10-06 09:17:47', '2025-10-06 09:17:47');
COMMIT;

-- ----------------------------
-- Table structure for tag_cloud_fetch_history
-- ----------------------------
DROP TABLE IF EXISTS `tag_cloud_fetch_history`;
CREATE TABLE `tag_cloud_fetch_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fetch_date` date NOT NULL COMMENT '获取日期',
  `source` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '数据源',
  `total_tags` int DEFAULT '0' COMMENT '获取的标签总数',
  `new_tags` int DEFAULT '0' COMMENT '新增标签数',
  `updated_tags` int DEFAULT '0' COMMENT '更新标签数',
  `status` enum('success','failed','partial') COLLATE utf8mb4_unicode_ci DEFAULT 'success' COMMENT '获取状态',
  `error_message` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fetch_date_source` (`fetch_date`,`source`),
  KEY `idx_fetch_date` (`fetch_date` DESC),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签云获取历史表';

-- ----------------------------
-- Records of tag_cloud_fetch_history
-- ----------------------------
BEGIN;
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (1, '2025-10-04', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-04 10:57:57');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (7, '2025-10-05', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-04 18:00:16');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (12, '2025-10-06', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-05 18:10:28');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (17, '2025-10-07', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-06 18:29:43');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (18, '2025-10-08', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-07 18:00:57');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (19, '2025-10-09', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-08 18:00:12');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (20, '2025-10-10', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-09 18:00:43');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (21, '2025-10-11', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-10 18:22:24');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (22, '2025-10-12', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-11 18:35:19');
INSERT INTO `tag_cloud_fetch_history` (`id`, `fetch_date`, `source`, `total_tags`, `new_tags`, `updated_tags`, `status`, `error_message`, `created_at`) VALUES (23, '2025-10-13', 'multiple', 0, 0, 0, 'success', NULL, '2025-10-12 18:00:08');
COMMIT;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `email` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_admin` tinyint(1) NOT NULL,
  `id` int NOT NULL AUTO_INCREMENT,
  `hashed_password` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user
-- ----------------------------
BEGIN;
INSERT INTO `user` (`email`, `full_name`, `is_active`, `is_admin`, `id`, `hashed_password`, `created_at`, `updated_at`) VALUES ('yaoqiwood@gmail.com', 'Mikko', 1, 1, 1, '$2b$12$aKWJdylE9YXDTwGc0RKzvOcQTU6oURKzR2/eDqDybjZjQ38Xhjkki', '2025-09-22 13:04:42', '2025-09-22 13:04:42');
COMMIT;

-- ----------------------------
-- Table structure for user_profiles
-- ----------------------------
DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '关联用户ID',
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱地址',
  `bio` text COLLATE utf8mb4_unicode_ci COMMENT '个人简介',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `blog_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '博客标题',
  `blog_subtitle` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '博客副标题',
  `motto` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '个人格言',
  `github_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'GitHub链接',
  `twitter_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Twitter链接',
  `weibo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微博链接',
  `website_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '个人网站链接',
  `qq_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QQ号码',
  `location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所在地',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `gender` enum('male','female','other','private') COLLATE utf8mb4_unicode_ci DEFAULT 'private' COMMENT '性别',
  `is_public` tinyint(1) DEFAULT '1' COMMENT '是否公开个人信息',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_nickname` (`nickname`),
  KEY `idx_email` (`email`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_user_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户个人信息表';

-- ----------------------------
-- Records of user_profiles
-- ----------------------------
BEGIN;
INSERT INTO `user_profiles` (`id`, `user_id`, `nickname`, `email`, `bio`, `avatar`, `blog_title`, `blog_subtitle`, `motto`, `github_url`, `twitter_url`, `weibo_url`, `website_url`, `qq_number`, `location`, `birthday`, `gender`, `is_public`, `created_at`, `updated_at`) VALUES (2, 1, 'Mikko', 'yaoqiwood@gmail.com', '一个技术工作者', '/uploads/images/e41d1f3cdbda444ca1efcd6f1ee4385f.png', 'Mikko', ' 的技术小栈', '“Stay hungry, stay foolish.”（保持饥饿，保持愚蠢）', '', '', '', '', NULL, NULL, NULL, 'private', 1, '2025-09-30 11:00:31', '2025-10-06 09:34:59');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
