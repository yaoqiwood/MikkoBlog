<template>
  <div class="columns-management">
    <!-- 筛选和操作区域 -->
    <div class="filter-controls">
      <div class="filter-item">
        <Input
          v-model="searchForm.name"
          placeholder="搜索专栏名称"
          style="width: 200px"
          clearable
          @on-enter="loadColumns"
        />
      </div>
      <div class="filter-item">
        <Select v-model="searchForm.is_visible" placeholder="可见性" style="width: 120px" clearable>
          <Option :value="true">可见</Option>
          <Option :value="false">隐藏</Option>
        </Select>
      </div>
      <div class="filter-buttons">
        <Button type="primary" @click="loadColumns">
          <Icon type="ios-search" />
          搜索
        </Button>
        <Button @click="resetSearch">
          <Icon type="ios-refresh" />
          重置
        </Button>
      </div>
    </div>

    <!-- 操作按钮区域 -->
    <div class="action-bar">
      <div class="batch-actions" v-if="selectedColumns.length > 0">
        <span class="selection-info">已选择 {{ selectedColumns.length }} 个专栏</span>
        <Button
          type="warning"
          icon="ios-images"
          :loading="batchGenerating"
          @click="batchGenerateCovers"
          style="margin-left: 8px; margin-right: 8px"
        >
          为选中专栏生成封面 ({{ selectedColumns.length }})
        </Button>
        <Button type="default" icon="ios-close" @click="clearSelection" size="small">
          取消选择
        </Button>
      </div>
      <div class="create-actions">
        <Button type="primary" class="add-column-button" @click="createNewColumn">
          <Icon type="ios-add" />
          创建专栏
        </Button>
      </div>
    </div>

    <!-- 专栏列表 -->
    <Card>
      <Table
        :columns="tableColumns"
        :data="columns"
        :loading="loading"
        stripe
        border
        @on-selection-change="handleSelectionChange"
      >
        <!-- 封面图片 -->
        <template #cover_image="{ row }">
          <div class="cover-image">
            <img
              v-if="row.cover_image_url"
              :src="getFullImageUrl(row.cover_image_url)"
              alt="专栏封面"
              @click="previewImage(row.cover_image_url)"
            />
            <span v-else class="no-image">无封面</span>
          </div>
        </template>

        <!-- 可见性状态 -->
        <template #is_visible="{ row }">
          <Switch v-model="row.is_visible" @on-change="toggleVisibility(row)">
            <template #open>
              <span>显示</span>
            </template>
            <template #close>
              <span>隐藏</span>
            </template>
          </Switch>
        </template>

        <!-- 操作按钮 -->
        <template #action="{ row }">
          <div class="action-buttons">
            <Button type="primary" size="small" @click="editColumn(row)"> 编辑 </Button>
            <Button type="info" size="small" @click="manageColumnPosts(row)"> 管理文章 </Button>
            <Button type="error" size="small" @click="deleteColumn(row)"> 删除 </Button>
          </div>
        </template>
      </Table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <Page
          :total="total"
          :current="currentPage"
          :page-size="pageSize"
          show-total
          show-sizer
          show-elevator
          @on-change="handlePageChange"
          @on-page-size-change="handlePageSizeChange"
        />
      </div>
    </Card>

    <!-- 创建/编辑专栏弹窗 -->
    <Modal
      v-model="showCreateModal"
      :title="isEditing ? '编辑专栏' : '创建专栏'"
      width="600"
      :mask-closable="false"
    >
      <Form ref="columnFormRef" :model="columnForm" :rules="columnRules" :label-width="80">
        <FormItem label="专栏名称" prop="name">
          <Input
            v-model="columnForm.name"
            placeholder="请输入专栏名称"
            maxlength="100"
            show-word-limit
          />
        </FormItem>

        <FormItem label="专栏描述" prop="description">
          <Input
            v-model="columnForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入专栏描述"
            maxlength="500"
            show-word-limit
          />
        </FormItem>

        <FormItem label="封面图片">
          <div class="cover-upload">
            <div v-if="columnForm.cover_image_url" class="cover-preview">
              <img
                :src="getFullImageUrl(columnForm.cover_image_url)"
                alt="封面预览"
                @click="previewImage(columnForm.cover_image_url)"
              />
              <Button
                type="error"
                size="small"
                class="remove-cover"
                @click="columnForm.cover_image_url = ''"
              >
                <Icon type="ios-close" />
              </Button>
            </div>
            <div v-else class="upload-options">
              <Upload
                :action="uploadUrl"
                :headers="uploadHeaders"
                :on-success="handleCoverUpload"
                :on-error="handleUploadError"
                :show-upload-list="false"
                accept="image/*"
              >
                <Button icon="ios-cloud-upload-outline"> 上传封面图片 </Button>
              </Upload>
              <Button
                type="success"
                icon="ios-images"
                :loading="generatingCover"
                @click="generateRandomCover"
                style="margin-left: 8px"
              >
                随机生成封面
              </Button>
            </div>
          </div>
        </FormItem>

        <FormItem label="排序顺序" prop="sort_order">
          <InputNumber
            v-model="columnForm.sort_order"
            :min="0"
            :max="9999"
            placeholder="数字越小越靠前"
          />
        </FormItem>

        <FormItem label="是否可见">
          <Switch v-model="columnForm.is_visible">
            <template #open>
              <span>显示</span>
            </template>
            <template #close>
              <span>隐藏</span>
            </template>
          </Switch>
        </FormItem>
      </Form>

      <template #footer>
        <Button @click="showCreateModal = false">取消</Button>
        <Button type="primary" :loading="saving" @click="saveColumn">
          {{ isEditing ? '更新' : '创建' }}
        </Button>
      </template>
    </Modal>

    <!-- 管理专栏文章弹窗 -->
    <Modal v-model="showPostsModal" title="管理专栏文章" width="800" :mask-closable="false">
      <div class="posts-management">
        <div class="posts-search">
          <Input
            v-model="postSearchKeyword"
            placeholder="搜索文章标题"
            style="width: 300px"
            @on-enter="searchPosts"
          />
          <Button type="primary" @click="searchPosts" style="margin-left: 10px"> 搜索文章 </Button>
          <Button type="success" @click="showCreatePostModalHandler" style="margin-left: 10px">
            创建专栏文章
          </Button>
        </div>

        <div class="posts-section">
          <h4>专栏文章 ({{ selectedColumn?.post_count || 0 }}篇)</h4>
          <Table
            :columns="columnPostsColumns"
            :data="columnPosts"
            :loading="postsLoading"
            size="small"
          >
            <template #action="{ row }">
              <Button type="error" size="small" @click="removePostFromColumn(row.id)">
                移除
              </Button>
            </template>
          </Table>
        </div>

        <div class="posts-section" style="margin-top: 20px">
          <h4>可添加文章</h4>
          <Table
            :columns="availablePostsColumns"
            :data="availablePosts"
            :loading="postsLoading"
            size="small"
          >
            <template #action="{ row }">
              <Button type="primary" size="small" @click="addPostToColumn(row.id)"> 添加 </Button>
            </template>
          </Table>
        </div>
      </div>

      <template #footer>
        <Button @click="showPostsModal = false">关闭</Button>
      </template>
    </Modal>

    <!-- 图片预览弹窗 -->
    <Modal v-model="showImagePreview" title="图片预览" width="80%" class="image-preview-modal">
      <div class="image-preview-container">
        <img v-if="previewImageUrl" :src="getFullImageUrl(previewImageUrl)" alt="图片预览" />
      </div>
      <template #footer>
        <Button @click="showImagePreview = false">关闭</Button>
      </template>
    </Modal>

    <!-- 批量生成进度弹窗 -->
    <Modal
      v-model="showProgressModal"
      title="批量生成封面进度"
      width="600"
      :mask-closable="false"
      :closable="false"
    >
      <div class="progress-container">
        <div class="progress-header">
          <h4>正在为 {{ selectedColumns.length }} 个专栏生成封面...</h4>
          <div class="progress-stats">
            <span class="stat-item success">✅ 成功: {{ progressStats.success }}</span>
            <span class="stat-item failed">❌ 失败: {{ progressStats.failed }}</span>
            <span class="stat-item pending">⏳ 待处理: {{ progressStats.pending }}</span>
          </div>
        </div>

        <div class="progress-bar-container">
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: `${progressPercentage}%` }"></div>
          </div>
          <span class="progress-text">{{ progressPercentage }}%</span>
        </div>

        <div class="progress-list">
          <div
            v-for="item in progressItems"
            :key="item.id"
            class="progress-item"
            :class="item.status"
          >
            <div class="item-info">
              <span class="item-name">{{ item.name }}</span>
              <span class="item-tags">{{ item.tags.join(', ') }}</span>
            </div>
            <div class="item-status">
              <Icon v-if="item.status === 'processing'" type="ios-loading" class="loading-icon" />
              <Icon
                v-else-if="item.status === 'success'"
                type="ios-checkmark-circle"
                color="#52c41a"
              />
              <Icon v-else-if="item.status === 'failed'" type="ios-close-circle" color="#ff4d4f" />
              <Icon v-else type="ios-time" color="#999" />
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <Button v-if="progressStats.pending === 0" type="primary" @click="closeProgressModal">
          完成
        </Button>
        <Button v-else @click="cancelBatchGeneration" :disabled="cancelling">
          {{ cancelling ? '正在取消...' : '取消' }}
        </Button>
      </template>
    </Modal>

    <!-- 创建专栏文章弹窗 -->
    <Modal v-model="showCreatePostModal" title="创建专栏文章" width="90%" :mask-closable="false">
      <div class="create-post-container">
        <Form ref="postForm" :model="postForm" :rules="postRules" :label-width="100">
          <FormItem label="文章标题" prop="title">
            <Input v-model="postForm.title" placeholder="请输入文章标题" />
          </FormItem>

          <FormItem label="文章摘要" prop="summary">
            <Input
              v-model="postForm.summary"
              type="textarea"
              :rows="3"
              placeholder="请输入文章摘要"
            />
          </FormItem>

          <FormItem label="封面图片" prop="cover_image_url">
            <div class="cover-upload">
              <Upload
                :action="uploadUrl"
                :headers="uploadHeaders"
                :on-success="handleCoverUpload"
                :show-upload-list="false"
                accept="image/*"
              >
                <div class="upload-area">
                  <img
                    v-if="postForm.cover_image_url"
                    :src="postForm.cover_image_url"
                    alt="封面预览"
                  />
                  <div v-else class="upload-placeholder">
                    <Icon type="ios-cloud-upload" size="48" />
                    <p>点击上传封面图片</p>
                  </div>
                </div>
              </Upload>
            </div>
          </FormItem>

          <FormItem label="文章内容" prop="content">
            <MarkdownEditor v-model="postForm.content" />
          </FormItem>

          <FormItem label="文章状态">
            <RadioGroup v-model="postForm.is_visible">
              <Radio :label="true">公开</Radio>
              <Radio :label="false">草稿</Radio>
            </RadioGroup>
          </FormItem>
        </Form>
      </div>
      <template #footer>
        <Button @click="showCreatePostModal = false">取消</Button>
        <Button type="primary" @click="createPost" :loading="creatingPost">创建文章</Button>
      </template>
    </Modal>
  </div>
