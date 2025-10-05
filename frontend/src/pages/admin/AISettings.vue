<template>
  <div class="ai-settings">
    <Card>
      <template #title>
        <Icon type="ios-settings" />
        AI设置
      </template>

      <Form ref="aiForm" :model="aiForm" :rules="aiRules" :label-width="120">
        <FormItem label="AI服务提供商" prop="provider">
          <Select
            v-model="aiForm.provider"
            placeholder="选择AI服务提供商"
            style="width: 300px"
            @change="onProviderChange"
          >
            <Option value="openai">OpenAI</Option>
            <Option value="claude">Claude (Anthropic)</Option>
            <Option value="gemini">Google Gemini</Option>
            <Option value="qwen">通义千问</Option>
            <Option value="deepseek">DeepSeek</Option>
            <Option value="custom">自定义</Option>
          </Select>
        </FormItem>

        <FormItem label="AI模型名称" prop="model">
          <Input v-model="aiForm.model" placeholder="例如: gpt-3.5-turbo" style="width: 300px" />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>根据选择的AI服务提供商填写对应的模型名称</span>
          </div>
        </FormItem>

        <FormItem label="API密钥" prop="api_key">
          <Input
            v-model="aiForm.api_key"
            type="password"
            placeholder="请输入AI API密钥"
            style="width: 400px"
            show-password
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>API密钥将安全存储，不会在界面上显示</span>
          </div>
        </FormItem>

        <FormItem label="API基础URL" prop="base_url">
          <Input
            v-model="aiForm.base_url"
            placeholder="https://api.openai.com/v1"
            style="width: 400px"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>自定义API服务时填写完整的基础URL</span>
          </div>
        </FormItem>

        <FormItem label="最大Token数" prop="max_tokens">
          <InputNumber
            v-model="aiForm.max_tokens"
            :min="100"
            :max="4000"
            placeholder="1000"
            style="width: 200px"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>控制AI响应的长度，建议1000-2000</span>
          </div>
        </FormItem>

        <FormItem label="温度参数" prop="temperature">
          <InputNumber
            v-model="aiForm.temperature"
            :min="0"
            :max="2"
            :step="0.1"
            placeholder="0.7"
            style="width: 200px"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>控制AI回答的随机性，0-1之间，0.7为推荐值</span>
          </div>
        </FormItem>

        <FormItem label="提示词模板" prop="prompt_template">
          <Input
            v-model="aiForm.prompt_template"
            type="textarea"
            :rows="4"
            placeholder="请输入提示词模板"
            style="width: 100%"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>使用{keywords}作为关键词占位符，AI将生成JSON格式的标签数据</span>
          </div>
        </FormItem>

        <FormItem label="启用AI功能" prop="enabled">
          <Switch v-model="aiForm.enabled" />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>控制是否启用AI标签生成功能</span>
          </div>
        </FormItem>

        <FormItem label="请求超时时间" prop="timeout">
          <InputNumber
            v-model="aiForm.timeout"
            :min="5"
            :max="120"
            placeholder="30"
            style="width: 200px"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>AI请求的超时时间，单位：秒</span>
          </div>
        </FormItem>

        <FormItem label="重试次数" prop="retry_count">
          <InputNumber
            v-model="aiForm.retry_count"
            :min="1"
            :max="5"
            placeholder="3"
            style="width: 200px"
          />
          <div class="form-help">
            <Icon type="ios-information-circle" />
            <span>AI请求失败时的重试次数</span>
          </div>
        </FormItem>
      </Form>

      <template #extra>
        <Button type="primary" @click="saveSettings" :loading="saving">
          <Icon type="ios-save" />
          保存设置
        </Button>
        <Button @click="testConnection" :loading="testing">
          <Icon type="ios-flash" />
          测试连接
        </Button>
        <Button @click="resetSettings">
          <Icon type="ios-refresh" />
          重置
        </Button>
      </template>
    </Card>

    <!-- 测试结果弹窗 -->
    <Modal v-model="showTestModal" title="AI连接测试结果" width="600">
      <div v-if="testResult">
        <Alert :type="testResult.success ? 'success' : 'error'" show-icon>
          <template #desc>
            <p><strong>状态:</strong> {{ testResult.success ? '连接成功' : '连接失败' }}</p>
            <p v-if="testResult.message"><strong>消息:</strong> {{ testResult.message }}</p>
            <p v-if="testResult.response"><strong>响应:</strong> {{ testResult.response }}</p>
          </template>
        </Alert>
      </div>
      <template #footer>
        <Button @click="showTestModal = false">关闭</Button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { systemSettingApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { onMounted, ref } from 'vue';

// 响应式数据
const aiForm = ref({
  provider: 'openai',
  model: 'gpt-3.5-turbo',
  api_key: '',
  base_url: 'https://api.openai.com/v1',
  max_tokens: 1000,
  temperature: 0.7,
  prompt_template:
    '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]',
  enabled: true,
  timeout: 30,
  retry_count: 3,
});

const saving = ref(false);
const testing = ref(false);
const showTestModal = ref(false);
const testResult = ref(null);

// 表单验证规则
const aiRules = {
  provider: [{ required: true, message: '请选择AI服务提供商', trigger: 'change' }],
  model: [{ required: true, message: '请输入AI模型名称', trigger: 'blur' }],
  api_key: [{ required: true, message: '请输入API密钥', trigger: 'blur' }],
  base_url: [{ required: true, message: '请输入API基础URL', trigger: 'blur' }],
  max_tokens: [{ required: true, message: '请输入最大Token数', trigger: 'blur' }],
  temperature: [{ required: true, message: '请输入温度参数', trigger: 'blur' }],
  prompt_template: [{ required: true, message: '请输入提示词模板', trigger: 'blur' }],
  timeout: [{ required: true, message: '请输入请求超时时间', trigger: 'blur' }],
  retry_count: [{ required: true, message: '请输入重试次数', trigger: 'blur' }],
};

// AI服务提供商变化处理
const onProviderChange = provider => {
  const providerConfigs = {
    openai: {
      base_url: 'https://api.openai.com/v1',
      model: 'gpt-3.5-turbo',
    },
    claude: {
      base_url: 'https://api.anthropic.com/v1',
      model: 'claude-3-sonnet-20240229',
    },
    gemini: {
      base_url: 'https://generativelanguage.googleapis.com/v1beta',
      model: 'gemini-pro',
    },
    qwen: {
      base_url: 'https://dashscope.aliyuncs.com/api/v1',
      model: 'qwen-turbo',
    },
    deepseek: {
      base_url: 'https://api.deepseek.com/v1',
      model: 'deepseek-chat',
    },
    custom: {
      base_url: '',
      model: '',
    },
  };

  const config = providerConfigs[provider];
  if (config) {
    aiForm.value.base_url = config.base_url;
    aiForm.value.model = config.model;
  }
};

// 加载AI设置
const loadAISettings = async () => {
  try {
    const aiConfig = await systemSettingApi.getAIConfig();

    // 填充表单数据
    aiForm.value = {
      provider: aiConfig.provider || 'openai',
      model: aiConfig.model || 'gpt-3.5-turbo',
      api_key: aiConfig.api_key || '',
      base_url: aiConfig.base_url || 'https://api.openai.com/v1',
      max_tokens: aiConfig.max_tokens || 1000,
      temperature: aiConfig.temperature || 0.7,
      prompt_template:
        aiConfig.prompt_template ||
        '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]',
      enabled: aiConfig.enabled !== false,
      timeout: aiConfig.timeout || 30,
      retry_count: aiConfig.retry_count || 3,
    };
  } catch (error) {
    console.error('加载AI设置失败:', error);
    Message.error('加载AI设置失败');
  }
};

// 保存设置
const saveSettings = async () => {
  try {
    saving.value = true;

    await systemSettingApi.updateAIConfig(aiForm.value);

    Message.success('AI设置保存成功');
  } catch (error) {
    console.error('保存AI设置失败:', error);
    Message.error('保存AI设置失败');
  } finally {
    saving.value = false;
  }
};

// 测试连接
const testConnection = async () => {
  try {
    testing.value = true;

    const response = await systemSettingApi.testAIConnection(aiForm.value);

    testResult.value = response;
    showTestModal.value = true;
  } catch (error) {
    console.error('测试AI连接失败:', error);
    testResult.value = {
      success: false,
      message: error.message || '连接测试失败',
    };
    showTestModal.value = true;
  } finally {
    testing.value = false;
  }
};

// 重置设置
const resetSettings = () => {
  aiForm.value = {
    provider: 'openai',
    model: 'gpt-3.5-turbo',
    api_key: '',
    base_url: 'https://api.openai.com/v1',
    max_tokens: 1000,
    temperature: 0.7,
    prompt_template:
      '请生成20个与"{keywords}"相关的热门技术标签，以JSON格式返回，格式为：[{"name": "标签名", "category": "分类", "count": 数量}]',
    enabled: true,
    timeout: 30,
    retry_count: 3,
  };
  Message.info('设置已重置');
};

// 组件挂载时加载设置
onMounted(() => {
  loadAISettings();
});
</script>

<style scoped>
.ai-settings {
  padding: 20px;
}

.form-help {
  display: flex;
  align-items: flex-start;
  gap: 4px;
  margin-top: 4px;
  font-size: 12px;
  color: #666;
}

.form-help .ivu-icon {
  margin-top: 2px;
}

.ivu-card-extra {
  display: flex;
  gap: 8px;
}
</style>
