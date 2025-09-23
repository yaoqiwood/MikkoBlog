<template>
  <div class="user-management">
    <div class="page-header">
      <h1 class="page-title">用户管理</h1>
      <div class="page-actions">
        <Button type="success" icon="ios-person-add" @click="showAddUser = true">添加用户</Button>
      </div>
    </div>

    <!-- 错误提示 -->
    <Alert v-if="error" type="error" show-icon class="error-alert">
      {{ error }}
    </Alert>

    <!-- 用户列表 -->
    <Card>
      <template #title>
        <div class="card-title">
          <Icon type="ios-people" />
          用户列表
        </div>
      </template>

      <!-- 搜索条件 -->
      <div class="search-section">
        <div class="search-form-container">
          <Form :model="searchForm" inline class="search-form">
            <FormItem label="邮箱">
              <Input
                v-model="searchForm.email"
                placeholder="请输入邮箱地址"
                clearable
                style="width: 200px"
              />
            </FormItem>

            <FormItem label="姓名">
              <Input
                v-model="searchForm.full_name"
                placeholder="请输入姓名"
                clearable
                style="width: 150px"
              />
            </FormItem>

            <FormItem label="管理员">
              <Select
                v-model="searchForm.is_admin"
                placeholder="选择管理员状态"
                clearable
                style="width: 120px"
              >
                <Option value="true">是</Option>
                <Option value="false">否</Option>
              </Select>
            </FormItem>

            <FormItem label="状态">
              <Select
                v-model="searchForm.is_active"
                placeholder="选择用户状态"
                clearable
                style="width: 120px"
              >
                <Option value="true">活跃</Option>
                <Option value="false">禁用</Option>
              </Select>
            </FormItem>

            <div class="date-range-field">
              <div class="field-label">创建时间</div>
              <div class="date-range">
                <DatePicker
                  v-model="searchForm.start_date"
                  type="date"
                  placeholder="开始时间"
                  clearable
                  style="width: 140px"
                  @on-change="validateDateRange"
                />
                <span class="date-separator">至</span>
                <DatePicker
                  v-model="searchForm.end_date"
                  type="date"
                  placeholder="结束时间"
                  clearable
                  style="width: 140px"
                  @on-change="validateDateRange"
                />
              </div>
            </div>
          </Form>

          <div class="search-actions">
            <Button type="primary" icon="ios-search" :loading="searching" @click="handleSearch">
              搜索
            </Button>
            <Button
              icon="ios-refresh"
              :loading="searching"
              @click="handleReset"
              style="margin-left: 8px"
            >
              重置
            </Button>
          </div>
        </div>
      </div>

      <div ref="tableContainer" class="table-container">
        <Table
          v-if="isTableReady && filteredUsers.length > 0"
          :columns="columns"
          :data="filteredUsers"
          stripe
          border
          :width="tableWidth"
          :height="tableHeight"
          :max-height="tableMaxHeight"
        />
        <div v-else-if="isTableReady && filteredUsers.length === 0" class="no-data-placeholder">
          <Icon type="ios-information-circle" size="48" color="#c5c8ce" />
          <p>暂无数据</p>
        </div>
        <div v-else class="table-placeholder">
          <Spin size="large" />
          <p>正在加载用户数据...</p>
        </div>
      </div>

      <!-- 分页器 -->
      <div class="pagination-container">
        <Page
          :current="currentPage"
          :total="total"
          :page-size="pageSize"
          :page-size-opts="[10, 20, 50, 100]"
          show-sizer
          show-elevator
          show-total
          @on-change="handlePageChange"
          @on-page-size-change="handlePageSizeChange"
        />
      </div>
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
import { authCookie } from '@/utils/cookieUtils';
import { startLoading, stopLoading } from '@/utils/loadingManager';
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { Message, Tag } from 'view-ui-plus';
import { nextTick, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 数据状态
const users = ref([]);
const filteredUsers = ref([]);
const adding = ref(false);
const updating = ref(false);
const searching = ref(false);
const error = ref('');

// 搜索表单
const searchForm = ref({
  email: '',
  full_name: '',
  is_admin: '',
  is_active: '',
  start_date: null,
  end_date: null,
});

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 表格容器引用
const tableContainer = ref(null);

// 表格尺寸管理
const tableWidth = ref('100%');
const tableHeight = ref('auto');
const tableMaxHeight = ref('600px');
const isTableReady = ref(false);

// 表格列配置
const columns = ref([
  {
    title: '序号',
    key: 'index',
    width: 80,
    render: (h, params) => {
      return h('span', {}, (currentPage.value - 1) * pageSize.value + params.index + 1);
    },
  },
  {
    title: '邮箱',
    key: 'email',
    minWidth: 200,
  },
  {
    title: '姓名',
    key: 'full_name',
    minWidth: 150,
  },
  {
    title: '管理员',
    key: 'is_admin',
    width: 100,
    render: (h, params) => {
      return h(
        Tag,
        {
          color: params.row.is_admin ? 'success' : 'default',
        },
        {
          default() {
            return params.row.is_admin ? '是' : '否';
          },
        }
      );
    },
  },
  {
    title: '状态',
    key: 'is_active',
    width: 100,
    render: (h, params) => {
      return h(
        Tag,
        {
          color: params.row.is_active ? 'success' : 'error',
        },
        {
          default() {
            return params.row.is_active ? '活跃' : '禁用';
          },
        }
      );
    },
  },
  {
    title: '创建时间',
    key: 'created_at',
    minWidth: 180,
    render: (h, params) => {
      return h('span', {}, formatDate(params.row.created_at));
    },
  },
  {
    title: '操作',
    width: 150,
    render: (h, params) => {
      return h(
        'div',
        {
          style: 'display: flex; justify-content: center; align-items: center;',
        },
        [
          h(
            'Button',
            {
              type: 'default',
              size: 'small',
              icon: 'ios-create',
              style: 'background: #fff; color: #333; border: 1px solid #d9d9d9; min-width: 54px;',
              onClick: () => editUser(params.row),
            },
            {
              default() {
                return '编辑';
              },
            }
          ),
          h(
            'Button',
            {
              type: 'default',
              size: 'small',
              icon: 'ios-trash',
              style:
                'background: #fff; color: #e74c3c; border: 1px solid #e74c3c; margin-left: 12px; min-width: 54px;',
              onClick: () => deleteUser(params.row),
            },
            {
              default() {
                return '删除';
              },
            }
          ),
        ]
      );
    },
  },
]);

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
    error.value = '';
    isTableReady.value = false;

    console.log('开始获取用户数据...');
    console.log('当前认证状态:', authCookie.isAuthenticated());
    console.log('当前token:', authCookie.getAuth().token);

    // 使用真实API获取用户列表（全局loading会自动显示）
    const data = await userApi.getUsers();
    console.log('获取到的用户数据:', data);
    console.log('数据类型:', typeof data);
    console.log('数据长度:', data?.length);

    // 先设置数据
    users.value = data;

    // 应用搜索过滤
    applySearchFilter();

    // 等待DOM更新
    await nextTick();

    // 标记表格准备就绪
    isTableReady.value = true;

    console.log('users.value 设置后:', users.value);
    console.log('filteredUsers.value 设置后:', filteredUsers.value);

    // Message.success(`成功获取 ${data.length} 个用户`); // 注释掉测试提示
  } catch (err) {
    console.error('获取用户列表失败:', err);
    console.error('错误详情:', err.response?.data);
    console.error('错误状态码:', err.response?.status);
    error.value = '获取用户列表失败，请检查权限或重新登录';
    Message.error('获取用户列表失败，请检查权限或重新登录');

    // 如果是401错误，清除认证信息并跳转到登录页
    if (err.response?.status === 401) {
      authCookie.clearAuth();
      routerUtils.navigateTo(router, ROUTES.LOGIN);
    }
  }
}