</template>

<script>
import MarkdownEditor from '@/components/MarkdownEditor.vue';
import apiService from '@/utils/apiService';
import { getApiUrl, getFullUrl } from '@/utils/urlUtils';
import { Modal as IModal, Message } from 'view-ui-plus';
import { computed, onMounted, reactive, ref } from 'vue';

export default {
  name: 'ColumnsManagement',
  components: {
    MarkdownEditor,
  },
  setup() {
    // 响应式数据
    const loading = ref(false);
    const saving = ref(false);
    const postsLoading = ref(false);
    const generatingCover = ref(false);
    const batchGenerating = ref(false);
    const columns = ref([]);
    const selectedColumns = ref([]);
    const total = ref(0);
    const currentPage = ref(1);
    const pageSize = ref(10);

    // 进度相关数据
    const showProgressModal = ref(false);
    const progressItems = ref([]);
    const progressStats = reactive({
      success: 0,
      failed: 0,
      pending: 0,
    });
    const cancelling = ref(false);
    const shouldCancel = ref(false);

    // 搜索表单
    const searchForm = reactive({
      name: '',
      is_visible: null,
    });

    // 专栏表单
    const columnForm = reactive({
      name: '',
      description: '',
      cover_image_url: '',
      sort_order: 0,
      is_visible: true,
    });

    // 弹窗状态
    const showCreateModal = ref(false);
    const showPostsModal = ref(false);
    const showImagePreview = ref(false);
    const isEditing = ref(false);
    const editingColumnId = ref(null);

    // 创建文章相关数据
    const showCreatePostModal = ref(false);
    const creatingPost = ref(false);
    const postForm = reactive({
      title: '',
      summary: '',
      content: '',
      cover_image_url: '',
      is_visible: true,
    });
    const postRules = {
      title: [{ required: true, message: '请输入文章标题', trigger: 'blur' }],
      content: [{ required: true, message: '请输入文章内容', trigger: 'blur' }],
    };

    // 图片预览
    const previewImageUrl = ref('');

    // 专栏文章管理
    const selectedColumn = ref(null);
    const columnPosts = ref([]);
    const availablePosts = ref([]);
    const postSearchKeyword = ref('');

    // 表单验证规则
    const columnRules = {
      name: [
        { required: true, message: '请输入专栏名称', trigger: 'blur' },
        { min: 1, max: 100, message: '专栏名称长度在1到100个字符', trigger: 'blur' },
      ],
      description: [{ max: 500, message: '专栏描述不能超过500个字符', trigger: 'blur' }],
      sort_order: [
        { type: 'number', min: 0, max: 9999, message: '排序顺序必须在0-9999之间', trigger: 'blur' },
      ],
    };

    // 表格列定义
    const tableColumns = [
      {
        type: 'selection',
        width: 60,
        align: 'center',
      },
      {
        title: '专栏名称',
        key: 'name',
        width: 200,
      },
      {
        title: '描述',
        key: 'description',
        width: 300,
        ellipsis: true,
      },
      {
        title: '封面',
        slot: 'cover_image',
        width: 100,
        align: 'center',
      },
      {
        title: '文章数',
        key: 'post_count',
        width: 80,
        align: 'center',
      },
      {
        title: '浏览量',
        key: 'view_count',
        width: 80,
        align: 'center',
      },
      {
        title: '排序',
        key: 'sort_order',
        width: 80,
        align: 'center',
      },
      {
        title: '可见性',
        slot: 'is_visible',
        width: 100,
        align: 'center',
      },
      {
        title: '创建时间',
        key: 'created_at',
        width: 150,
        render: (h, params) => {
          return h('span', new Date(params.row.created_at).toLocaleString());
        },
      },
      {
        title: '操作',
        slot: 'action',
        width: 200,
        align: 'center',
      },
    ];

    // 专栏文章表格列
    const columnPostsColumns = [
      { title: '文章标题', key: 'title' },
      {
        title: '创建时间',
        key: 'created_at',
        width: 180,
        render: (h, params) =>
          h(
            'span',
            {
              style: { whiteSpace: 'nowrap' },
            },
            new Date(params.row.created_at).toLocaleString()
          ),
      },
      { title: '操作', slot: 'action', width: 80, align: 'center' },
    ];

    // 可添加文章表格列
    const availablePostsColumns = [
      { title: '文章标题', key: 'title' },
      {
        title: '创建时间',
        key: 'created_at',
        width: 180,
        render: (h, params) =>
          h(
            'span',
            {
              style: { whiteSpace: 'nowrap' },
            },
            new Date(params.row.created_at).toLocaleString()
          ),
      },
      { title: '操作', slot: 'action', width: 80, align: 'center' },
    ];

    // 计算属性
    const uploadUrl = computed(() => getApiUrl('/api/attachments/upload'));
    const uploadHeaders = computed(() => ({
      Authorization: `Bearer ${localStorage.getItem('access_token')}`,
    }));

    // 进度百分比
    const progressPercentage = computed(() => {
      const total = progressItems.value.length;
      if (total === 0) return 0;
      const completed = progressStats.success + progressStats.failed;
      return Math.round((completed / total) * 100);
    });

    // 方法
    const getFullImageUrl = url => {
      if (!url) return '';
      if (url.startsWith('http')) return url;
      return getFullUrl(url);
    };

    const loadColumns = async () => {
      loading.value = true;
      try {
        const params = {
          page: currentPage.value,
          limit: pageSize.value,
        };

        if (searchForm.name) {
          // 注意：后端可能不支持按名称搜索，这里先保留接口
          // params.name = searchForm.name;
        }
        if (searchForm.is_visible !== null) {
          params.is_visible = searchForm.is_visible;
        }

        const response = await apiService.columns.getColumns(params);
        columns.value = response.items || [];
        total.value = response.total || 0;
      } catch (error) {
        console.error('加载专栏列表失败:', error);
        Message.error('加载专栏列表失败');
      } finally {
        loading.value = false;
      }
    };

    const resetSearch = () => {
      searchForm.name = '';
      searchForm.is_visible = null;
      currentPage.value = 1;
      loadColumns();
    };

    const resetForm = () => {
      columnForm.name = '';
      columnForm.description = '';
      columnForm.cover_image_url = '';
      columnForm.sort_order = 0;
      columnForm.is_visible = true;
      isEditing.value = false;
      editingColumnId.value = null;
    };

    const createNewColumn = () => {
      resetForm();
      showCreateModal.value = true;
    };

    const editColumn = column => {
      isEditing.value = true;
      editingColumnId.value = column.id;
      columnForm.name = column.name;
      columnForm.description = column.description || '';
      columnForm.cover_image_url = column.cover_image_url || '';
      columnForm.sort_order = column.sort_order;
      columnForm.is_visible = column.is_visible;
      showCreateModal.value = true;
    };

    const saveColumn = async () => {
      // 表单验证
      if (!columnForm.name.trim()) {
        Message.error('请输入专栏名称');
        return;
      }

      saving.value = true;
      try {
        const data = {
          name: columnForm.name.trim(),
          description: columnForm.description.trim(),
          cover_image_url: columnForm.cover_image_url,
          sort_order: columnForm.sort_order,
          is_visible: columnForm.is_visible,
          user_id: 1, // 假设当前用户ID为1
        };

        if (isEditing.value) {
          await apiService.columns.updateColumn(editingColumnId.value, data);
          Message.success('专栏更新成功');
        } else {
          await apiService.columns.createColumn(data);
          Message.success('专栏创建成功');
        }

        showCreateModal.value = false;
        resetForm();
        loadColumns();
      } catch (error) {
        console.error('保存专栏失败:', error);
        const errorMsg = error.response?.data?.detail || '保存专栏失败';
        Message.error(errorMsg);
      } finally {
        saving.value = false;
      }
    };

    const toggleVisibility = async column => {
      try {
        await apiService.columns.updateColumn(column.id, {
          is_visible: column.is_visible,
        });
        Message.success(`专栏已${column.is_visible ? '显示' : '隐藏'}`);
      } catch (error) {
        console.error('更新专栏可见性失败:', error);
        Message.error('更新专栏可见性失败');
        // 恢复原状态
        column.is_visible = !column.is_visible;
      }
    };

    const deleteColumn = column => {
      IModal.confirm({
        title: '确认删除',
        content: `确定要删除专栏"${column.name}"吗？此操作不可恢复。`,
        onOk: async () => {
          try {
            await apiService.columns.deleteColumn(column.id);
            Message.success('专栏删除成功');
            loadColumns();
          } catch (error) {
            console.error('删除专栏失败:', error);
            Message.error('删除专栏失败');
          }
        },
      });
    };

    const manageColumnPosts = async column => {
      selectedColumn.value = column;
      showPostsModal.value = true;
      await loadColumnPosts();
      await loadAvailablePosts();
    };

    const loadColumnPosts = async () => {
      if (!selectedColumn.value) return;

      postsLoading.value = true;
      try {
        const response = await apiService.columns.getColumnById(selectedColumn.value.id);
        columnPosts.value = response.posts || [];
      } catch (error) {
        console.error('加载专栏文章失败:', error);
        Message.error('加载专栏文章失败');
      } finally {
        postsLoading.value = false;
      }
    };

    const loadAvailablePosts = async () => {
      postsLoading.value = true;
      try {
        // 获取所有文章
        const response = await apiService.post.getPosts({ limit: 100 });
        const allPosts = response?.items || [];

        // 过滤掉已经在专栏中的文章
        const columnPostIds = columnPosts.value.map(post => post.id);
        availablePosts.value = allPosts.filter(
          post =>
            !columnPostIds.includes(post.id) &&
            (!postSearchKeyword.value || post.title.includes(postSearchKeyword.value))
        );
      } catch (error) {
        console.error('加载可用文章失败:', error);
        Message.error('加载可用文章失败');
      } finally {
        postsLoading.value = false;
      }
    };

    const searchPosts = () => {
      loadAvailablePosts();
    };

    const addPostToColumn = async postId => {
      try {
        await apiService.columns.addPostToColumn(selectedColumn.value.id, postId);
        Message.success('文章添加成功');
        await loadColumnPosts();
        await loadAvailablePosts();
        // 更新专栏列表中的文章数量
        const columnIndex = columns.value.findIndex(c => c.id === selectedColumn.value.id);
        if (columnIndex !== -1) {
          columns.value[columnIndex].post_count++;
        }
      } catch (error) {
        console.error('添加文章到专栏失败:', error);
        Message.error('添加文章到专栏失败');
      }
    };

    const removePostFromColumn = async postId => {
      try {
        await apiService.columns.removePostFromColumn(selectedColumn.value.id, postId);
        Message.success('文章移除成功');
        await loadColumnPosts();
        await loadAvailablePosts();
        // 更新专栏列表中的文章数量
        const columnIndex = columns.value.findIndex(c => c.id === selectedColumn.value.id);
        if (columnIndex !== -1) {
          columns.value[columnIndex].post_count = Math.max(
            0,
            columns.value[columnIndex].post_count - 1
          );
        }
      } catch (error) {
        console.error('从专栏移除文章失败:', error);
        Message.error('从专栏移除文章失败');
      }
    };

    // 显示创建文章弹窗
    const showCreatePostModalHandler = () => {
      // 重置表单
      Object.assign(postForm, {
        title: '',
        summary: '',
        content: '',
        cover_image_url: '',
        is_visible: true,
      });
      showCreatePostModal.value = true;
    };

    // 创建文章
    const createPost = async () => {
      try {
        creatingPost.value = true;

        // 创建文章
        const postData = {
          title: postForm.title,
          summary: postForm.summary,
          content: postForm.content,
          cover_image_url: postForm.cover_image_url,
          is_visible: postForm.is_visible,
        };

        const newPost = await apiService.post.createPost(postData);

        // 将文章添加到当前专栏
        if (selectedColumn.value) {
          await apiService.columns.addPostToColumn(selectedColumn.value.id, newPost.id);
        }

        Message.success('文章创建成功');
        showCreatePostModal.value = false;

        // 刷新列表
        await loadColumnPosts();
        await loadAvailablePosts();

        // 更新专栏列表中的文章数量
        const columnIndex = columns.value.findIndex(c => c.id === selectedColumn.value.id);
        if (columnIndex !== -1) {
          columns.value[columnIndex].post_count++;
        }
      } catch (error) {
        console.error('创建文章失败:', error);
        Message.error('创建文章失败');
      } finally {
        creatingPost.value = false;
      }
    };

    const handleCoverUpload = response => {
      if (response && response.file_url) {
        columnForm.cover_image_url = response.file_url;
        Message.success('封面上传成功');
      } else {
        Message.error('封面上传失败');
      }
    };

    const handleUploadError = error => {
      console.error('上传失败:', error);
      Message.error('封面上传失败');
    };

    const previewImage = imageUrl => {
      previewImageUrl.value = imageUrl;
      showImagePreview.value = true;
    };

    const handlePageChange = page => {
      currentPage.value = page;
      loadColumns();
    };

    const handlePageSizeChange = size => {
      pageSize.value = size;
      currentPage.value = 1;
      loadColumns();
    };

    // 生成随机封面
    const generateRandomCover = async () => {
      generatingCover.value = true;
      try {
        // 根据专栏名称生成标签
        const tags = generateTagsFromName(columnForm.name);
        console.log('生成封面标签:', tags);

        const response = await apiService.imageSearch.getRandomCover(tags);
        console.log('API响应:', response);

        if (response && response.cover_url) {
          columnForm.cover_image_url = response.cover_url;
          Message.success('随机封面生成成功');
        } else {
          console.error('API响应无效:', response);
          Message.error('生成随机封面失败：API响应无效');
        }
      } catch (error) {
        console.error('生成随机封面失败:', error);
        console.error('错误详情:', error.response?.data);

        if (error.response?.status === 401) {
          Message.error('权限不足，请重新登录');
        } else if (error.response?.status === 403) {
          Message.error('需要管理员权限才能生成封面');
        } else {
          Message.error(`生成随机封面失败: ${error.response?.data?.detail || error.message}`);
        }
      } finally {
        generatingCover.value = false;
      }
    };

    // 批量生成封面
    const batchGenerateCovers = async () => {
      if (selectedColumns.value.length === 0) {
        Message.warning('请先选择要生成封面的专栏');
        return;
      }

      // 初始化进度数据
      initializeProgress();
      showProgressModal.value = true;
      batchGenerating.value = true;
      shouldCancel.value = false;

      try {
        for (let i = 0; i < selectedColumns.value.length; i++) {
          // 检查是否需要取消
          if (shouldCancel.value) {
            break;
          }

          const column = selectedColumns.value[i];
          const progressItem = progressItems.value[i];

          // 更新当前项状态为处理中
          progressItem.status = 'processing';
          progressStats.pending--;

          try {
            console.log(`正在为专栏 "${column.name}" 生成封面...`);
            const tags = generateTagsFromName(column.name);

            const response = await apiService.imageSearch.getRandomCover(tags);

            if (response && response.cover_url) {
              // 更新专栏封面
              await apiService.columns.updateColumn(column.id, {
                cover_image_url: response.cover_url,
              });

              // 更新进度状态
              progressItem.status = 'success';
              progressStats.success++;
              console.log(`专栏 "${column.name}" 封面更新成功`);
            } else {
              progressItem.status = 'failed';
              progressStats.failed++;
              console.error(`专栏 "${column.name}" API响应无效:`, response);
            }
          } catch (error) {
            progressItem.status = 'failed';
            progressStats.failed++;
            console.error(`为专栏 ${column.name} 生成封面失败:`, error);

            if (error.response?.status === 401) {
              Message.error('权限不足，请重新登录');
              break; // 停止批量处理
            } else if (error.response?.status === 403) {
              Message.error('需要管理员权限才能生成封面');
              break; // 停止批量处理
            }
          }

          // 添加小延迟，让用户看到进度变化
          await new Promise(resolve => setTimeout(resolve, 300));
        }

        // 处理完成后的反馈
        if (progressStats.success > 0) {
          loadColumns(); // 重新加载列表
        }
      } catch (error) {
        console.error('批量生成封面失败:', error);
        Message.error('批量生成封面失败');
      } finally {
        batchGenerating.value = false;
      }
    };

    // 根据专栏名称生成搜索标签
    const generateTagsFromName = name => {
      if (!name) return ['设计'];

      const tagMap = {
        技术: ['科技', '编程'],
        编程: ['编程', '代码'],
        开发: ['开发', '科技'],
        设计: ['设计', '艺术'],
        艺术: ['艺术', '设计'],
        摄影: ['艺术', '自然'],
        旅行: ['旅行', '风景'],
        美食: ['食物'],
        音乐: ['音乐', '艺术'],
        运动: ['运动'],
        教育: ['教育'],
        商务: ['商务'],
        医疗: ['医疗'],
        建筑: ['建筑', '城市'],
        自然: ['自然', '风景'],
      };

      // 检查专栏名称中是否包含关键词
      for (const [keyword, tags] of Object.entries(tagMap)) {
        if (name.includes(keyword)) {
          return tags;
        }
      }

      // 默认标签
      return ['设计', '艺术'];
    };

    // 处理表格选择变化
    const handleSelectionChange = selection => {
      selectedColumns.value = selection;
    };

    // 清除选择
    const clearSelection = () => {
      selectedColumns.value = [];
    };

    // 初始化进度数据
    const initializeProgress = () => {
      progressItems.value = selectedColumns.value.map(column => ({
        id: column.id,
        name: column.name,
        tags: generateTagsFromName(column.name),
        status: 'pending', // pending, processing, success, failed
      }));

      progressStats.success = 0;
      progressStats.failed = 0;
      progressStats.pending = selectedColumns.value.length;
    };

    // 关闭进度弹窗
    const closeProgressModal = () => {
      showProgressModal.value = false;
      clearSelection(); // 清除选择

      // 显示最终结果
      const { success, failed } = progressStats;
      if (success > 0 && failed === 0) {
        Message.success(`✅ 成功为 ${success} 个专栏生成封面`);
      } else if (success > 0 && failed > 0) {
        Message.info(`✅ 成功: ${success} 个，❌ 失败: ${failed} 个`);
      } else if (failed > 0) {
        Message.warning(`❌ ${failed} 个专栏封面生成失败`);
      }
    };

    // 取消批量生成
    const cancelBatchGeneration = () => {
      cancelling.value = true;
      shouldCancel.value = true;

      setTimeout(() => {
        cancelling.value = false;
        closeProgressModal();
      }, 1000);
    };

    // 生命周期
    onMounted(() => {
      loadColumns();
    });

    return {
      // 响应式数据
      loading,
      saving,
      postsLoading,
      generatingCover,
      batchGenerating,
      columns,
      selectedColumns,
      total,
      currentPage,
      pageSize,
      searchForm,
      columnForm,
      showCreateModal,
      showPostsModal,
      showImagePreview,
      isEditing,
      editingColumnId,
      previewImageUrl,
      selectedColumn,
      columnPosts,
      availablePosts,
      postSearchKeyword,

      // 创建文章相关
      showCreatePostModal,
      creatingPost,
      postForm,
      postRules,
      columnRules,
      tableColumns,
      columnPostsColumns,
      availablePostsColumns,
      uploadUrl,
      uploadHeaders,

      // 进度相关
      showProgressModal,
      progressItems,
      progressStats,
      progressPercentage,
      cancelling,
      shouldCancel,

      // 方法
      getFullImageUrl,
      loadColumns,
      resetSearch,
      resetForm,
      createNewColumn,
      editColumn,
      saveColumn,
      toggleVisibility,
      deleteColumn,
      manageColumnPosts,
      loadColumnPosts,
      loadAvailablePosts,
      searchPosts,
      addPostToColumn,
      removePostFromColumn,
      showCreatePostModalHandler,
      createPost,
      handleCoverUpload,
      handleUploadError,
      previewImage,
      handlePageChange,
      handlePageSizeChange,
      generateRandomCover,
      batchGenerateCovers,
      generateTagsFromName,
      handleSelectionChange,
      clearSelection,
      initializeProgress,
      closeProgressModal,
      cancelBatchGeneration,
    };
  },
};
</script>

