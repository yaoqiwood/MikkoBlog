<template>
  <div class="tag-cloud-management">
    <div class="page-header">
      <h2>标签云管理</h2>
      <div class="header-actions">
        <Button type="primary" @click="showCreateModal = true">
          <Icon type="ios-add" />
          添加标签
        </Button>
        <Button type="success" @click="fetchTagsNow" :loading="fetching">
          <Icon type="ios-refresh" />
          立即获取
        </Button>
        <Button type="warning" @click="showScheduleModal = true">
          <Icon type="ios-time" />
          调度设置
        </Button>
        <Button type="info" @click="showSearchModal = true">
          <Icon type="ios-search" />
          搜索设置
        </Button>
        <Button type="warning" @click="reassignColors" :loading="reassigningColors">
          <Icon type="ios-color-palette" />
          重新分配颜色
        </Button>
      </div>
    </div>

    <!-- 统计信息 -->
    <Card class="stats-card">
      <div class="stats-grid">
        <div class="stat-item">
          <div class="stat-value">{{ stats.total_tags }}</div>
          <div class="stat-label">总标签数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ stats.active_tags }}</div>
          <div class="stat-label">活跃标签</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ stats.category_stats.length }}</div>
          <div class="stat-label">分类数量</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ stats.source_stats.length }}</div>
          <div class="stat-label">数据源</div>
        </div>
      </div>
    </Card>

    <!-- 筛选器 -->
    <div class="filter-controls">
      <div class="filter-item">
        <label>分类筛选</label>
        <Select v-model="filters.category" placeholder="选择分类" clearable>
          <Option value="">全部分类</Option>
          <Option v-for="cat in categoryOptions" :key="cat" :value="cat">{{ cat }}</Option>
        </Select>
      </div>
      <div class="filter-item">
        <label>状态筛选</label>
        <Select v-model="filters.is_active" placeholder="选择状态" clearable>
          <Option value="">全部状态</Option>
          <Option value="true">活跃</Option>
          <Option value="false">禁用</Option>
        </Select>
      </div>
      <div class="filter-item">
        <label>来源筛选</label>
        <Select v-model="filters.source" placeholder="选择来源" clearable>
          <Option value="">全部来源</Option>
          <Option value="manual">手动添加</Option>
          <Option value="auto">自动获取</Option>
          <Option value="trending">热门趋势</Option>
        </Select>
      </div>
      <div class="filter-item">
        <Button @click="resetFilters">重置筛选</Button>
        <Button type="primary" @click="loadTags">应用筛选</Button>
      </div>
    </div>

    <!-- 标签列表 -->
    <Card>
      <Table
        :columns="tableColumns"
        :data="tags"
        :loading="loading"
        :pagination="pagination"
        @on-page-change="handlePageChange"
        @on-page-size-change="handlePageSizeChange"
        border
        stripe
      >
        <template #size="{ row }">
          <Tag :color="getSizeColor(row.size)">{{ getSizeText(row.size) }}</Tag>
        </template>

        <template #color="{ row }">
          <div class="color-preview" :style="{ backgroundColor: row.color }"></div>
          <span>{{ row.color }}</span>
        </template>

        <template #is_active="{ row }">
          <Tag :color="row.is_active ? 'success' : 'default'">
            {{ row.is_active ? '活跃' : '禁用' }}
          </Tag>
        </template>

        <template #action="{ row }">
          <div class="action-buttons">
            <Button type="primary" size="small" @click="editTag(row)">编辑</Button>
            <Button
              :type="row.is_active ? 'warning' : 'success'"
              size="small"
              @click="toggleTagStatus(row)"
            >
              {{ row.is_active ? '禁用' : '激活' }}
            </Button>
            <Button type="error" size="small" @click="deleteTag(row)">删除</Button>
          </div>
        </template>
      </Table>

      <!-- 手动分页器 -->
      <div class="pagination-wrapper" style="margin-top: 16px; text-align: right">
        <Page
          :current="pagination.current"
          :total="pagination.total"
          :page-size="pagination.pageSize"
          :page-size-opts="pagination.pageSizeOpts"
          :show-total="pagination.showTotal"
          :show-sizer="pagination.showSizer"
          :show-elevator="pagination.showElevator"
          @on-change="handlePageChange"
          @on-page-size-change="handlePageSizeChange"
        />
      </div>
    </Card>

    <!-- 创建/编辑标签弹窗 -->
    <Modal v-model="showCreateModal" :title="isEditing ? '编辑标签' : '创建标签'" width="600">
      <Form ref="tagForm" :model="tagForm" :rules="tagRules" :label-width="100">
        <FormItem label="标签名称" prop="name">
          <Input v-model="tagForm.name" placeholder="请输入标签名称" />
        </FormItem>

        <FormItem label="使用次数" prop="count">
          <InputNumber v-model="tagForm.count" :min="1" placeholder="使用次数" />
        </FormItem>

        <FormItem label="标签大小" prop="size">
          <Select v-model="tagForm.size" placeholder="选择标签大小">
            <Option value="small">小</Option>
            <Option value="medium">中</Option>
            <Option value="large">大</Option>
          </Select>
        </FormItem>

        <FormItem label="标签颜色" prop="color">
          <div class="color-input">
            <Input v-model="tagForm.color" placeholder="#ff6b6b" />
            <div class="color-preview" :style="{ backgroundColor: tagForm.color }"></div>
          </div>
        </FormItem>

        <FormItem label="标签分类" prop="category">
          <Input v-model="tagForm.category" placeholder="请输入标签分类" />
        </FormItem>

        <FormItem label="标签状态">
          <RadioGroup v-model="tagForm.is_active">
            <Radio label="true">活跃</Radio>
            <Radio label="false">禁用</Radio>
          </RadioGroup>
        </FormItem>
      </Form>

      <template #footer>
        <Button @click="showCreateModal = false">取消</Button>
        <Button type="primary" @click="saveTag" :loading="saving">
          {{ isEditing ? '更新' : '创建' }}
        </Button>
      </template>
    </Modal>

    <!-- 获取历史弹窗 -->
    <Modal v-model="showHistoryModal" title="获取历史" width="800">
      <Table :columns="historyColumns" :data="fetchHistory" :loading="historyLoading">
        <template #status="{ row }">
          <Tag :color="getStatusColor(row.status)">{{ getStatusText(row.status) }}</Tag>
        </template>
      </Table>

      <template #footer>
        <Button @click="showHistoryModal = false">关闭</Button>
      </template>
    </Modal>

    <!-- 调度设置弹窗 -->
    <Modal v-model="showScheduleModal" title="调度设置" width="500">
      <Form ref="scheduleForm" :model="scheduleForm" :rules="scheduleRules" :label-width="120">
        <FormItem label="当前调度配置">
          <div class="current-schedule">
            <Icon type="ios-settings" />
            <span>{{ getScheduleDescription(scheduleInfo) }}</span>
          </div>
        </FormItem>

        <FormItem label="下次运行时间">
          <div class="next-run">
            <Icon type="ios-calendar" />
            <span>{{
              scheduleInfo.next_run ? formatDateTime(scheduleInfo.next_run) : '未设置'
            }}</span>
          </div>
        </FormItem>

        <FormItem label="调度频度" prop="frequency">
          <Select v-model="scheduleForm.frequency" placeholder="选择频度" style="width: 200px">
            <Option value="hourly">每小时</Option>
            <Option value="daily">每天</Option>
            <Option value="weekly">每周</Option>
          </Select>
        </FormItem>

        <FormItem label="调度时间" prop="time">
          <TimePicker
            v-model="scheduleForm.time"
            format="HH:mm"
            placeholder="选择时间"
            style="width: 200px"
          />
        </FormItem>

        <FormItem label="星期几" prop="day" v-if="scheduleForm.frequency === 'weekly'">
          <Select v-model="scheduleForm.day" placeholder="选择星期几" style="width: 200px">
            <Option value="monday">星期一</Option>
            <Option value="tuesday">星期二</Option>
            <Option value="wednesday">星期三</Option>
            <Option value="thursday">星期四</Option>
            <Option value="friday">星期五</Option>
            <Option value="saturday">星期六</Option>
            <Option value="sunday">星期日</Option>
          </Select>
        </FormItem>

        <div class="schedule-help">
          <Icon type="ios-information-circle" />
          <span>{{ getScheduleHelpText(scheduleForm.frequency) }}</span>
        </div>
      </Form>

      <template #footer>
        <Button @click="showScheduleModal = false">取消</Button>
        <Button type="primary" @click="updateScheduleConfig" :loading="scheduleUpdating">
          更新调度配置
        </Button>
      </template>
    </Modal>

    <!-- 搜索设置弹窗 -->
    <Modal v-model="showSearchModal" title="搜索设置" width="800">
      <Form ref="searchFormRef" :model="searchForm" :rules="searchRules" :label-width="120">
        <FormItem label="当前搜索关键词">
          <div class="current-keywords">
            <Icon type="ios-search" />
            <span>{{ getCurrentKeywordsText(scheduleInfo.search_keywords) }}</span>
          </div>
        </FormItem>

        <FormItem label="搜索关键词" prop="keywords">
          <Input
            v-model="searchForm.keywords"
            type="textarea"
            :rows="4"
            placeholder="请输入搜索关键词，多个关键词用逗号分隔&#10;例如：AI，大模型，机器学习，深度学习，神经网络"
            style="width: 100%"
            @input="validateKeywords"
          />
          <div class="search-help">
            <Icon type="ios-information-circle" />
            <span
              >支持多个关键词，用中文逗号（，）或英文逗号（,）分隔。系统将从GitHub、Stack
              Overflow等平台搜索相关标签</span
            >
          </div>
        </FormItem>

        <FormItem label="提示词模板" prop="prompt_template">
          <Input
            v-model="searchForm.prompt_template"
            type="textarea"
            :rows="4"
            placeholder="请输入提示词模板"
            style="width: 100%"
          />
          <div class="search-help">
            <Icon type="ios-information-circle" />
            <span>使用{keywords}作为关键词占位符，AI将生成JSON格式的标签数据</span>
          </div>
        </FormItem>

        <FormItem label="示例关键词">
          <div class="keyword-examples">
            <Tag
              v-for="example in keywordExamples"
              :key="example"
              @click.stop="addKeywordExample(example)"
              style="cursor: pointer; margin: 2px"
              class="keyword-tag"
            >
              {{ example }}
            </Tag>
          </div>
        </FormItem>
      </Form>

      <template #footer>
        <Button @click="showSearchModal = false">取消</Button>
        <Button type="primary" @click="updateSearchKeywords" :loading="searchUpdating">
          更新关键词
        </Button>
        <Button type="success" @click="fetchTagsByKeywordsStream" :loading="searchFetching">
          立即搜索
        </Button>
      </template>
    </Modal>

    <!-- AI响应显示弹窗 -->
    <Modal v-model="showAIResponseModal" title="AI响应" width="900" :closable="false">
      <div class="ai-response-container">
        <!-- 状态显示 -->
        <div class="response-status">
          <Icon
            :type="getStatusIcon(aiResponseStatus)"
            :color="getAIStatusColor(aiResponseStatus)"
          />
          <span class="status-text">{{ aiResponseStatusText }}</span>
        </div>

        <!-- AI响应内容 -->
        <div class="ai-response-content">
          <div class="response-label">AI响应内容：</div>
          <div class="response-text" ref="responseTextRef">{{ aiResponseContent }}</div>
        </div>

        <!-- 解析结果 -->
        <div v-if="parsedTags.length > 0" class="parsed-tags">
          <div class="response-label">解析结果（{{ parsedTags.length }}个标签）：</div>
          <div class="tags-preview">
            <Tag
              v-for="(tag, index) in parsedTags.slice(0, 20)"
              :key="index"
              :color="getTagColor(tag.category)"
              class="preview-tag"
            >
              {{ tag.name }}
            </Tag>
            <div v-if="parsedTags.length > 20" class="more-tags">
              还有 {{ parsedTags.length - 20 }} 个标签...
            </div>
          </div>
        </div>

        <!-- 错误信息 -->
        <div v-if="aiResponseError" class="error-message">
          <Icon type="ios-close-circle" color="#ed4014" />
          <span>{{ aiResponseError }}</span>
        </div>

        <!-- 调试信息 -->
        <div
          class="debug-info"
          style="
            margin-top: 10px;
            padding: 8px;
            background: #f0f0f0;
            border-radius: 4px;
            font-size: 12px;
          "
        >
          <div>调试信息：</div>
          <div>parsedTags.length: {{ parsedTags.length }}</div>
          <div>aiResponseError: "{{ aiResponseError }}"</div>
          <div>!!aiResponseError: {{ !!aiResponseError }}</div>
          <div>isConfirmButtonDisabled: {{ isConfirmButtonDisabled }}</div>
          <div>
            按钮禁用条件: {{ parsedTags.length === 0 || !!aiResponseError ? 'true' : 'false' }}
          </div>
          <div>按钮实际状态: {{ isConfirmButtonDisabled ? '禁用' : '启用' }}</div>
        </div>
      </div>

      <template #footer>
        <Button @click="cancelAIResponse" :disabled="searchFetching">取消</Button>
        <Button
          type="success"
          @click="applyTagsData"
          :loading="applyingTags"
          :disabled="isConfirmButtonDisabled"
        >
          确认应用 ({{ parsedTags.length }}个标签)
        </Button>
      </template>
    </Modal>
  </div>
