<script setup>
import { userApi } from '@/utils/apiService';
import { getRoutePath, routerUtils, ROUTES } from '@/utils/routeManager';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const users = ref([]);
const error = ref('');
const loading = ref(false);

// 路由路径常量
const homePath = getRoutePath(ROUTES.HOME);

async function fetchUsers() {
  const token = localStorage.getItem('token');
  if (!token) {
    routerUtils.navigateTo(router, ROUTES.LOGIN);
    return;
  }
  try {
    loading.value = true;
    const data = await userApi.getUsers();
    users.value = data;
  } catch (error) {
    error.value = '需要管理员权限，请重新登录';
    Message.error('需要管理员权限，请重新登录');
    routerUtils.navigateTo(router, ROUTES.LOGIN);
  } finally {
    loading.value = false;
  }
}

onMounted(fetchUsers);
</script>

<template>
  <div class="page-container min-h-screen bg-gray-50">
    <div class="max-w-6xl mx-auto py-10 px-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold">用户管理</h1>
        <div class="space-x-3">
          <Button type="primary" icon="ios-refresh" @click="fetchUsers">刷新</Button>
          <router-link :to="homePath">
            <Button icon="ios-arrow-back">返回首页</Button>
          </router-link>
        </div>
      </div>

      <Alert v-if="error" type="error" show-icon class="mb-4">
        {{ error }}
      </Alert>

      <Card>
        <template #title>
          <Icon type="ios-people" />
          用户列表
        </template>
        <Table :data="users" :loading="loading" stripe>
          <TableColumn prop="id" label="ID" width="80" />
          <TableColumn prop="email" label="邮箱" min-width="200" />
          <TableColumn prop="full_name" label="姓名" min-width="150" />
          <TableColumn prop="is_admin" label="管理员" width="100">
            <template #default="{ row }">
              <Tag :color="row.is_admin ? 'success' : 'default'">
                {{ row.is_admin ? '是' : '否' }}
              </Tag>
            </template>
          </TableColumn>
          <TableColumn prop="is_active" label="状态" width="100">
            <template #default="{ row }">
              <Tag :color="row.is_active ? 'success' : 'error'">
                {{ row.is_active ? '活跃' : '禁用' }}
              </Tag>
            </template>
          </TableColumn>
        </Table>
      </Card>
    </div>
  </div>
</template>
