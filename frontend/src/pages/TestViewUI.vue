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

    <!-- 滚动条测试 -->
    <div class="mb-6">
      <h2 class="text-lg font-semibold mb-3">滚动条测试</h2>
      <div class="space-y-4">
        <!-- 垂直滚动测试 -->
        <div class="border border-gray-300 rounded p-4">
          <h3 class="font-medium mb-2">垂直滚动测试</h3>
          <div class="h-32 overflow-y-auto border border-gray-200 rounded p-2 bg-gray-50">
            <div v-for="i in 20" :key="i" class="p-2 border-b border-gray-100">
              滚动条测试内容 {{ i }} - 这是一个很长的文本内容，用来测试垂直滚动条是否显示为白色主题
            </div>
          </div>
        </div>

        <!-- 水平滚动测试 -->
        <div class="border border-gray-300 rounded p-4">
          <h3 class="font-medium mb-2">水平滚动测试</h3>
          <div class="w-64 overflow-x-auto border border-gray-200 rounded p-2 bg-gray-50">
            <div class="flex space-x-4" style="width: 800px">
              <div
                v-for="i in 10"
                :key="i"
                class="flex-shrink-0 w-32 h-16 bg-blue-100 border border-blue-200 rounded p-2 text-center"
              >
                项目 {{ i }}
              </div>
            </div>
          </div>
        </div>

        <!-- 表格滚动测试 -->
        <div class="border border-gray-300 rounded p-4">
          <h3 class="font-medium mb-2">表格滚动测试</h3>
          <div class="h-40 overflow-auto border border-gray-200 rounded">
            <Table :data="largeTestData" stripe>
              <TableColumn prop="name" label="姓名" width="120" />
              <TableColumn prop="age" label="年龄" width="80" />
              <TableColumn prop="city" label="城市" width="120" />
              <TableColumn prop="email" label="邮箱" width="200" />
              <TableColumn prop="phone" label="电话" width="150" />
              <TableColumn prop="address" label="地址" width="300" />
            </Table>
          </div>
        </div>
      </div>
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

const largeTestData = ref([
  {
    name: '张三',
    age: 25,
    city: '北京',
    email: 'zhangsan@example.com',
    phone: '13800138001',
    address: '北京市朝阳区某某街道123号',
  },
  {
    name: '李四',
    age: 30,
    city: '上海',
    email: 'lisi@example.com',
    phone: '13800138002',
    address: '上海市浦东新区某某路456号',
  },
  {
    name: '王五',
    age: 28,
    city: '广州',
    email: 'wangwu@example.com',
    phone: '13800138003',
    address: '广州市天河区某某大道789号',
  },
  {
    name: '赵六',
    age: 32,
    city: '深圳',
    email: 'zhaoliu@example.com',
    phone: '13800138004',
    address: '深圳市南山区某某科技园101号',
  },
  {
    name: '钱七',
    age: 27,
    city: '杭州',
    email: 'qianqi@example.com',
    phone: '13800138005',
    address: '杭州市西湖区某某路202号',
  },
  {
    name: '孙八',
    age: 29,
    city: '南京',
    email: 'sunba@example.com',
    phone: '13800138006',
    address: '南京市鼓楼区某某街303号',
  },
  {
    name: '周九',
    age: 31,
    city: '成都',
    email: 'zhoujiu@example.com',
    phone: '13800138007',
    address: '成都市锦江区某某广场404号',
  },
  {
    name: '吴十',
    age: 26,
    city: '武汉',
    email: 'wushi@example.com',
    phone: '13800138008',
    address: '武汉市江汉区某某中心505号',
  },
  {
    name: '郑十一',
    age: 33,
    city: '西安',
    email: 'zhengshiyi@example.com',
    phone: '13800138009',
    address: '西安市雁塔区某某大厦606号',
  },
  {
    name: '王十二',
    age: 24,
    city: '重庆',
    email: 'wangshier@example.com',
    phone: '13800138010',
    address: '重庆市渝中区某某商业街707号',
  },
  {
    name: '李十三',
    age: 35,
    city: '天津',
    email: 'lishisan@example.com',
    phone: '13800138011',
    address: '天津市和平区某某广场808号',
  },
  {
    name: '张十四',
    age: 23,
    city: '青岛',
    email: 'zhangshisi@example.com',
    phone: '13800138012',
    address: '青岛市市南区某某路909号',
  },
  {
    name: '刘十五',
    age: 34,
    city: '大连',
    email: 'liushiwu@example.com',
    phone: '13800138013',
    address: '大连市中山区某某中心1010号',
  },
  {
    name: '陈十六',
    age: 22,
    city: '厦门',
    email: 'chenshiliu@example.com',
    phone: '13800138014',
    address: '厦门市思明区某某广场1111号',
  },
  {
    name: '杨十七',
    age: 36,
    city: '苏州',
    email: 'yangshiqi@example.com',
    phone: '13800138015',
    address: '苏州市姑苏区某某街1212号',
  },
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
