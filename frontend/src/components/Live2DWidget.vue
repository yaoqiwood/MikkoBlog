<template>
  <!-- Vue Live2D 看板娘 -->
  <vue-live2d
    v-if="shouldShowLive2D"
    :api-path="apiPath"
    :size="size"
    :width="width"
    :height="height"
    :model="model"
    :direction="direction"
    :tip-position="tipPosition"
    :tips="tips"
    :home-page="homePage"
    :custom-id="customId"
  />
</template>

<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import vueLive2d from 'vue-live2d';

const route = useRoute();

// 检查是否应该显示看板娘
const shouldShowLive2D = computed(() => {
  // 不在管理页面显示
  return !route.path.startsWith('/admin');
});

// 配置参数
const apiPath =
  'https://raw.githubusercontent.com/evgo2017/live2d-static-api/refs/heads/main/indexes';
const size = 255;
const width = 0;
const height = 0;
const model = ['Potion-Maker/Pio', 'school-2017-costume-yello'];
const direction = 'right';
const tipPosition = 'top';
const homePage = 'https://github.com/yaoqiwood/MikkoBlog';
const customId = 'mikko-live2d';

// 自定义提示语
const tips = {
  welcome: ['欢迎来到 MikkoBlog！', '今天也要加油哦~', '有什么想了解的吗？'],
  click: ['点击我有什么奖励吗？', '嘿嘿，被你发现了~', '再点一下试试看？'],
  mouseover: ['鼠标滑过我了呢~', '想和我互动吗？', '我在这里等你哦'],
  timeout: ['你还在吗？', '不要走嘛~', '回来陪我聊天吧']
};
</script>

<style scoped>
/* vue-live2d 组件会自动处理样式 */
</style>