<template>
  <div class="system-settings">
    <div class="page-header">
      <h2>系统默认参数设置</h2>
      <p>管理系统默认配置和参数</p>
    </div>

    <div class="settings-container">
      <!-- 分类筛选 -->
      <div class="filter-section">
        <div class="filter-controls">
          <Select
            v-model="selectedCategory"
            placeholder="选择分类"
            clearable
            style="width: 200px; margin-right: 10px"
            @on-change="handleCategoryChange"
          >
            <Option value="">全部分类</Option>
            <Option v-for="category in categories" :key="category" :value="category">
              {{ category }}
            </Option>
          </Select>
          <Button type="primary" @click="loadDefaults">刷新</Button>
          <Button type="success" @click="showCreateModal = true" style="margin-left: 10px">
            新增参数
          </Button>
        </div>
      </div>

      <!-- 参数列表 -->
      <div class="table-section">
        <Table :columns="columns" :data="defaults" :loading="loading" stripe border height="600">
          <template #action="{ row }">
            <div class="action-buttons">
              <Button
                type="primary"
                size="small"
                @click="editDefault(row)"
                :disabled="!row.is_editable"
              >
                编辑
              </Button>
              <Button
                type="error"
                size="small"
                @click="deleteDefault(row)"
                :disabled="!row.is_editable"
                style="margin-left: 5px"
              >
                删除
              </Button>
            </div>
          </template>
        </Table>
      </div>
    </div>

    <!-- 创建/编辑模态框 -->
    <Modal
      v-model="showCreateModal"
      :title="editingDefault ? '编辑参数' : '新增参数'"
      width="600"
      @on-cancel="resetForm"
    >
      <Form :model="formData" :rules="formRules" ref="formRef" label-width="120">
        <FormItem label="分类" prop="category">
          <Input v-model="formData.category" placeholder="请输入分类" />
        </FormItem>
        <FormItem label="键名" prop="key_name">
          <Input v-model="formData.key_name" placeholder="请输入键名" />
        </FormItem>
        <FormItem label="键值" prop="key_value">
          <Input v-model="formData.key_value" type="textarea" :rows="3" placeholder="请输入键值" />
        </FormItem>
        <FormItem label="描述" prop="description">
          <Input v-model="formData.description" placeholder="请输入描述" />
        </FormItem>
        <FormItem label="数据类型" prop="data_type">
          <Select v-model="formData.data_type" placeholder="选择数据类型">
            <Option value="string">字符串</Option>
            <Option value="number">数字</Option>
            <Option value="boolean">布尔值</Option>
            <Option value="json">JSON</Option>
            <Option value="url">URL</Option>
          </Select>
        </FormItem>
        <FormItem label="是否可编辑">
          <Switch v-model="formData.is_editable" />
        </FormItem>
        <FormItem label="是否公开">
          <Switch v-model="formData.is_public" />
        </FormItem>
        <FormItem label="排序">
          <InputNumber v-model="formData.sort_order" :min="0" />
        </FormItem>
      </Form>
      <template #footer>
        <Button @click="resetForm">取消</Button>
        <Button type="primary" :loading="saving" @click="saveDefault">
          {{ editingDefault ? '更新' : '创建' }}
        </Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { systemApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { onMounted, reactive, ref } from 'vue';

// 响应式数据
const loading = ref(false);
const saving = ref(false);
const selectedCategory = ref('');
const categories = ref([]);
const defaults = ref([]);
const showCreateModal = ref(false);
const editingDefault = ref(null);
const formRef = ref(null);

// 表单数据
const formData = reactive({
  category: '',
  key_name: '',
  key_value: '',
  description: '',
  data_type: 'string',
  is_editable: true,
  is_public: false,
  sort_order: 0,
});

// 表单验证规则
const formRules = {
  category: [{ required: true, message: '请输入分类', trigger: 'blur' }],
  key_name: [{ required: true, message: '请输入键名', trigger: 'blur' }],
  data_type: [{ required: true, message: '请选择数据类型', trigger: 'change' }],
};

// 表格列配置
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80,
  },
  {
    title: '分类',
    key: 'category',
    width: 120,
  },
  {
    title: '键名',
    key: 'key_name',
    width: 150,
  },
  {
    title: '键值',
    key: 'key_value',
    minWidth: 200,
    render: (h, params) => {
      const value = params.row.key_value;
      if (value && value.length > 50) {
        return h('span', { title: value }, value.substring(0, 50) + '...');
      }
      return h('span', value || '');
    },
  },
  {
    title: '数据类型',
    key: 'data_type',
    width: 100,
  },
  {
    title: '可编辑',
    key: 'is_editable',
    width: 80,
    render: (h, params) => {
      return h(
        'Tag',
        {
          color: params.row.is_editable ? 'green' : 'red',
        },
        params.row.is_editable ? '是' : '否'
      );
    },
  },
  {
    title: '公开',
    key: 'is_public',
    width: 80,
    render: (h, params) => {
      return h(
        'Tag',
        {
          color: params.row.is_public ? 'blue' : 'default',
        },
        params.row.is_public ? '是' : '否'
      );
    },
  },
  {
    title: '排序',
    key: 'sort_order',
    width: 80,
  },
  {
    title: '操作',
    slot: 'action',
    width: 150,
    fixed: 'right',
  },
];

