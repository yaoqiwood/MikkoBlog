<template>
  <div class="comment-management">
    <div class="page-header">
      <h1 class="page-title">评论管理</h1>
      <div class="page-actions">
        <Button type="primary" icon="ios-refresh" @click="fetchComments">刷新</Button>
      </div>
    </div>

    <!-- 错误提示 -->
    <Alert v-if="error" type="error" show-icon class="error-alert">
      {{ error }}
    </Alert>

    <!-- 评论列表 -->
    <Card>
      <template #title>
        <div class="card-title">
          <Icon type="ios-chatbubbles" />
          评论列表
        </div>
      </template>

      <!-- 搜索条件 -->
      <div class="search-section">
        <div class="search-form-container">
          <Form :model="searchForm" inline class="search-form">
            <FormItem label="评论者">
              <Input
                v-model="searchForm.author_name"
                placeholder="请输入评论者姓名"
                clearable
                style="width: 150px"
              />
            </FormItem>

            <FormItem label="邮箱">
              <Input
                v-model="searchForm.author_email"
                placeholder="请输入邮箱地址"
                clearable
                style="width: 200px"
              />
            </FormItem>

            <FormItem label="审核状态">
              <Select
                v-model="searchForm.is_approved"
                placeholder="选择审核状态"
                clearable
                style="width: 120px"
              >
                <Option value="true">已审核</Option>
                <Option value="false">待审核</Option>
              </Select>
            </FormItem>

            <FormItem label="可见性">
              <Select
                v-model="searchForm.is_visible"
                placeholder="选择可见性"
                clearable
                style="width: 120px"
              >
                <Option value="true">可见</Option>
                <Option value="false">隐藏</Option>
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
          v-if="isTableReady && filteredComments.length > 0"
          :columns="columns"
          :data="filteredComments"
          stripe
          border
          :width="tableWidth"
          :height="tableHeight"
          :max-height="tableMaxHeight"
        />
        <div v-else-if="isTableReady && filteredComments.length === 0" class="no-data-placeholder">
          <Icon type="ios-information-circle" size="48" color="#c5c8ce" />
          <p>暂无数据</p>
        </div>
        <div v-else class="table-placeholder">
          <Spin size="large" />
          <p>正在加载评论数据...</p>
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

    <!-- 编辑评论模态框 -->
    <Modal v-model="showEditComment" title="编辑评论" :mask-closable="false" width="800">
      <Form
        ref="editCommentForm"
        :model="editingComment"
        :rules="commentRules"
        label-position="top"
      >
        <FormItem label="评论者姓名" prop="author_name">
          <Input v-model="editingComment.author_name" placeholder="请输入评论者姓名" />
        </FormItem>
        <FormItem label="评论者邮箱" prop="author_email">
          <Input v-model="editingComment.author_email" placeholder="请输入评论者邮箱" />
        </FormItem>
        <FormItem label="评论者网站">
          <Input v-model="editingComment.author_website" placeholder="请输入评论者网站" />
        </FormItem>
        <FormItem label="评论内容" prop="content">
          <Input
            v-model="editingComment.content"
            type="textarea"
            :rows="4"
            placeholder="请输入评论内容"
          />
        </FormItem>
        <FormItem label="IP地址">
          <Input v-model="editingComment.ip_address" placeholder="IP地址" readonly />
        </FormItem>
        <FormItem label="地域信息">
          <Input v-model="editingComment.location" placeholder="地域信息" readonly />
        </FormItem>
        <Row :gutter="20">
          <Col span="8">
            <FormItem label="审核状态">
              <Switch v-model="editingComment.is_approved" />
            </FormItem>
          </Col>
          <Col span="8">
            <FormItem label="可见性">
              <Switch v-model="editingComment.is_visible" />
            </FormItem>
          </Col>
        </Row>
      </Form>

      <template #footer>
        <Button @click="showEditComment = false">取消</Button>
        <Button type="primary" @click="updateComment" :loading="updating">确定</Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { commentApi } from '@/utils/apiService';