</template>

<script>
import { tagCloudApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { computed, nextTick, onMounted, reactive, ref } from 'vue';

export default {
  name: 'TagCloudManagement',
  setup() {
    // 响应式数据
    const loading = ref(false);
    const saving = ref(false);
    const fetching = ref(false);
    const historyLoading = ref(false);
    const tags = ref([]);
    const fetchHistory = ref([]);
    const stats = ref({
      total_tags: 0,
      active_tags: 0,
      category_stats: [],
      source_stats: [],
    });

    // 弹窗状态
    const showCreateModal = ref(false);
    const showHistoryModal = ref(false);
    const showScheduleModal = ref(false);
    const showSearchModal = ref(false);
    const isEditing = ref(false);
    const editingTagId = ref(null);

    // 筛选器
    const filters = reactive({
      category: '',
      is_active: '',
      source: '',
    });

    // 分页
    const pagination = reactive({
      current: 1,
      pageSize: 10,
      total: 0,
      pageSizeOpts: [10, 20, 50, 100],
      showTotal: true,
      showSizer: true,
      showElevator: true,
    });

    // 表单数据
    const tagForm = ref({
      name: '',
      count: 1,
      size: 'medium',
      color: '#ff6b6b',
      category: 'general',
      is_active: 'true',
    });

    // 表单验证规则
    const tagRules = {
      name: [{ required: true, message: '请输入标签名称', trigger: 'blur' }],
      count: [{ required: true, message: '请输入使用次数', trigger: 'blur' }],
      size: [{ required: true, message: '请选择标签大小', trigger: 'change' }],
      color: [{ required: true, message: '请输入标签颜色', trigger: 'blur' }],
      category: [{ required: true, message: '请输入标签分类', trigger: 'blur' }],
    };

    // 调度相关数据
    const scheduleUpdating = ref(false);
    const scheduleInfo = ref({
      frequency: 'daily',
      time: '02:00',
      day: 'monday',
      next_run: null,
      search_keywords: [],
    });
    const scheduleForm = ref({
      frequency: 'daily',
      time: '',
      day: 'monday',
    });
    const scheduleRules = {
      frequency: [{ required: true, message: '请选择调度频度', trigger: 'change' }],
      time: [{ required: true, message: '请选择调度时间', trigger: 'change' }],
      day: [{ required: true, message: '请选择星期几', trigger: 'change' }],
    };

    // 搜索相关数据
    const searchUpdating = ref(false);
    const searchFetching = ref(false);
    const searchFormRef = ref(null);
    const searchForm = ref({
      keywords: '',
      prompt_template:
        '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]',
    });
    const searchRules = {
      keywords: [{ required: true, message: '请输入搜索关键词', trigger: 'blur' }],
      prompt_template: [{ required: true, message: '请输入提示词模板', trigger: 'change' }],
    };
    const keywordExamples = ref([
      'AI',
      '大模型',
      '机器学习',
      '深度学习',
      '神经网络',
      'React',
      'Vue',
      'Angular',
      'Node.js',
      'Python',
      'Web开发',
      '移动开发',
      '数据科学',
      'DevOps',
      '云计算',
    ]);

    // AI响应相关数据
    const showAIResponseModal = ref(false);
    const aiResponseContent = ref('');
    const aiResponseStatus = ref('idle'); // idle, loading, success, error
    const aiResponseStatusText = ref('');
    const aiResponseError = ref('');
    const parsedTags = ref([]);
    const applyingTags = ref(false);
    const responseTextRef = ref(null);
    const reassigningColors = ref(false);

    // 计算属性：按钮是否应该被禁用
    const isConfirmButtonDisabled = computed(() => {
      const hasError = !!aiResponseError.value;
      const hasNoTags = parsedTags.value.length === 0;
      const result = hasNoTags || hasError;
      console.log('按钮禁用计算:', {
        hasNoTags,
        hasError,
        result,
        tagsLength: parsedTags.value.length,
        error: aiResponseError.value,
      });
      return result;
    });

    // 表格列定义
    const tableColumns = [
      { title: 'ID', key: 'id', width: 80 },
      { title: '标签名称', key: 'name', width: 150 },
      { title: '使用次数', key: 'count', width: 100 },
      { title: '大小', key: 'size', slot: 'size', width: 100 },
      { title: '颜色', key: 'color', slot: 'color', width: 120 },
      { title: '分类', key: 'category', width: 100 },
      { title: '来源', key: 'source', width: 100 },
      { title: '状态', key: 'is_active', slot: 'is_active', width: 100 },
      { title: '创建时间', key: 'created_at', width: 150 },
      { title: '操作', key: 'action', slot: 'action', width: 200 },
    ];

    // 历史记录列定义
    const historyColumns = [
      { title: '获取日期', key: 'fetch_date', width: 120 },
      { title: '数据源', key: 'source', width: 100 },
      { title: '总标签数', key: 'total_tags', width: 100 },
      { title: '新增标签', key: 'new_tags', width: 100 },
      { title: '更新标签', key: 'updated_tags', width: 100 },
      { title: '状态', key: 'status', slot: 'status', width: 100 },
      { title: '创建时间', key: 'created_at', width: 150 },
    ];

    // 分类选项
    const categoryOptions = ref([]);

    // 方法
    const loadTags = async () => {
      loading.value = true;
      try {
        const params = {
          page: pagination.current,
          page_size: pagination.pageSize,
        };

        if (filters.category) params.category = filters.category;
        if (filters.is_active !== '') params.isActive = filters.is_active === 'true';
        if (filters.source) params.source = filters.source;

        const response = await tagCloudApi.getTags(params);
        tags.value = response.items || [];
        pagination.total = response.total || 0;
      } catch (error) {
        console.error('加载标签失败:', error);
        Message.error('加载标签失败');
      } finally {
        loading.value = false;
      }
    };

    const loadStats = async () => {
      try {
        const response = await tagCloudApi.getStats();
        stats.value = response;

        // 更新分类选项
        categoryOptions.value = response.category_stats.map(item => item.category);
      } catch (error) {
        console.error('加载统计信息失败:', error);
      }
    };

    const loadFetchHistory = async () => {
      historyLoading.value = true;
      try {
        const response = await tagCloudApi.getFetchHistory();
        fetchHistory.value = response;
      } catch (error) {
        console.error('加载获取历史失败:', error);
        Message.error('加载获取历史失败');
      } finally {
        historyLoading.value = false;
      }
    };

    const fetchTagsNow = async () => {
      fetching.value = true;
      try {
        // 获取当前的搜索关键词和提示词模板
        const keywords = scheduleInfo.value.search_keywords || [];
        const promptTemplate =
          scheduleInfo.value.prompt_template ||
          '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]';

        if (keywords.length === 0) {
          Message.error('请先在搜索设置中配置搜索关键词');
          return;
        }

        // 重置AI响应数据
        aiResponseContent.value = '';
        aiResponseStatus.value = 'loading';
        aiResponseStatusText.value = '正在连接AI服务器...';
        aiResponseError.value = '';
        parsedTags.value = [];

        // 显示AI响应弹窗
        showAIResponseModal.value = true;

        // 等待DOM更新
        await nextTick();

        // 发起流式请求
        const response = await tagCloudApi.fetchTagsByKeywordsStream(keywords, promptTemplate);

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const reader = response.body.getReader();
        const decoder = new window.TextDecoder();

        try {
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value);
            const lines = chunk.split('\n');

            for (const line of lines) {
              if (line.startsWith('data: ')) {
                try {
                  const data = JSON.parse(line.slice(6));

                  switch (data.type) {
                    case 'start':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'ai_request':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'ai_response':
                      aiResponseContent.value += data.content;
                      // 自动滚动到底部
                      await nextTick();
                      if (responseTextRef.value) {
                        responseTextRef.value.scrollTop = responseTextRef.value.scrollHeight;
                      }
                      break;
                    case 'parse_start':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'parse_success':
                      aiResponseStatus.value = 'success';
                      aiResponseStatusText.value = data.message;
                      parsedTags.value = data.data;
                      aiResponseError.value = ''; // 清空错误信息
                      break;
                    case 'parse_error':
                      aiResponseStatus.value = 'error';
                      aiResponseError.value = data.message;
                      break;
                    case 'complete':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'error':
                      aiResponseStatus.value = 'error';
                      aiResponseError.value = data.message;
                      break;
                  }
                } catch (e) {
                  console.warn('解析流数据失败:', e);
                }
              }
            }
          }
        } finally {
          reader.releaseLock();
        }
      } catch (error) {
        console.error('流式获取标签失败:', error);
        aiResponseStatus.value = 'error';
        aiResponseError.value = `获取失败: ${error.message}`;
        Message.error('获取标签失败');
      } finally {
        fetching.value = false;
      }
    };

    const resetForm = () => {
      Object.assign(tagForm.value, {
        name: '',
        count: 1,
        size: 'medium',
        color: '#ff6b6b',
        category: 'general',
        is_active: 'true',
      });
      isEditing.value = false;
      editingTagId.value = null;
    };

    const editTag = tag => {
      isEditing.value = true;
      editingTagId.value = tag.id;
      Object.assign(tagForm.value, {
        name: tag.name,
        count: tag.count,
        size: tag.size,
        color: tag.color,
        category: tag.category,
        is_active: tag.is_active ? 'true' : 'false',
      });
      showCreateModal.value = true;
    };

    const saveTag = async () => {
      try {
        saving.value = true;

        // 转换数据格式
        const tagData = {
          ...tagForm.value,
          is_active: tagForm.value.is_active === 'true',
        };

        if (isEditing.value) {
          await tagCloudApi.updateTag(editingTagId.value, tagData);
          Message.success('标签更新成功');
        } else {
          await tagCloudApi.createTag(tagData);
          Message.success('标签创建成功');
        }

        showCreateModal.value = false;
        resetForm();
        loadTags();
        loadStats();
      } catch (error) {
        console.error('保存标签失败:', error);
        Message.error('保存标签失败');
      } finally {
        saving.value = false;
      }
    };

    const toggleTagStatus = async tag => {
      try {
        await tagCloudApi.toggleTagStatus(tag.id);
        Message.success(`标签已${tag.is_active ? '禁用' : '激活'}`);
        loadTags();
        loadStats();
      } catch (error) {
        console.error('切换标签状态失败:', error);
        Message.error('切换标签状态失败');
      }
    };

    const deleteTag = async tag => {
      try {
        await tagCloudApi.deleteTag(tag.id);
        Message.success('标签删除成功');
        loadTags();
        loadStats();
      } catch (error) {
        console.error('删除标签失败:', error);
        Message.error('删除标签失败');
      }
    };

    const resetFilters = () => {
      Object.assign(filters, {
        category: '',
        is_active: '',
        source: '',
      });
      loadTags();
    };

    const handlePageChange = page => {
      pagination.current = page;
      loadTags();
    };

    const handlePageSizeChange = pageSize => {
      pagination.pageSize = pageSize;
      pagination.current = 1;
      loadTags();
    };

    // 调度相关方法
    const loadScheduleInfo = async () => {
      try {
        const response = await tagCloudApi.getScheduleConfig();
        scheduleInfo.value = response;

        // 初始化表单数据
        scheduleForm.value.frequency = response.frequency || 'daily';
        scheduleForm.value.time = response.time || '';
        scheduleForm.value.day = response.day || 'monday';

        // 初始化搜索表单数据
        if (response.search_keywords) {
          searchForm.value.keywords = response.search_keywords.join('，');
        }
        if (response.prompt_template) {
          searchForm.value.prompt_template = response.prompt_template;
        }
      } catch (error) {
        console.error('加载调度信息失败:', error);
        Message.error('加载调度信息失败');
      }
    };

    const updateScheduleConfig = async () => {
      try {
        scheduleUpdating.value = true;

        if (!scheduleForm.value.frequency) {
          Message.error('请选择调度频度');
          return;
        }

        if (!scheduleForm.value.time) {
          Message.error('请选择调度时间');
          return;
        }

        if (scheduleForm.value.frequency === 'weekly' && !scheduleForm.value.day) {
          Message.error('请选择星期几');
          return;
        }

        // 格式化时间为 HH:MM
        const timeStr =
          scheduleForm.value.time instanceof Date
            ? scheduleForm.value.time.toTimeString().slice(0, 5)
            : scheduleForm.value.time;

        const config = {
          frequency: scheduleForm.value.frequency,
          time: timeStr,
        };

        if (scheduleForm.value.frequency === 'weekly') {
          config.day = scheduleForm.value.day;
        }

        await tagCloudApi.updateScheduleConfig(config);
        Message.success('调度配置更新成功');

        // 重新加载调度信息
        await loadScheduleInfo();
        showScheduleModal.value = false;
      } catch (error) {
        console.error('更新调度配置失败:', error);
        Message.error('更新调度配置失败');
      } finally {
        scheduleUpdating.value = false;
      }
    };

    const getScheduleDescription = info => {
      if (!info.frequency) return '未设置';

      const frequencyMap = {
        hourly: '每小时',
        daily: '每天',
        weekly: '每周',
      };

      const dayMap = {
        monday: '星期一',
        tuesday: '星期二',
        wednesday: '星期三',
        thursday: '星期四',
        friday: '星期五',
        saturday: '星期六',
        sunday: '星期日',
      };

      let desc = frequencyMap[info.frequency] || info.frequency;

      if (info.time) {
        desc += ` ${info.time}`;
      }

      if (info.frequency === 'weekly' && info.day) {
        desc += ` (${dayMap[info.day] || info.day})`;
      }

      return desc;
    };

    const getScheduleHelpText = frequency => {
      const helpMap = {
        hourly: '每小时在指定分钟执行一次',
        daily: '每天在指定时间执行一次',
        weekly: '每周在指定星期几的指定时间执行一次',
      };
      return helpMap[frequency] || '设置自动获取标签的调度规则';
    };

    // 搜索相关方法
    const updateSearchKeywords = async () => {
      try {
        searchUpdating.value = true;

        if (!searchForm.value.keywords.trim()) {
          Message.error('请输入搜索关键词');
          return;
        }

        const keywords = parseKeywords(searchForm.value.keywords);

        if (keywords.length === 0) {
          Message.error('请输入有效的搜索关键词');
          return;
        }

        if (keywords.length > 10) {
          Message.error('关键词数量不能超过10个');
          return;
        }

        await tagCloudApi.updateSearchKeywords(keywords, searchForm.value.prompt_template);
        Message.success('搜索关键词和提示词模板更新成功');

        // 重新加载调度信息
        await loadScheduleInfo();
        showSearchModal.value = false;
      } catch (error) {
        console.error('更新搜索关键词失败:', error);
        Message.error('更新搜索关键词失败');
      } finally {
        searchUpdating.value = false;
      }
    };

    const fetchTagsByKeywords = async () => {
      try {
        searchFetching.value = true;

        if (!searchForm.value.keywords.trim()) {
          Message.error('请输入搜索关键词');
          return;
        }

        const keywords = parseKeywords(searchForm.value.keywords);

        if (keywords.length === 0) {
          Message.error('请输入有效的搜索关键词');
          return;
        }

        await tagCloudApi.fetchTagsByKeywords(keywords, searchForm.value.prompt_template);
        Message.success('关键词搜索任务已启动，请稍后查看结果');

        // 延迟刷新数据
        window.setTimeout(() => {
          loadTags();
          loadStats();
        }, 3000);

        showSearchModal.value = false;
      } catch (error) {
        console.error('启动关键词搜索失败:', error);
        Message.error('启动关键词搜索失败');
      } finally {
        searchFetching.value = false;
      }
    };

    const fetchTagsByKeywordsStream = async () => {
      try {
        searchFetching.value = true;

        if (!searchForm.value.keywords.trim()) {
          Message.error('请输入搜索关键词');
          return;
        }

        const keywords = parseKeywords(searchForm.value.keywords);

        if (keywords.length === 0) {
          Message.error('请输入有效的搜索关键词');
          return;
        }

        // 重置AI响应数据
        aiResponseContent.value = '';
        aiResponseStatus.value = 'loading';
        aiResponseStatusText.value = '正在连接AI服务器...';
        aiResponseError.value = '';
        parsedTags.value = [];

        // 显示AI响应弹窗
        showAIResponseModal.value = true;
        showSearchModal.value = false;

        // 等待DOM更新
        await nextTick();

        // 发起流式请求
        const response = await tagCloudApi.fetchTagsByKeywordsStream(
          keywords,
          searchForm.value.prompt_template
        );

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const reader = response.body.getReader();
        const decoder = new window.TextDecoder();

        try {
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value);
            const lines = chunk.split('\n');

            for (const line of lines) {
              if (line.startsWith('data: ')) {
                try {
                  const data = JSON.parse(line.slice(6));

                  switch (data.type) {
                    case 'start':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'ai_request':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'ai_response':
                      aiResponseContent.value += data.content;
                      // 自动滚动到底部
                      await nextTick();
                      if (responseTextRef.value) {
                        responseTextRef.value.scrollTop = responseTextRef.value.scrollHeight;
                      }
                      break;
                    case 'parse_start':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'parse_success':
                      aiResponseStatus.value = 'success';
                      aiResponseStatusText.value = data.message;
                      parsedTags.value = data.data;
                      aiResponseError.value = ''; // 清空错误信息
                      break;
                    case 'parse_error':
                      aiResponseStatus.value = 'error';
                      aiResponseError.value = data.message;
                      break;
                    case 'complete':
                      aiResponseStatusText.value = data.message;
                      break;
                    case 'error':
                      aiResponseStatus.value = 'error';
                      aiResponseError.value = data.message;
                      break;
                  }
                } catch (e) {
                  console.warn('解析流数据失败:', e);
                }
              }
            }
          }
        } finally {
          reader.releaseLock();
        }
      } catch (error) {
        console.error('流式获取标签失败:', error);
        aiResponseStatus.value = 'error';
        aiResponseError.value = `获取失败: ${error.message}`;
        Message.error('获取标签失败');
      } finally {
        searchFetching.value = false;
      }
    };

    const getCurrentKeywordsText = keywords => {
      if (!keywords || keywords.length === 0) {
        return '未设置搜索关键词';
      }
      return keywords.join('，');
    };

    const addKeywordExample = async example => {
      console.log('点击示例关键词:', example);
      console.log('当前输入框内容:', searchForm.value.keywords);

      // 检查是否已存在该关键词
      const currentKeywords = searchForm.value.keywords || '';
      const existingKeywords = parseKeywords(currentKeywords);

      if (existingKeywords.includes(example)) {
        Message.warning(`关键词"${example}"已存在，无法重复添加`);
        return;
      }

      // 添加新关键词
      const newKeywords = currentKeywords + (currentKeywords ? '，' : '') + example;
      searchForm.value.keywords = newKeywords;

      console.log('更新后的输入框内容:', searchForm.value.keywords);

      // 确保DOM更新
      await nextTick();
      console.log('DOM更新后的输入框内容:', searchForm.value.keywords);

      // 显示成功消息
      Message.success(`已添加关键词: ${example}`);
    };

    const parseKeywords = keywordsStr => {
      // 支持中文逗号和英文逗号混写
      return keywordsStr
        .split(/[,，]/)
        .map(k => k.trim())
        .filter(k => k);
    };

    const validateKeywords = () => {
      const keywords = parseKeywords(searchForm.value.keywords);
      const uniqueKeywords = [...new Set(keywords)];

      if (keywords.length !== uniqueKeywords.length) {
        // 有重复关键词，自动去重
        const deduplicatedText = uniqueKeywords.join('，');
        searchForm.value.keywords = deduplicatedText;
        Message.warning('检测到重复关键词，已自动去重');
      }
    };

    const formatDateTime = dateTimeStr => {
      if (!dateTimeStr) return '未设置';
      const date = new Date(dateTimeStr);
      return date.toLocaleString('zh-CN');
    };

    // AI响应相关方法
    const cancelAIResponse = () => {
      showAIResponseModal.value = false;
      aiResponseContent.value = '';
      aiResponseStatus.value = 'idle';
      aiResponseStatusText.value = '';
      aiResponseError.value = '';
      parsedTags.value = [];
    };

    const applyTagsData = async () => {
      try {
        applyingTags.value = true;

        await tagCloudApi.applyTagsData(parsedTags.value);
        Message.success(`成功应用 ${parsedTags.value.length} 个标签`);

        // 关闭弹窗并刷新数据
        showAIResponseModal.value = false;
        await loadTags();
        await loadStats();
      } catch (error) {
        console.error('应用标签数据失败:', error);
        Message.error('应用标签数据失败');
      } finally {
        applyingTags.value = false;
      }
    };

    const reassignColors = async () => {
      try {
        reassigningColors.value = true;

        await tagCloudApi.reassignColors();
        Message.success('标签颜色重新分配成功');

        // 刷新数据
        await loadTags();
        await loadStats();
      } catch (error) {
        console.error('重新分配颜色失败:', error);
        Message.error('重新分配颜色失败');
      } finally {
        reassigningColors.value = false;
      }
    };

    const getStatusIcon = status => {
      const icons = {
        idle: 'ios-help-circle',
        loading: 'ios-loading',
        success: 'ios-checkmark-circle',
        error: 'ios-close-circle',
      };
      return icons[status] || 'ios-help-circle';
    };

    const getAIStatusColor = status => {
      const colors = {
        idle: '#999',
        loading: '#2d8cf0',
        success: '#19be6b',
        error: '#ed4014',
      };
      return colors[status] || '#999';
    };

    const getTagColor = category => {
      // 美观的颜色调色板 - 与后端保持一致
      const beautifulColors = [
        // 蓝色系
        '#3498db',
        '#2980b9',
        '#5dade2',
        '#85c1e9',
        // 绿色系
        '#27ae60',
        '#2ecc71',
        '#58d68d',
        '#82e0aa',
        // 紫色系
        '#8e44ad',
        '#9b59b6',
        '#bb8fce',
        '#d2b4de',
        // 橙色系
        '#e67e22',
        '#f39c12',
        '#f7dc6f',
        '#f9e79f',
        // 红色系
        '#e74c3c',
        '#ec7063',
        '#f1948a',
        '#f5b7b1',
        // 青色系
        '#1abc9c',
        '#48c9b0',
        '#7fb3d3',
        '#aed6f1',
        // 粉色系
        '#e91e63',
        '#f06292',
        '#f8bbd9',
        '#fce4ec',
        // 深色系
        '#34495e',
        '#5d6d7e',
        '#85929e',
        '#b2babb',
        // 暖色系
        '#d35400',
        '#e67e22',
        '#f39c12',
        '#f1c40f',
        // 冷色系
        '#16a085',
        '#27ae60',
        '#2ecc71',
        '#58d68d',
      ];

      // 基于分类名称生成一致的随机颜色
      // 使用简单的哈希函数来确保相同分类总是得到相同颜色
      let hash = 0;
      for (let i = 0; i < category.length; i++) {
        const char = category.charCodeAt(i);
        hash = (hash << 5) - hash + char;
        hash = hash & hash; // 转换为32位整数
      }

      const colorIndex = Math.abs(hash) % beautifulColors.length;
      return beautifulColors[colorIndex];
    };

    // 工具方法
    const getSizeColor = size => {
      const colors = {
        small: 'default',
        medium: 'primary',
        large: 'success',
      };
      return colors[size] || 'default';
    };

    const getSizeText = size => {
      const texts = {
        small: '小',
        medium: '中',
        large: '大',
      };
      return texts[size] || '中';
    };

    const getStatusColor = status => {
      const colors = {
        success: 'success',
        failed: 'error',
        partial: 'warning',
      };
      return colors[status] || 'default';
    };

    const getStatusText = status => {
      const texts = {
        success: '成功',
        failed: '失败',
        partial: '部分成功',
      };
      return texts[status] || '未知';
    };

    // 生命周期
    onMounted(() => {
      loadTags();
      loadStats();
      loadScheduleInfo();
    });

    return {
      // 响应式数据
      loading,
      saving,
      fetching,
      historyLoading,
      tags,
      fetchHistory,
      stats,
      showCreateModal,
      showHistoryModal,
      showScheduleModal,
      showSearchModal,
      isEditing,
      editingTagId,
      filters,
      pagination,
      tagForm,
      tagRules,
      tableColumns,
      historyColumns,
      categoryOptions,
      scheduleUpdating,
      scheduleInfo,
      scheduleForm,
      scheduleRules,
      searchUpdating,
      searchFetching,
      searchFormRef,
      searchForm,
      searchRules,
      keywordExamples,
      showAIResponseModal,
      aiResponseContent,
      aiResponseStatus,
      aiResponseStatusText,
      aiResponseError,
      parsedTags,
      applyingTags,
      responseTextRef,
      reassigningColors,
      isConfirmButtonDisabled,

      // 方法
      loadTags,
      loadStats,
      loadFetchHistory,
      fetchTagsNow,
      resetForm,
      editTag,
      saveTag,
      toggleTagStatus,
      deleteTag,
      resetFilters,
      handlePageChange,
      handlePageSizeChange,
      loadScheduleInfo,
      updateScheduleConfig,
      getScheduleDescription,
      getScheduleHelpText,
      updateSearchKeywords,
      fetchTagsByKeywords,
      fetchTagsByKeywordsStream,
      getCurrentKeywordsText,
      addKeywordExample,
      parseKeywords,
      validateKeywords,
      formatDateTime,
      cancelAIResponse,
      applyTagsData,
      reassignColors,
      getStatusIcon,
      getAIStatusColor,
      getTagColor,
      getSizeColor,
      getSizeText,
      getStatusColor,
      getStatusText,
    };
  },
};
</script>

