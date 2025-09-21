<template>
  <div class="user-management">
    <div class="page-header">
      <h1 class="page-title">用户管理</h1>
      <div class="page-actions">
        <Button type="primary" icon="ios-refresh" @click="fetchUsers">刷新</Button>
        <Button type="success" icon="ios-person-add" @click="showAddUser = true">添加用户</Button>
      </div>
    </div>

    <!-- 用户列表 -->
    <Card>
      <template #title>
        <Icon type="ios-people" />
        用户列表
      </template>

      <Table :data="users" :loading="loading" stripe>
        <TableColumn prop="id" label="ID" width="80"></TableColumn>
        <TableColumn prop="email" label="邮箱" min-width="200"></TableColumn>
        <TableColumn prop="full_name" label="姓名" min-width="150"></TableColumn>
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
        <TableColumn prop="created_at" label="创建时间" min-width="150">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </TableColumn>
        <TableColumn label="操作" width="150">
          <template #default="{ row }">
            <Button type="primary" size="small" icon="ios-create" @click="editUser(row)">
              编辑
            </Button>
            <Button
              type="error"
              size="small"
              icon="ios-trash"
              @click="deleteUser(row)"
              style="margin-left: 8px"
            >
              删除
            </Button>
          </template>
        </TableColumn>
      </Table>
    </Card>

    <!-- 添加用户模态框 -->
    <Modal v-model="showAddUser" title="添加用户" :mask-closable="false">
      <Form ref="addUserForm" :model="newUser" :rules="userRules" label-position="top">
        <FormItem label="邮箱地址" prop="email">
          <Input v-model="newUser.email" placeholder="请输入邮箱地址" />
        </FormItem>
        <FormItem label="姓名" prop="full_name">
          <Input v-model="newUser.full_name" placeholder="请输入姓名" />
        </FormItem>
        <FormItem label="密码" prop="password">
          <Input v-model="newUser.password" type="password" placeholder="请输入密码" />
        </FormItem>
        <FormItem label="管理员权限">
          <Switch v-model="newUser.is_admin" />
        </FormItem>
        <FormItem label="激活状态">
          <Switch v-model="newUser.is_active" />
        </FormItem>
      </Form>

      <template #footer>
        <Button @click="showAddUser = false">取消</Button>
        <Button type="primary" @click="addUser" :loading="adding">确定</Button>
      </template>
    </Modal>

    <!-- 编辑用户模态框 -->
    <Modal v-model="showEditUser" title="编辑用户" :mask-closable="false">
      <Form ref="editUserForm" :model="editingUser" :rules="editUserRules" label-position="top">
        <FormItem label="邮箱地址" prop="email">
          <Input v-model="editingUser.email" placeholder="请输入邮箱地址" />
        </FormItem>
        <FormItem label="姓名" prop="full_name">
          <Input v-model="editingUser.full_name" placeholder="请输入姓名" />
        </FormItem>
        <FormItem label="管理员权限">
          <Switch v-model="editingUser.is_admin" />
        </FormItem>
        <FormItem label="激活状态">
          <Switch v-model="editingUser.is_active" />
        </FormItem>
      </Form>

      <template #footer>
        <Button @click="showEditUser = false">取消</Button>
        <Button type="primary" @click="updateUser" :loading="updating">确定</Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { userApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';

// 数据状态
const users = ref([]);
const loading = ref(false);
const adding = ref(false);
const updating = ref(false);

// 模态框状态
const showAddUser = ref(false);
const showEditUser = ref(false);

// 表单数据
const newUser = ref({
  email: '',
  full_name: '',
  password: '',
  is_admin: false,
  is_active: true,
});

const editingUser = ref({
  id: null,
  email: '',
  full_name: '',
  is_admin: false,
  is_active: true,
});

// 表单验证规则
const userRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  full_name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, message: '姓名长度不能少于2位', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' },
  ],
};

const editUserRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  full_name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, message: '姓名长度不能少于2位', trigger: 'blur' },
  ],
};

// 获取用户列表
async function fetchUsers() {
  try {
    loading.value = true;
    const data = await userApi.getUsers();
    users.value = data;
  } catch (error) {
    console.error('获取用户列表失败:', error);
    Message.error('获取用户列表失败');
  } finally {
    loading.value = false;
  }
}

// 添加用户
async function addUser() {
  try {
    adding.value = true;
    // 这里应该调用API添加用户
    // await userApi.createUser(newUser.value);

    Message.success('用户添加成功');
    showAddUser.value = false;
    resetNewUser();
    await fetchUsers();
  } catch (error) {
    console.error('添加用户失败:', error);
    Message.error('添加用户失败');
  } finally {
    adding.value = false;
  }
}

// 编辑用户
function editUser(user) {
  editingUser.value = { ...user };
  showEditUser.value = true;
}

// 更新用户
async function updateUser() {
  try {
    updating.value = true;
    // 这里应该调用API更新用户
    // await userApi.updateUser(editingUser.value.id, editingUser.value);

    Message.success('用户更新成功');
    showEditUser.value = false;
    await fetchUsers();
  } catch (error) {
    console.error('更新用户失败:', error);
    Message.error('更新用户失败');
  } finally {
    updating.value = false;
  }
}

// 删除用户
async function deleteUser(user) {
  try {
    // 这里应该调用API删除用户
    // await userApi.deleteUser(user.id);

    Message.success('用户删除成功');
    await fetchUsers();
  } catch (error) {
    console.error('删除用户失败:', error);
    Message.error('删除用户失败');
  }
}

// 重置新用户表单
function resetNewUser() {
  newUser.value = {
    email: '',
    full_name: '',
    password: '',
    is_admin: false,
    is_active: true,
  };
}

// 格式化日期
function formatDate(dateString) {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

onMounted(() => {
  fetchUsers();
});
</script>

<style scoped>
.user-management {
  max-width: 1200px;
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

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .page-actions {
    justify-content: center;
  }
}
</style>