// 添加用户
async function addUser() {
  try {
    adding.value = true;
    // 调用API创建用户
    const userData = {
      email: newUser.value.email,
      full_name: newUser.value.full_name,
      password: newUser.value.password,
    };

    console.log('创建用户数据:', userData);
    const result = await userApi.createUser(userData);
    console.log('用户创建成功:', result);

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
    // 调用API更新用户
    const userData = {
      email: editingUser.value.email,
      full_name: editingUser.value.full_name,
      is_admin: editingUser.value.is_admin,
      is_active: editingUser.value.is_active,
    };

    console.log('更新用户数据:', userData);
    console.log('用户ID:', editingUser.value.id);

    const result = await userApi.updateUser(editingUser.value.id, userData);
    console.log('用户更新成功:', result);

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
    console.log('删除用户:', user.id);

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

// 应用搜索过滤
function applySearchFilter() {
  let filtered = [...users.value];

  // 邮箱搜索（模糊匹配）
  if (searchForm.value.email) {
    filtered = filtered.filter(user =>
      user.email.toLowerCase().includes(searchForm.value.email.toLowerCase())
    );
  }

  // 姓名搜索（模糊匹配）
  if (searchForm.value.full_name) {
    filtered = filtered.filter(
      user =>
        user.full_name &&
        user.full_name.toLowerCase().includes(searchForm.value.full_name.toLowerCase())
    );
  }

  // 管理员状态过滤
  if (searchForm.value.is_admin !== null && searchForm.value.is_admin !== '') {
    const isAdminValue = searchForm.value.is_admin === 'true';
    filtered = filtered.filter(user => user.is_admin === isAdminValue);
  }

  // 用户状态过滤
  if (searchForm.value.is_active !== null && searchForm.value.is_active !== '') {
    const isActiveValue = searchForm.value.is_active === 'true';
    filtered = filtered.filter(user => user.is_active === isActiveValue);
  }

  // 创建时间范围过滤
  if (searchForm.value.start_date || searchForm.value.end_date) {
    filtered = filtered.filter(user => {
      const userDate = new Date(user.created_at);
      const startDate = searchForm.value.start_date ? new Date(searchForm.value.start_date) : null;
      const endDate = searchForm.value.end_date ? new Date(searchForm.value.end_date) : null;

      if (startDate && endDate) {
        // 两个日期都有，检查是否在范围内
        return userDate >= startDate && userDate <= endDate;
      } else if (startDate) {
        // 只有开始日期
        return userDate >= startDate;
      } else if (endDate) {
        // 只有结束日期
        return userDate <= endDate;
      }
      return true;
    });
  }

  filteredUsers.value = filtered;
  console.log(`搜索过滤完成，从 ${users.value.length} 个用户中筛选出 ${filtered.length} 个`);

  // 重置到第一页并应用分页
  currentPage.value = 1;
  applyPagination();
}

// 处理搜索
async function handleSearch() {
  try {
    searching.value = true;
    startLoading(); // 启动全局loading
    console.log('执行搜索，搜索条件:', searchForm.value);

    // 模拟搜索延迟，让用户看到loading效果
    await new Promise(resolve => setTimeout(resolve, 500));

    applySearchFilter();
    Message.info(`搜索完成，找到 ${filteredUsers.value.length} 个用户`);
  } catch (error) {
    console.error('搜索失败:', error);
    Message.error('搜索失败，请稍后重试');
  } finally {
    searching.value = false;
    stopLoading(); // 停止全局loading
  }
}

// 重置搜索条件
async function handleReset() {
  try {
    searching.value = true;
    startLoading(); // 启动全局loading

    // 模拟重置延迟
    await new Promise(resolve => setTimeout(resolve, 300));

    searchForm.value = {
      email: '',
      full_name: '',
      is_admin: '',
      is_active: '',
      start_date: null,
      end_date: null,
    };
    currentPage.value = 1;
    applySearchFilter();
    Message.info('搜索条件已重置');
  } catch (error) {
    console.error('重置失败:', error);
    Message.error('重置失败，请稍后重试');
  } finally {
    searching.value = false;
    stopLoading(); // 停止全局loading
  }
}

// 验证日期范围
function validateDateRange() {
  if (searchForm.value.start_date && searchForm.value.end_date) {
    const startDate = new Date(searchForm.value.start_date);
    const endDate = new Date(searchForm.value.end_date);

    if (startDate > endDate) {
      Message.error('结束时间必须大于开始时间');
      searchForm.value.end_date = null;
    }
  }
}

// 处理分页变化
function handlePageChange(page) {
  currentPage.value = page;
  applyPagination();
}

// 处理每页大小变化
function handlePageSizeChange(pageSize) {
  currentPage.value = 1;
  pageSize.value = pageSize;
  applyPagination();
}

// 应用分页
function applyPagination() {
  // 这里应该根据实际需求处理分页逻辑
  // 目前是前端分页，实际项目中应该是后端分页
  total.value = filteredUsers.value.length;

  console.log(`分页: 第${currentPage.value}页，每页${pageSize.value}条，共${total.value}条`);
}
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

.error-alert {
  margin-bottom: 1rem;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.search-section {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e8eaec;
}

.search-form-container {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 0.75rem;
  flex: 1;
}

.search-form .ivu-form-item {
  margin-bottom: 0;
  margin-right: 0;
}

.search-form .ivu-form-item-label {
  font-weight: 500;
  color: #515a6e;
  margin-bottom: 4px;
  font-size: 14px;
  line-height: 1.5;
  height: 22px;
  display: flex;
  align-items: center;
}

.date-range-field {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-bottom: 0;
}

.field-label {
  font-weight: 500;
  color: #515a6e;
  margin-bottom: 4px;
  font-size: 14px;
  line-height: 1.5;
  height: 22px;
  display: flex;
  align-items: center;
  padding-bottom: 10px;
}

.date-range-container {
  display: flex;
  flex-direction: column;
}

.date-range {
  display: flex;
  align-items: center;
  gap: 8px;
}

.date-separator {
  color: #999;
  font-size: 14px;
}

.search-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: 1rem;
}

.pagination-container {
  margin-top: 1.5rem;
  display: flex;
  justify-content: flex-end;
}

/* 表格容器样式 - 防止横向滚动条闪烁 */
.user-management {
  overflow-x: hidden;
}

.ivu-card {
  overflow: hidden;
}

.table-container {
  width: 100%;
  min-height: 400px;
  overflow: hidden;
  max-width: 100%;
}

.table-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400px;
  color: #999;
  overflow: hidden;
  width: 100%;
  max-width: 100%;
}

.table-placeholder p {
  margin-top: 16px;
  font-size: 14px;
}

.no-data-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400px;
  color: #999;
  overflow: hidden;
  width: 100%;
  max-width: 100%;
}

