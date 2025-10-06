<template>
  <div class="ai-settings">
    <Form ref="formRef" :model="aiForm" :rules="aiRules" :label-width="120">
      <FormItem label="AI服务提供商" prop="provider">
        <Select
          v-model="aiForm.provider"
          placeholder="选择AI服务提供商"
          style="width: 300px"
          @on-change="onProviderChange"
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
        <Input v-model="aiForm.model" :placeholder="modelPlaceholder" style="width: 300px" />
        <div class="form-help">
          <Icon type="ios-information-circle" />
          <span>{{ modelHelpText }}</span>
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

    <div class="button-group">
      <Button @click="testConnection" :loading="testing">
        <Icon type="ios-flash" />
        测试连接
      </Button>
      <Button @click="resetSettings">
        <Icon type="ios-refresh" />
        重置
      </Button>
    </div>

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
import { computed, onMounted, ref, watch } from 'vue';

// 响应式数据
const aiForm = ref({
  provider: 'openai',
  model: 'gpt-3.5-turbo',
  api_key: '',
  base_url: 'https://api.openai.com/v1',
  max_tokens: 1000,
  temperature: 0.7,
  enabled: true,
  timeout: 30,
  retry_count: 3,
});

const testing = ref(false);
const showTestModal = ref(false);
const testResult = ref(null);
const formRef = ref(null);

// 表单验证规则
const aiRules = {
  provider: [{ required: true, message: '请选择AI服务提供商', trigger: 'change' }],
  model: [{ required: true, message: '请输入AI模型名称', trigger: 'blur' }],
  api_key: [{ required: true, message: '请输入API密钥', trigger: 'blur' }],
  base_url: [{ required: true, message: '请输入API基础URL', trigger: 'blur' }],
  max_tokens: [{ required: true, message: '请输入最大Token数', trigger: 'blur' }],
  temperature: [{ required: true, message: '请输入温度参数', trigger: 'blur' }],
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

// 监听provider变化
watch(
  () => aiForm.value.provider,
  newProvider => {
    onProviderChange(newProvider);
  }
);

// 获取模型名称placeholder - 使用计算属性
const modelPlaceholder = computed(() => {
  const placeholders = {
    openai: '例如: gpt-3.5-turbo, gpt-4',
    claude: '例如: claude-3-sonnet-20240229, claude-3-haiku-20240307',
    gemini: '例如: gemini-pro, gemini-pro-vision',
    qwen: '例如: qwen-turbo, qwen-plus, qwen-max',
    deepseek: '例如: deepseek-chat, deepseek-coder',
    custom: '请输入自定义模型名称',
  };
  return placeholders[aiForm.value.provider] || '请输入模型名称';
});

// 获取模型名称帮助文本 - 使用计算属性
const modelHelpText = computed(() => {
  const helpTexts = {
    openai: 'OpenAI模型: gpt-3.5-turbo(便宜), gpt-4(更强)',
    claude: 'Claude模型: claude-3-sonnet(平衡), claude-3-haiku(快速)',
    gemini: 'Gemini模型: gemini-pro(文本), gemini-pro-vision(多模态)',
    qwen: '通义千问模型: qwen-turbo(快速), qwen-plus(平衡), qwen-max(最强)',
    deepseek: 'DeepSeek模型: deepseek-chat(对话), deepseek-coder(编程)',
    custom: '根据您的自定义API服务填写对应的模型名称',
  };
  return helpTexts[aiForm.value.provider] || '根据选择的AI服务提供商填写对应的模型名称';
});

// 加载AI设置
const loadAISettings = async () => {
  try {
    console.log('开始加载AI设置...');
    const aiConfig = await systemSettingApi.getAIConfig();
    console.log('Loaded AI config:', aiConfig);

    // 填充表单数据 - 使用Object.assign一次性更新
    Object.assign(aiForm.value, {
      provider: aiConfig.provider || 'openai',
      model: aiConfig.model || 'gpt-3.5-turbo',
      api_key: aiConfig.api_key || '',
      base_url: aiConfig.base_url || 'https://api.openai.com/v1',
      max_tokens: aiConfig.max_tokens || 1000,
      temperature: aiConfig.temperature || 0.7,
      enabled: aiConfig.enabled !== false,
      timeout: aiConfig.timeout || 30,
      retry_count: aiConfig.retry_count || 3,
    });
    console.log('Updated aiForm after load:', aiForm.value);
    console.log('AI设置加载成功');
  } catch (error) {
    console.error('加载AI设置失败:', error);
    console.error('Error details:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      stack: error.stack,
    });
    Message.error(`加载AI设置失败: ${error.message}`);
  }
};

// 保存AI设置
const saveSettings = async () => {
  try {
    await systemSettingApi.updateAIConfig(aiForm.value);
    // 不显示成功消息，由父组件统一处理
  } catch (error) {
    console.error('保存AI设置失败:', error);
    Message.error('保存AI设置失败');
    throw error; // 重新抛出错误，让父组件知道保存失败
  }
};

// 测试连接
const testConnection = async () => {
  try {
    testing.value = true;

    // 为AI测试连接设置更长的超时时间
    const response = await systemSettingApi.testAIConnection(aiForm.value, {
      timeout: 60000, // 60秒超时
    });

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
  aiForm.value.provider = 'openai';
  aiForm.value.model = 'gpt-3.5-turbo';
  aiForm.value.api_key = '';
  aiForm.value.base_url = 'https://api.openai.com/v1';
  aiForm.value.max_tokens = 1000;
  aiForm.value.temperature = 0.7;
  aiForm.value.enabled = true;
  aiForm.value.timeout = 30;
  aiForm.value.retry_count = 3;
  Message.info('设置已重置');
};

// 组件挂载时加载设置
onMounted(() => {
  loadAISettings();
});

// 暴露方法给父组件
defineExpose({
  saveSettings,
});
</script>

<style scoped>
.ai-settings {
  padding: 20px;
}

.button-group {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #e8eaec;
}

.form-help {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 4px;
  font-size: 12px;
  color: #666;
  line-height: 1.4;
}

.form-help .ivu-icon {
  flex-shrink: 0;
  font-size: 14px;
}

.ivu-card-extra {
  display: flex;
  gap: 8px;
}
</style>
