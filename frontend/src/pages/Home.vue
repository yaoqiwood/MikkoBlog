<script setup>
import { postApi } from '@/utils/apiService';
import { getRoutePath, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';

const posts = ref([]);
const title = ref('');
const content = ref('');
const summary = ref('');
const loading = ref(false);
const error = ref('');

async function fetchPosts() {
  try {
    const data = await postApi.getPosts();
    posts.value = data;
  } catch (err) {
    console.error('获取文章列表失败:', err);
    error.value = '获取文章列表失败';
  }
}

async function createPost() {
  try {
    loading.value = true;
    error.value = '';
    const payload = { title: title.value, content: content.value, summary: summary.value };
    await postApi.createPost(payload);
    title.value = '';
    content.value = '';
    summary.value = '';
    await fetchPosts();
    Message.success('文章创建成功！');
  } catch {
    error.value = '创建失败';
    Message.error('文章创建失败！');
  } finally {
    loading.value = false;
  }
}

onMounted(fetchPosts);
</script>

<template>
  <div class="page-container min-h-screen bg-gray-50">
    <div class="max-w-3xl mx-auto py-10 px-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold">MikkoBlog Posts</h1>
        <div class="space-x-3">
          <router-link :to="getRoutePath(ROUTES.LOGIN)" class="text-blue-600">登录</router-link>
          <router-link :to="getRoutePath(ROUTES.ADMIN_USERS)" class="text-blue-600"
            >用户管理</router-link
          >
          <router-link :to="getRoutePath(ROUTES.TEST_VIEWUI)" class="text-blue-600"
            >View UI 测试</router-link
          >
          <router-link :to="getRoutePath(ROUTES.TEST_NOT_FOUND)" class="text-blue-600"
            >404 测试</router-link
          >
          <router-link to="/404-demo" class="text-blue-600">404 演示</router-link>
          <router-link to="/fullscreen-test" class="text-blue-600">全屏测试</router-link>
          <router-link to="/cookie-test" class="text-blue-600">Cookie测试</router-link>
          <router-link to="/loading-test" class="text-blue-600">Loading测试</router-link>
        </div>
      </div>

      <Card class="mb-8">
        <template #title>
          <Icon type="ios-create" />
          创建新文章
        </template>
        <Form :model="{ title, content, summary }" @submit.prevent="createPost">
          <FormItem label="标题">
            <Input v-model="title" placeholder="文章标题" />
          </FormItem>
          <FormItem label="摘要">
            <Input v-model="summary" placeholder="简要摘要" />
          </FormItem>
          <FormItem label="内容">
            <Input
              v-model="content"
              type="textarea"
              :rows="4"
              placeholder="Markdown 内容或纯文本"
            />
          </FormItem>
          <FormItem>
            <Button type="primary" :loading="loading" html-type="submit" icon="ios-add">
              提交
            </Button>
            <span v-if="error" class="text-red-600 text-sm ml-3">{{ error }}</span>
          </FormItem>
        </Form>
      </Card>

      <div class="space-y-4">
        <Card v-for="p in posts" :key="p.id" class="mb-4">
          <template #title>
            <Icon type="ios-document" />
            {{ p.title }}
          </template>
          <p class="text-gray-600 mb-3">{{ p.summary }}</p>
          <p class="whitespace-pre-wrap">{{ p.content }}</p>
          <template #extra>
            <Tag color="blue">文章</Tag>
          </template>
        </Card>
      </div>
    </div>
  </div>
</template>
