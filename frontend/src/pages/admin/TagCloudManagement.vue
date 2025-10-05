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
    <Modal v-model="showSearchModal" title="搜索设置" width="600">
      <Form ref="searchForm" :model="searchForm" :rules="searchRules" :label-width="120">
        <FormItem label="当前搜索关键词">
          <div class="current-keywords">
            <Icon type="ios-search" />
            <span>{{ getCurrentKeywordsText(scheduleInfo.search_keywords) }}</span>
          </div>
        </FormItem>

        <FormItem label="搜索关键词" prop="keywords">
          <Input
            v-model="searchKeywords"
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
        <Button type="success" @click="fetchTagsByKeywords" :loading="searchFetching">
          立即搜索
        </Button>
      </template>
    </Modal>
  </div>
</template>

<script>
import { tagCloudApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { nextTick, onMounted, reactive, ref } from 'vue';

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
    const searchKeywords = ref('');
    const searchForm = ref({
      keywords: '',
    });
    const searchRules = {
      keywords: [{ required: true, message: '请输入搜索关键词', trigger: 'blur' }],
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
          limit: pagination.pageSize,
          page: pagination.current,
        };

        if (filters.category) params.category = filters.category;
        if (filters.is_active !== '') params.is_active = filters.is_active === 'true';
        if (filters.source) params.source = filters.source;

        const response = await tagCloudApi.getTags(params);
        tags.value = response.items || response;
        pagination.total = response.total || response.length;
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
        await tagCloudApi.fetchTagsNow();
        Message.success('标签获取任务已启动');
        // 延迟刷新数据
        window.setTimeout(() => {
          loadTags();
          loadStats();
        }, 2000);
      } catch (error) {
        console.error('启动获取任务失败:', error);
        if (error.response?.status === 401) {
          Message.error('请先登录管理员账户');
        } else if (error.response?.status === 403) {
          Message.error('权限不足，需要管理员权限');
        } else {
          Message.error('启动获取任务失败: ' + (error.message || '未知错误'));
        }
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

        if (!searchKeywords.value.trim()) {
          Message.error('请输入搜索关键词');
          return;
        }

        const keywords = parseKeywords(searchKeywords.value);

        if (keywords.length === 0) {
          Message.error('请输入有效的搜索关键词');
          return;
        }

        if (keywords.length > 10) {
          Message.error('关键词数量不能超过10个');
          return;
        }

        await tagCloudApi.updateSearchKeywords(keywords);
        Message.success('搜索关键词更新成功');

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

        if (!searchKeywords.value.trim()) {
          Message.error('请输入搜索关键词');
          return;
        }

        const keywords = parseKeywords(searchKeywords.value);

        if (keywords.length === 0) {
          Message.error('请输入有效的搜索关键词');
          return;
        }

        await tagCloudApi.fetchTagsByKeywords(keywords);
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

    const getCurrentKeywordsText = keywords => {
      if (!keywords || keywords.length === 0) {
        return '未设置搜索关键词';
      }
      return keywords.join('，');
    };

    const addKeywordExample = async example => {
      console.log('点击示例关键词:', example);
      console.log('当前输入框内容:', searchKeywords.value);

      // 检查是否已存在该关键词
      const currentKeywords = searchKeywords.value || '';
      const existingKeywords = parseKeywords(currentKeywords);

      if (existingKeywords.includes(example)) {
        Message.warning(`关键词"${example}"已存在，无法重复添加`);
        return;
      }

      // 添加新关键词
      const newKeywords = currentKeywords + (currentKeywords ? '，' : '') + example;
      searchKeywords.value = newKeywords;

      console.log('更新后的输入框内容:', searchKeywords.value);

      // 确保DOM更新
      await nextTick();
      console.log('DOM更新后的输入框内容:', searchKeywords.value);

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
      const keywords = parseKeywords(searchKeywords.value);
      const uniqueKeywords = [...new Set(keywords)];

      if (keywords.length !== uniqueKeywords.length) {
        // 有重复关键词，自动去重
        const deduplicatedText = uniqueKeywords.join('，');
        searchKeywords.value = deduplicatedText;
        Message.warning('检测到重复关键词，已自动去重');
      }
    };

    const formatDateTime = dateTimeStr => {
      if (!dateTimeStr) return '未设置';
      const date = new Date(dateTimeStr);
      return date.toLocaleString('zh-CN');
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
      searchKeywords,
      searchForm,
      searchRules,
      keywordExamples,

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
      getCurrentKeywordsText,
      addKeywordExample,
      parseKeywords,
      validateKeywords,
      formatDateTime,
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
