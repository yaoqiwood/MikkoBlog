<template>
  <div class="image-search-settings">
    <div class="settings-header">
      <h3>图片搜索配置</h3>
      <p class="description">配置随机图片生成功能的搜索参数</p>
    </div>

    <div class="settings-content">
      <Form :model="formData" :label-width="150" label-position="left">
        <!-- 默认搜索标签 -->
        <FormItem label="默认搜索标签">
          <Input
            v-model="formData.default_tags"
            type="textarea"
            :rows="3"
            placeholder="输入默认搜索标签，用逗号分隔，如：nature,landscape,abstract 或 风景，二次元，美女"
          />
          <div class="field-help">用于图片搜索的默认标签，多个标签用逗号分隔（支持中文逗号）</div>
        </FormItem>

        <!-- 默认方向 -->
        <FormItem label="默认方向">
          <Select v-model="formData.default_orientation" placeholder="选择默认图片方向">
            <Option value="landscape">横向</Option>
            <Option value="portrait">纵向</Option>
            <Option value="squarish">方形</Option>
          </Select>
          <div class="field-help">默认图片方向，影响搜索结果的图片比例</div>
        </FormItem>

        <!-- 专栏封面标签 -->
        <FormItem label="专栏封面标签">
          <Input
            v-model="formData.column_cover_tags"
            type="textarea"
            :rows="3"
            placeholder="专栏封面专用标签，如：minimal,modern,geometric 或 简约，现代，几何"
          />
          <div class="field-help">
            专门用于专栏封面生成的标签，通常偏向简洁、现代风格（支持中文逗号）
          </div>
        </FormItem>

        <!-- 搜索数量 -->
        <FormItem label="搜索数量">
          <InputNumber
            v-model="formData.search_count"
            :min="1"
            :max="50"
            placeholder="每次搜索返回的图片数量"
          />
          <div class="field-help">每次搜索返回的图片数量，建议10-20张</div>
        </FormItem>

        <!-- 启用Unsplash -->
        <FormItem label="启用Unsplash">
          <Switch v-model="formData.enable_unsplash" />
          <div class="field-help">是否启用Unsplash API进行图片搜索，关闭时使用Picsum作为备选</div>
        </FormItem>

        <!-- Unsplash API Key -->
        <FormItem v-if="formData.enable_unsplash" label="Unsplash API Key">
          <Input
            v-model="formData.unsplash_access_key"
            type="password"
            placeholder="输入Unsplash API访问密钥"
            show-password
          />
          <div class="field-help">Unsplash API访问密钥，用于获取高质量图片</div>
        </FormItem>

        <!-- 自动生成标签 -->
        <FormItem label="自动生成标签">
          <Switch v-model="formData.auto_generate_tags" />
          <div class="field-help">是否根据专栏名称自动生成搜索标签</div>
        </FormItem>

        <!-- 标签映射规则 -->
        <FormItem v-if="formData.auto_generate_tags" label="标签映射规则">
          <Input
            v-model="formData.tag_mapping_rules"
            type="textarea"
            :rows="4"
            placeholder="输入标签映射规则，格式：关键词:标签1,标签2 或 关键词：标签1，标签2"
          />
          <div class="field-help">
            根据关键词自动映射到对应标签，格式：关键词:标签1,标签2，每行一个规则（支持中文逗号）
          </div>
        </FormItem>

        <!-- 操作按钮 -->
        <FormItem>
          <Button @click="resetSettings"> 重置 </Button>
          <Button @click="testConnection" style="margin-left: 10px" :loading="testing">
            测试连接
          </Button>
        </FormItem>
      </Form>
    </div>

    <!-- 标签预览 -->
    <div class="tag-preview" v-if="previewTags.length > 0">
      <h4>标签预览</h4>
      <div class="tag-list">
        <Tag v-for="tag in previewTags" :key="tag" color="blue" size="small">
          {{ tag }}
        </Tag>
      </div>
    </div>
  </div>
</template>

<script>
import { systemApi } from '@/utils/apiService';
import { Message } from 'view-ui-plus';
import { computed, onMounted, reactive, ref } from 'vue';