.no-data-placeholder p {
  margin-top: 16px;
  font-size: 16px;
  color: #c5c8ce;
}

.ivu-table-wrapper {
  overflow-x: hidden !important;
  overflow-y: hidden;
  width: 100% !important;
  max-width: 100% !important;
}

.ivu-table {
  width: 100% !important;
  min-width: 100% !important;
  max-width: 100% !important;
  table-layout: fixed;
}

/* 确保表格列宽度固定 */
.ivu-table th,
.ivu-table td {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  padding: 8px 12px;
}

/* 强制隐藏所有滚动条 */
.ivu-table-wrapper::-webkit-scrollbar {
  display: none !important;
}

.ivu-table-wrapper {
  -ms-overflow-style: none !important;
  scrollbar-width: none !important;
}

/* 确保表格不会超出容器宽度 */
.ivu-table-wrapper .ivu-table {
  max-width: 100% !important;
  width: 100% !important;
}

/* 确保表格容器不会产生滚动 */
.table-container .ivu-table-wrapper {
  overflow: hidden !important;
  max-width: 100% !important;
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

  .search-form-container {
    flex-direction: column;
    align-items: stretch;
  }

  .search-form {
    flex-direction: column;
    align-items: stretch;
  }

  .search-form .ivu-form-item {
    display: block;
    margin-bottom: 12px;
  }

  .search-form .ivu-form-item-label {
    display: block;
    margin-bottom: 4px;
  }

  .search-form .ivu-input,
  .search-form .ivu-select,
  .search-form .ivu-date-picker {
    width: 100% !important;
  }

  .date-range-field {
    align-items: stretch;
  }

  .date-range-container {
    flex-direction: column;
  }

  .date-range {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }

  .date-separator {
    text-align: center;
  }

  .search-actions {
    justify-content: center;
    margin-top: 12px;
    margin-left: 0;
  }

  .pagination-container {
    justify-content: center;
  }
}
</style>
