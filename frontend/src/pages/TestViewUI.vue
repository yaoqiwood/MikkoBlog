<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-6">View UI Plus 测试页面</h1>

    <!-- 按钮测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">按钮组件</h2>
      <div class="space-x-3">
        <Button type="primary">主要按钮</Button>
        <Button type="success">成功按钮</Button>
        <Button type="warning">警告按钮</Button>
        <Button type="error">错误按钮</Button>
        <Button type="info">信息按钮</Button>
      </div>
    </div>

    <!-- 输入框测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">输入框组件</h2>
      <div class="space-y-3">
        <Input placeholder="普通输入框" />
        <Input type="password" placeholder="密码输入框" />
        <Input type="textarea" placeholder="多行文本输入框" :rows="3" />
      </div>
    </div>

    <!-- 卡片测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">卡片组件</h2>
      <Card>
        <template #title>
          <Icon type="ios-document" />
          测试卡片
        </template>
        <p>这是一个使用View UI Plus的卡片组件。</p>
        <template #extra>
          <Tag color="blue">标签</Tag>
        </template>
      </Card>
    </div>

    <!-- 表格测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">表格组件</h2>
      <Table :data="testData" stripe>
        <TableColumn prop="name" label="姓名" />
        <TableColumn prop="age" label="年龄" />
        <TableColumn prop="city" label="城市" />
      </Table>
    </div>

    <!-- 消息提示测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">消息提示</h2>
      <div class="space-x-3">
        <Button @click="showSuccess">成功消息</Button>
        <Button @click="showError">错误消息</Button>
        <Button @click="showWarning">警告消息</Button>
        <Button @click="showInfo">信息消息</Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Message } from 'view-ui-plus';
import { ref } from 'vue';

const testData = ref([
  { name: '张三', age: 25, city: '北京' },
  { name: '李四', age: 30, city: '上海' },
  { name: '王五', age: 28, city: '广州' },
]);

const showSuccess = () => {
  Message.success('这是一个成功消息！');
};

const showError = () => {
  Message.error('这是一个错误消息！');
};

const showWarning = () => {
  Message.warning('这是一个警告消息！');
};

const showInfo = () => {
  Message.info('这是一个信息消息！');
};
</script>