<style scoped>
.columns-management {
  padding: 0;
}

.filter-controls {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 4px;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-buttons {
  display: flex;
  gap: 8px;
}

.action-bar {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  min-height: 40px;
}

.batch-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f0f8ff;
  border: 1px solid #d4edda;
  border-radius: 4px;
}

.selection-info {
  color: #155724;
  font-weight: 500;
  font-size: 14px;
}

.create-actions {
  display: flex;
  align-items: center;
}

.add-column-button {
  position: relative;
  top: 3px;
}

.pagination-wrapper {
  margin-top: 16px;
  text-align: center;
}

.cover-image {
  display: flex;
  justify-content: center;
  align-items: center;
}

.cover-image img {
  max-width: 60px;
  max-height: 40px;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s;
}

.cover-image img:hover {
  transform: scale(1.1);
}

.no-image {
  color: #999;
  font-size: 12px;
}

.cover-upload {
  position: relative;
}

.upload-options {
  display: flex;
  align-items: center;
  gap: 8px;
}

.cover-preview {
  position: relative;
  display: inline-block;
}

.cover-preview img {
  max-width: 200px;
  max-height: 120px;
  border-radius: 4px;
  cursor: pointer;
}

.remove-cover {
  position: absolute;
  top: -8px;
  right: -8px;
  border-radius: 50%;
}