<style scoped>
.tag-cloud-management {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.stats-card {
  margin-bottom: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #2d8cf0;
  margin-bottom: 5px;
}

.stat-label {
  color: #666;
  font-size: 14px;
}

.filter-controls {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 4px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-item:last-child {
  flex-direction: row;
  align-items: flex-end;
  gap: 8px;
  margin-top: 20px;
  justify-content: flex-start;
}

.filter-item label {
  font-size: 14px;
  color: #666;
}

.action-buttons {
  display: flex;
  gap: 4px;
}

.color-preview {
  width: 20px;
  height: 20px;
  border-radius: 4px;
  border: 1px solid #ddd;
  display: inline-block;
  margin-right: 8px;
  vertical-align: middle;
}

.color-input {
  display: flex;
  align-items: center;
  gap: 10px;
}

.current-schedule,
.next-run {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #e9ecef;
}

.schedule-help {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 4px;
  font-size: 12px;
  color: #666;
}

.current-keywords {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #e9ecef;
}

.search-help {
  display: flex;
  align-items: flex-start;
  gap: 4px;
  margin-top: 4px;
  font-size: 12px;
  color: #666;
}

.search-help .ivu-icon {
  margin-top: 10px;
}

.keyword-examples {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.keyword-tag {
  transition: all 0.3s ease;
  user-select: none;
}

.keyword-tag:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

/* AI响应弹窗样式 */
.ai-response-container {
  max-height: 600px;
  overflow-y: auto;
}

.response-status {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 4px;
  margin-bottom: 16px;
  border-left: 4px solid #2d8cf0;
}

.status-text {
  font-weight: 500;
  color: #333;
}

.ai-response-content {
  margin-bottom: 16px;
}

.response-label {
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
}

.response-text {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 4px;
  padding: 12px;
  font-family: 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.5;
  max-height: 200px;
  overflow-y: auto;
  white-space: pre-wrap;
  word-break: break-all;
}

.parsed-tags {
  margin-bottom: 16px;
}

.tags-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  max-height: 150px;
  overflow-y: auto;
  padding: 8px;
  background: #f8f9fa;
  border-radius: 4px;
}

.preview-tag {
  margin: 0;
}

.more-tags {
  color: #666;
  font-size: 12px;
  align-self: center;
}

.error-message {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #fff2f0;
  border: 1px solid #ffccc7;
  border-radius: 4px;
  color: #ed4014;
}

/* 分页器样式 */
:deep(.ivu-page) {
  margin-top: 16px;
  text-align: right;
}

:deep(.ivu-page-total) {
  color: #666;
  font-size: 14px;
}

:deep(.ivu-page-sizer) {
  margin-right: 16px;
}

:deep(.ivu-page-elevator) {
  margin-left: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .filter-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .filter-item:last-child {
    margin-top: 10px;
    justify-content: center;
  }
}
</style>