export default {
  name: 'ImageSearchSettings',
  emits: ['refresh'],
  setup(props, { emit }) {
    const saving = ref(false);
    const testing = ref(false);

    const formData = reactive({
      default_tags: '',
      default_orientation: 'landscape',
      column_cover_tags: '',
      search_count: 10,
      enable_unsplash: true,
      unsplash_access_key: '',
      auto_generate_tags: true,
      tag_mapping_rules: '',
    });

    // 标签预览
    const previewTags = computed(() => {
      const tags = [];
      if (formData.default_tags) {
        tags.push(
          ...formData.default_tags
            .split(/[,，]/) // 支持英文逗号和中文逗号分割
            .map(tag => tag.trim())
            .filter(tag => tag)
        );
      }
      if (formData.column_cover_tags) {
        tags.push(
          ...formData.column_cover_tags
            .split(/[,，]/) // 支持英文逗号和中文逗号分割
            .map(tag => tag.trim())
            .filter(tag => tag)
        );
      }
      return [...new Set(tags)]; // 去重
    });

    // 加载配置
    const loadSettings = async () => {
      try {
        const settingsArray = await systemApi.getDefaults({ category: 'ImageSearch' });
        console.log('🔍 API响应（配置数组）:', settingsArray);

        if (settingsArray && Array.isArray(settingsArray)) {
          // 将数组转换为对象，以key_name为键
          const settings = {};
          settingsArray.forEach(setting => {
            settings[setting.key_name] = setting;
          });
          console.log('🔍 转换后的配置对象:', settings);

          // 填充表单数据
          Object.keys(formData).forEach(key => {
            if (settings[key]) {
              const setting = settings[key];
              let value = setting.key_value;
              console.log(`🔍 处理字段 ${key}:`, { original: value, type: setting.data_type });

              // 类型转换
              if (setting.data_type === 'boolean') {
                value = value === 'true' || value === '1';
              } else if (setting.data_type === 'number') {
                value = parseInt(value) || 0;
              }
              // string 类型不需要转换

              console.log(`🔍 转换后 ${key}:`, value);
              formData[key] = value;
            } else {
              console.log(`🔍 未找到字段 ${key} 的配置`);
            }
          });

          console.log('🔍 最终表单数据:', formData);
        } else {
          console.log('🔍 API响应失败或无数据:', settingsArray);
        }
      } catch (error) {
        console.error('加载图片搜索配置失败:', error);
        Message.error('加载配置失败');
      }
    };

    // 保存所有配置
    const saveSettings = async () => {
      saving.value = true;
      try {
        const updates = [];

        Object.keys(formData).forEach(key => {
          const value = formData[key];
          const dataType =
            typeof value === 'boolean'
              ? 'boolean'
              : typeof value === 'number'
                ? 'number'
                : 'string';

          updates.push(systemApi.updateDefaultByKey('ImageSearch', key, value, dataType));
        });

        await Promise.all(updates);
        // 不显示成功消息，由父组件统一处理
        emit('refresh');
      } catch (error) {
        console.error('保存配置失败:', error);
        Message.error('保存配置失败');
      } finally {
        saving.value = false;
      }
    };

    // 重置配置
    const resetSettings = async () => {
      try {
        await loadSettings();
        Message.success('配置已重置');
      } catch (error) {
        console.error('重置配置失败:', error);
        Message.error('重置配置失败');
      }
    };

    // 测试连接
    const testConnection = async () => {
      testing.value = true;
      try {
        // 这里可以调用图片搜索API进行测试
        const response = await window.fetch('getFullUrl("")/api/image-search/tags');
        if (response.ok) {
          Message.success('连接测试成功');
        } else {
          Message.error('连接测试失败');
        }
      } catch (error) {
        console.error('连接测试失败:', error);
        Message.error('连接测试失败');
      } finally {
        testing.value = false;
      }
    };

    onMounted(() => {
      loadSettings();
    });

    return {
      saving,
      testing,
      formData,
      previewTags,
      saveSettings,
      resetSettings,
      testConnection,
    };
  },
};
</script>

<style scoped>
.image-search-settings {
  padding: 0;
  background: transparent;
  border-radius: 0;
}

.settings-header {
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e8eaec;
}

.settings-header h3 {
  margin: 0 0 8px 0;
  color: #2c3e50;
  font-size: 18px;
  font-weight: 600;
}

.description {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.settings-content {
  margin-bottom: 24px;
}

.field-help {
  margin-top: 4px;
  font-size: 12px;
  color: #999;
  line-height: 1.4;
}

.tag-preview {
  padding: 16px;
  background: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e8eaec;
}

.tag-preview h4 {
  margin: 0 0 12px 0;
  color: #2c3e50;
  font-size: 14px;
  font-weight: 600;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tag-list .ivu-tag {
  margin: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .image-search-settings {
    padding: 16px;
  }

  .settings-header h3 {
    font-size: 16px;
  }
}
</style>