.posts-management {
  max-height: 500px;
  overflow-y: auto;
}

.posts-search {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.posts-section {
  margin-bottom: 16px;
}

.posts-section h4 {
  margin-bottom: 8px;
  color: #333;
}

.image-preview-container {
  text-align: center;
  min-height: 300px;
  max-height: 60vh;
  overflow: auto;
  padding: 16px;
}

.image-preview-container img {
  max-width: 100%;
  max-height: 50vh;
  border-radius: 4px;
}

:deep(.image-preview-modal .ivu-modal-body) {
  padding: 0;
}

:deep(.image-preview-modal .ivu-modal-header) {
  text-align: center;
}

:deep(.image-preview-modal .ivu-modal-footer) {
  text-align: center;
}

/* 进度弹窗样式 */
.progress-container {
  padding: 16px 0;
}

.progress-header {
  margin-bottom: 20px;
}

.progress-header h4 {
  margin: 0 0 12px 0;
  color: #333;
  font-size: 16px;
}

.progress-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.stat-item {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 500;
}

/* 创建文章弹窗样式 */
.create-post-container {
  max-height: 70vh;
  overflow-y: auto;
}

.upload-area {
  width: 200px;
  height: 120px;
  border: 2px dashed #d9d9d9;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: border-color 0.3s;
}

.upload-area:hover {
  border-color: #2d8cf0;
}

.upload-area img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.upload-placeholder {
  text-align: center;
  color: #999;
}

.upload-placeholder p {
  margin: 8px 0 0 0;
  font-size: 14px;
}

.stat-item.success {
  background: #f6ffed;
  color: #52c41a;
  border: 1px solid #b7eb8f;
}

.stat-item.failed {
  background: #fff2f0;
  color: #ff4d4f;
  border: 1px solid #ffccc7;
}

.stat-item.pending {
  background: #f0f8ff;
  color: #1890ff;
  border: 1px solid #91d5ff;
}

.progress-bar-container {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: #f5f5f5;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1890ff 0%, #52c41a 100%);
  transition: width 0.3s ease;
}

.progress-text {
  font-weight: 500;
  color: #333;
  min-width: 40px;
}

.progress-list {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
}

.progress-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.2s ease;
}

.progress-item:last-child {
  border-bottom: none;
}

.progress-item.processing {
  background: #f0f8ff;
  border-left: 3px solid #1890ff;
}

.progress-item.success {
  background: #f6ffed;
  border-left: 3px solid #52c41a;
}

.progress-item.failed {
  background: #fff2f0;
  border-left: 3px solid #ff4d4f;
}

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-name {
  font-weight: 500;
  color: #333;
}

.item-tags {
  font-size: 12px;
  color: #999;
}

.item-status {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
}

.loading-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* 操作按钮样式 */
.action-buttons {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: nowrap;
  white-space: nowrap;
}

/* 进度弹窗的模态框样式 */
:deep(.ivu-modal-mask) {
  background-color: rgba(0, 0, 0, 0.6);
}

:deep(.ivu-modal-wrap) {
  backdrop-filter: blur(2px);
}
</style>
