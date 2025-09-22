<template>
  <div class="post-management">
    <div class="page-header">
      <h1 class="page-title">文章管理</h1>
      <div class="page-actions">
        <Button type="primary" icon="ios-refresh" @click="fetchPosts">刷新</Button>
        <Button type="success" icon="ios-create" @click="showAddPost = true">添加文章</Button>
      </div>
    </div>

    <Card>
      <template #title>
        <Icon type="ios-document" />
        文章列表
      </template>

      <Table :data="posts" :loading="loading" stripe>
        <TableColumn prop="id" label="ID" width="80"></TableColumn>
        <TableColumn prop="title" label="标题" min-width="200"></TableColumn>
        <TableColumn prop="summary" label="摘要" min-width="150"></TableColumn>
        <TableColumn prop="created_at" label="创建时间" min-width="150">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </TableColumn>
        <TableColumn label="操作" width="150">
          <template #default="{ row }">
            <Button type="primary" size="small" icon="ios-create" @click="editPost(row)"
              >编辑</Button
            >
            <Button
              type="error"
              size="small"
              icon="ios-trash"
              @click="deletePost(row)"
              style="margin-left: 8px"
              >删除</Button
            >
          </template>
        </TableColumn>
      </Table>
    </Card>
  </div>
</template>

<script setup>
import { postApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';

const posts = ref([]);
const loading = ref(false);
const showAddPost = ref(false);

async function fetchPosts() {
  try {
    loading.value = true;
    const data = await postApi.getPosts();
    posts.value = data;
  } catch (error) {
    console.error('获取文章列表失败:', error);
    Message.error('获取文章列表失败');
  } finally {
    loading.value = false;
  }
}

function editPost(post) {
  Message.info('编辑文章功能开发中...');
}

function deletePost(post) {
  Message.info('删除文章功能开发中...');
}

function formatDate(dateString) {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN');
}

onMounted(() => {
  fetchPosts();
});
</script>

<style scoped>
.post-management {
  /* max-width: 1200px; */
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.page-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2d3748;
  margin: 0;
}

.page-actions {
  display: flex;
  gap: 0.75rem;
}
</style>