import { authCookie } from '@/utils/cookieUtils';
import { startLoading, stopLoading } from '@/utils/loadingManager';
import { routerUtils, ROUTES } from '@/utils/routeManager';
import { Message, Modal, Tag } from 'view-ui-plus';
import { nextTick, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 数据状态
const comments = ref([]);
const filteredComments = ref([]);
const updating = ref(false);
const searching = ref(false);
const error = ref('');

// 搜索表单
const searchForm = ref({
  author_name: '',
  author_email: '',
  is_approved: '',
  is_visible: '',
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
    title: '评论者',
    key: 'author_name',
    minWidth: 120,
  },
  {
    title: '邮箱',
    key: 'author_email',
    minWidth: 180,
    render: (h, params) => {
      return h('span', {}, params.row.author_email || '-');
    },
  },
  {
    title: '评论内容',
    key: 'content',
    minWidth: 200,
    render: (h, params) => {
      const content = params.row.content;
      const truncatedContent = content.length > 50 ? content.substring(0, 50) + '...' : content;
      return h(
        'div',
        {
          style:
            'max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;',
          title: content,
        },
        truncatedContent
      );
    },
  },
  {
    title: 'IP地址',
    key: 'ip_address',
    width: 120,
    render: (h, params) => {
      return h('span', {}, params.row.ip_address || '-');
    },
  },
  {
    title: '地域',
    key: 'location',
    width: 100,
    render: (h, params) => {
      return h('span', {}, params.row.location || '-');
    },
  },
  {
    title: '审核状态',
    key: 'is_approved',
    width: 100,
    render: (h, params) => {
      return h(
        Tag,
        {
          color: params.row.is_approved ? 'success' : 'warning',
        },
        {
          default() {
            return params.row.is_approved ? '已审核' : '待审核';
          },
        }
      );
    },
  },
  {
    title: '可见性',
    key: 'is_visible',
    width: 100,
    render: (h, params) => {
      return h(
        Tag,
        {
          color: params.row.is_visible ? 'success' : 'default',
        },
        {
          default() {
            return params.row.is_visible ? '可见' : '隐藏';
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
    width: 200,
    render: (h, params) => {
      return h(
        'div',
        {
          style: 'display: flex; justify-content: center; align-items: center; gap: 8px;',
        },
        [
          h(
            'Button',
            {
              type: 'default',
              size: 'small',
              icon: 'ios-create',
              style: 'background: #fff; color: #333; border: 1px solid #d9d9d9; min-width: 54px;',
              onClick: () => editComment(params.row),
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
              icon: params.row.is_approved ? 'ios-checkmark' : 'ios-close',
              style: `background: #fff; color: ${params.row.is_approved ? '#52c41a' : '#faad14'}; border: 1px solid ${params.row.is_approved ? '#52c41a' : '#faad14'}; min-width: 54px;`,
              onClick: () => toggleApproval(params.row),
            },
            {
              default() {
                return params.row.is_approved ? '取消审核' : '审核通过';
              },
            }
          ),
          h(
            'Button',
            {
              type: 'default',
              size: 'small',
              icon: params.row.is_visible ? 'ios-eye' : 'ios-eye-off',
              style: `background: #fff; color: ${params.row.is_visible ? '#1890ff' : '#999'}; border: 1px solid ${params.row.is_visible ? '#1890ff' : '#999'}; min-width: 54px;`,
              onClick: () => toggleVisibility(params.row),
            },
            {
              default() {
                return params.row.is_visible ? '隐藏' : '显示';
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
                'background: #fff; color: #e74c3c; border: 1px solid #e74c3c; min-width: 54px;',
              onClick: () => deleteComment(params.row),
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
const showEditComment = ref(false);

// 表单数据
const editingComment = ref({
  id: null,
  author_name: '',
  author_email: '',
  author_website: '',
  content: '',
  ip_address: '',
  location: '',
  is_approved: false,
  is_visible: true,
});

// 表单验证规则
const commentRules = {
  author_name: [
    { required: true, message: '请输入评论者姓名', trigger: 'blur' },
    { min: 2, message: '姓名长度不能少于2位', trigger: 'blur' },
  ],
  author_email: [{ type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }],
  content: [
    { required: true, message: '请输入评论内容', trigger: 'blur' },
    { min: 5, message: '评论内容长度不能少于5位', trigger: 'blur' },
  ],
};

// 获取评论列表
async function fetchComments() {
  try {
    error.value = '';
    isTableReady.value = false;

    console.log('开始获取评论数据...');
    console.log('当前认证状态:', authCookie.isAuthenticated());
    console.log('当前token:', authCookie.getAuth().token);

    const data = await commentApi.getComments();
    console.log('获取到的评论数据:', data);
    console.log('数据类型:', typeof data);
    console.log('数据长度:', data?.length);

    comments.value = data;
    applySearchFilter();

    await nextTick();
    isTableReady.value = true;

    console.log('comments.value 设置后:', comments.value);
    console.log('filteredComments.value 设置后:', filteredComments.value);
  } catch (err) {
    console.error('获取评论列表失败:', err);
    console.error('错误详情:', err.response?.data);
    console.error('错误状态码:', err.response?.status);
    error.value = '获取评论列表失败，请检查权限或重新登录';
    Message.error('获取评论列表失败，请检查权限或重新登录');

    if (err.response?.status === 401) {
      authCookie.clearAuth();
      routerUtils.navigateTo(router, ROUTES.LOGIN);
    }
  }
}

// 编辑评论
function editComment(comment) {
  editingComment.value = { ...comment };
  showEditComment.value = true;
}

// 更新评论
async function updateComment() {
  try {
    updating.value = true;
    const commentData = {
      author_name: editingComment.value.author_name,
      author_email: editingComment.value.author_email,
      author_website: editingComment.value.author_website,
      content: editingComment.value.content,
      is_approved: editingComment.value.is_approved,
      is_visible: editingComment.value.is_visible,
    };

    console.log('更新评论数据:', commentData);
    console.log('评论ID:', editingComment.value.id);

    const result = await commentApi.updateComment(editingComment.value.id, commentData);
    console.log('评论更新成功:', result);

    Message.success('评论更新成功');
    showEditComment.value = false;
    await fetchComments();
  } catch (error) {
    console.error('更新评论失败:', error);
    Message.error('更新评论失败');
  } finally {
    updating.value = false;
  }
}

// 切换审核状态
async function toggleApproval(comment) {
  try {
    console.log('切换评论审核状态:', comment.id);
    console.log('当前状态:', comment.is_approved);

    await commentApi.toggleApproval(comment.id);
    Message.success(comment.is_approved ? '已取消审核' : '审核通过');
    await fetchComments();
  } catch (error) {
    console.error('切换审核状态失败:', error);
    console.error('错误详情:', error.response?.data);
    console.error('错误状态码:', error.response?.status);

    if (error.response?.status === 401) {
      Message.error('权限不足，请重新登录');
      authCookie.clearAuth();
      routerUtils.navigateTo(router, ROUTES.LOGIN);
    } else if (error.response?.status === 404) {
      Message.error('评论不存在');
    } else {
      Message.error('操作失败，请稍后重试');
    }
  }
}

// 切换可见性
async function toggleVisibility(comment) {
  try {
    console.log('切换评论可见性:', comment.id);
    console.log('当前状态:', comment.is_visible);

    await commentApi.toggleVisibility(comment.id);
    Message.success(comment.is_visible ? '已隐藏评论' : '已显示评论');
    await fetchComments();
  } catch (error) {
    console.error('切换可见性失败:', error);
    console.error('错误详情:', error.response?.data);
    console.error('错误状态码:', error.response?.status);

    if (error.response?.status === 401) {
      Message.error('权限不足，请重新登录');
      authCookie.clearAuth();
      routerUtils.navigateTo(router, ROUTES.LOGIN);
    } else if (error.response?.status === 404) {
      Message.error('评论不存在');
    } else {
      Message.error('操作失败，请稍后重试');
    }
  }
}

// 删除评论（软删除）
async function deleteComment(comment) {
  try {
    Modal.confirm({
      title: '确认删除',
      content: `确定要删除评论吗？删除后评论将被标记为已删除状态。`,
      okText: '确认删除',
      cancelText: '取消',
      type: 'warning',
      onOk: async () => {
        try {
          console.log('软删除评论:', comment.id);
          await commentApi.deleteComment(comment.id);

          Message.success('评论已删除');
          await fetchComments();
        } catch (error) {
          console.error('删除评论失败:', error);
          console.error('错误详情:', error.response?.data);
          console.error('错误状态码:', error.response?.status);

          if (error.response?.status === 401) {
            Message.error('权限不足，请重新登录');
            authCookie.clearAuth();
            routerUtils.navigateTo(router, ROUTES.LOGIN);
          } else if (error.response?.status === 404) {
            Message.error('评论不存在');
          } else {
            Message.error('评论删除失败，请稍后重试');
          }
        }
      },
      onCancel: () => {
        console.log('用户取消了删除操作');
      },
    });
  } catch (error) {
    console.error('显示确认对话框失败:', error);
    Message.error('操作失败，请稍后重试');
  }
}

// 应用搜索过滤
function applySearchFilter() {
  let filtered = [...comments.value];

  // 评论者姓名搜索（模糊匹配）
  if (searchForm.value.author_name) {
    filtered = filtered.filter(comment =>
      comment.author_name.toLowerCase().includes(searchForm.value.author_name.toLowerCase())
    );
  }

  // 邮箱搜索（模糊匹配）
  if (searchForm.value.author_email) {
    filtered = filtered.filter(
      comment =>
        comment.author_email &&
        comment.author_email.toLowerCase().includes(searchForm.value.author_email.toLowerCase())
    );
  }

  // 审核状态过滤
  if (searchForm.value.is_approved !== null && searchForm.value.is_approved !== '') {
    const isApprovedValue = searchForm.value.is_approved === 'true';
    filtered = filtered.filter(comment => comment.is_approved === isApprovedValue);
  }

  // 可见性过滤
  if (searchForm.value.is_visible !== null && searchForm.value.is_visible !== '') {
    const isVisibleValue = searchForm.value.is_visible === 'true';
    filtered = filtered.filter(comment => comment.is_visible === isVisibleValue);
  }

  // 创建时间范围过滤
  if (searchForm.value.start_date || searchForm.value.end_date) {
    filtered = filtered.filter(comment => {
      const commentDate = new Date(comment.created_at);
      const startDate = searchForm.value.start_date ? new Date(searchForm.value.start_date) : null;
      const endDate = searchForm.value.end_date ? new Date(searchForm.value.end_date) : null;

      if (startDate && endDate) {
        return commentDate >= startDate && commentDate <= endDate;
      } else if (startDate) {
        return commentDate >= startDate;
      } else if (endDate) {
        return commentDate <= endDate;
      }
      return true;
    });
  }

  filteredComments.value = filtered;
  console.log(`搜索过滤完成，从 ${comments.value.length} 条评论中筛选出 ${filtered.length} 条`);

  currentPage.value = 1;
  applyPagination();
}

// 处理搜索
async function handleSearch() {
  try {
    searching.value = true;
    startLoading();
    console.log('执行搜索，搜索条件:', searchForm.value);

    await new Promise(resolve => {
      setTimeout(resolve, 500);
    });

    applySearchFilter();
    Message.info(`搜索完成，找到 ${filteredComments.value.length} 条评论`);
  } catch (error) {
    console.error('搜索失败:', error);
    Message.error('搜索失败，请稍后重试');
  } finally {
    searching.value = false;
    stopLoading();
  }
}

// 重置搜索条件
async function handleReset() {
  try {
    searching.value = true;
    startLoading();

    await new Promise(resolve => {
      setTimeout(resolve, 300);
    });

    searchForm.value = {
      author_name: '',
      author_email: '',
      is_approved: '',
      is_visible: '',
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
    stopLoading();
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
  total.value = filteredComments.value.length;
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
  fetchComments();
});
</script>

<style scoped>
.comment-management {
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
.comment-management {
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
