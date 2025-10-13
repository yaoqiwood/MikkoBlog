# Live2D 看板娘集成说明

## 概述

本项目已成功集成了 vue-live2d 看板娘组件，为博客添加了可爱的 Live2D 角色。集成严格按照 [vue-live2d 官方文档](https://github.com/evgo2017/vue-live2d) 进行配置。

## 功能特性

- ✅ 支持多种 Live2D 模型
- ✅ 使用默认提示语（支持中文）
- ✅ 响应式设计，适配移动端
- ✅ 鼠标交互效果
- ✅ 模型切换和换装功能
- ✅ 固定定位，不影响页面布局

## 配置说明

### 主要参数（严格按照官方文档）

- **apiPath**: Live2D 模型 API 地址（使用在线 API）
- **size**: 模型大小（280px）
- **model**: 默认显示的模型和服装（Potion-Maker/Pio, school-2017-costume-yellow）
- **direction**: 模型位置（right）
- **tipPosition**: 提示框位置（top）
- **homePage**: 主页链接（https://github.com/evgo2017/vue-live2d）
- **customId**: 自定义 ID（mikko-blog-waifu）

### 属性名规范

严格按照 vue-live2d 源码使用 camelCase 属性名：
- `:apiPath`（不是 `:api-path`）
- `:tipPosition`（不是 `:tip-position`）
- `:homePage`（不是 `:home-page`）
- `:customId`（不是 `:custom-id`）

## 使用方法

1. 组件已自动集成到 `App.vue` 中
2. 看板娘会显示在页面右下角
3. 支持点击切换模型和换装
4. 支持鼠标交互和提示语

## 技术实现

- 使用 `vue-live2d` 包
- 在线 API 加载模型（无需本地文件）
- Vue 3 Composition API
- 响应式 CSS 设计

## 注意事项

- 首次加载可能需要一些时间下载模型文件
- 确保网络连接正常以加载在线模型
- 如需使用本地模型，请下载模型文件到 `public/live2d-static-api/` 目录

## 在线演示

- 官方演示: https://vue-live2d.demo.evgo2017.com/
- GitHub 仓库: https://github.com/evgo2017/vue-live2d