// 加载分类列表
const loadCategories = async () => {
  try {
    const response = await systemApi.getCategories();
    categories.value = response.data || response;
  } catch (error) {
    console.error('加载分类失败:', error);
    Message.error('加载分类失败!');
  }
};

// 加载默认参数列表
const loadDefaults = async () => {
  loading.value = true;
  try {
    const params = {};
    if (selectedCategory.value) {
      params.category = selectedCategory.value;
    }

    const response = await systemApi.getDefaults(params);
    defaults.value = response.data || response;
  } catch (error) {
    console.error('加载参数失败:', error);
    Message.error('加载参数失败!');
  } finally {
    loading.value = false;
  }
};

// 分类变化处理
const handleCategoryChange = () => {
  loadDefaults();
};

// 编辑参数
const editDefault = defaultItem => {
  editingDefault.value = defaultItem;
  Object.assign(formData, {
    category: defaultItem.category,
    key_name: defaultItem.key_name,
    key_value: defaultItem.key_value,
    description: defaultItem.description,
    data_type: defaultItem.data_type,
    is_editable: defaultItem.is_editable,
    is_public: defaultItem.is_public,
    sort_order: defaultItem.sort_order,
  });
  showCreateModal.value = true;
};

// 删除参数
const deleteDefault = async defaultItem => {
  if (!defaultItem.is_editable) {
    Message.warning('该参数不可删除!');
    return;
  }

  try {
    await systemApi.deleteDefault(defaultItem.id);
    Message.success('删除成功!');
    loadDefaults();
  } catch (error) {
    console.error('删除失败:', error);
    Message.error('删除失败!');
  }
};

// 保存参数
const saveDefault = async () => {
  try {
    await formRef.value.validate();

    saving.value = true;

    if (editingDefault.value) {
      await systemApi.updateDefault(editingDefault.value.id, formData);
      Message.success('更新成功!');
    } else {
      await systemApi.createDefault(formData);
      Message.success('创建成功!');
    }

    showCreateModal.value = false;
    resetForm();
    loadDefaults();
  } catch (error) {
    console.error('保存失败:', error);
    Message.error('保存失败!');
  } finally {
    saving.value = false;
  }
};

// 重置表单
const resetForm = () => {
  editingDefault.value = null;
  Object.assign(formData, {
    category: '',
    key_name: '',
    key_value: '',
    description: '',
    data_type: 'string',
    is_editable: true,
    is_public: false,
    sort_order: 0,
  });
  formRef.value?.resetFields();
};

// 生命周期
onMounted(() => {
  loadCategories();
  loadDefaults();
});
</script>

<style scoped>
.system-settings {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
  text-align: center;
}

.page-header h2 {
  font-size: 24px;
  color: #333;
  margin-bottom: 8px;
}

.page-header p {
  color: #666;
  font-size: 14px;
}

.settings-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.filter-section {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
}

.filter-controls {
  display: flex;
  align-items: center;
}

.table-section {
  padding: 20px;
}

.action-buttons {
  display: flex;
  gap: 5px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .system-settings {
    padding: 10px;
  }

  .filter-controls {
    flex-direction: column;
    gap: 10px;
  }

  .filter-controls .ivu-btn {
    margin-left: 0 !important;
  }
}
</style>
