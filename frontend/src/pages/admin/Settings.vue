<template>
  <div class="settings">
    <div class="page-header">
      <h1 class="page-title">系统设置</h1>
    </div>

    <div class="settings-grid">
      <Card title="基本设置">
        <Form label-position="top">
          <FormItem label="网站名称">
            <Input v-model="settings.siteName" placeholder="请输入网站名称" />
          </FormItem>
          <FormItem label="网站描述">
            <Input
              v-model="settings.siteDescription"
              type="textarea"
              placeholder="请输入网站描述"
            />
          </FormItem>
          <FormItem label="网站关键词">
            <Input v-model="settings.siteKeywords" placeholder="请输入网站关键词" />
          </FormItem>
        </Form>
      </Card>

      <Card title="用户设置">
        <Form label-position="top">
          <FormItem label="允许用户注册">
            <Switch v-model="settings.allowRegister" />
          </FormItem>
          <FormItem label="需要邮箱验证">
            <Switch v-model="settings.requireEmailVerification" />
          </FormItem>
          <FormItem label="默认用户权限">
            <Select v-model="settings.defaultUserRole">
              <Option value="user">普通用户</Option>
              <Option value="admin">管理员</Option>
            </Select>
          </FormItem>
        </Form>
      </Card>

      <Card title="安全设置">
        <Form label-position="top">
          <FormItem label="密码最小长度">
            <InputNumber v-model="settings.minPasswordLength" :min="6" :max="20" />
          </FormItem>
          <FormItem label="登录失败锁定">
            <Switch v-model="settings.lockOnFailedLogin" />
          </FormItem>
          <FormItem label="会话超时时间（分钟）">
            <InputNumber v-model="settings.sessionTimeout" :min="5" :max="1440" />
          </FormItem>
        </Form>
      </Card>

      <Card title="邮件设置">
        <Form label-position="top">
          <FormItem label="SMTP服务器">
            <Input v-model="settings.smtpHost" placeholder="请输入SMTP服务器地址" />
          </FormItem>
          <FormItem label="SMTP端口">
            <InputNumber v-model="settings.smtpPort" :min="1" :max="65535" />
          </FormItem>
          <FormItem label="发送邮箱">
            <Input v-model="settings.smtpEmail" placeholder="请输入发送邮箱" />
          </FormItem>
        </Form>
      </Card>
    </div>

    <!-- AI设置 -->
    <Card title="AI设置" style="margin-bottom: 1.5rem">
      <AISettings />
    </Card>

    <!-- 图片搜索配置 -->
    <Card title="图片搜索配置" style="margin-bottom: 1.5rem">
      <ImageSearchSettings ref="imageSearchRef" @refresh="loadDefaults" />
    </Card>

    <div class="settings-actions">
      <Button type="primary" size="large" @click="saveSettings">保存设置</Button>
      <Button type="default" size="large" @click="resetSettings">重置设置</Button>
      <Button type="success" size="large" @click="goToSystemDefaults" style="margin-left: 10px">
        设置系统默认变量
      </Button>
    </div>
  </div>
</template>

<script setup>
import { Message } from 'view-ui-plus';
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import ImageSearchSettings from './ImageSearchSettings.vue';
import AISettings from './AISettings.vue';

const router = useRouter();
const imageSearchRef = ref(null);

const settings = ref({
  siteName: 'MikkoBlog',
  siteDescription: '一个现代化的博客系统',
  siteKeywords: '博客,文章,管理',
  allowRegister: true,
  requireEmailVerification: false,
  defaultUserRole: 'user',
  minPasswordLength: 6,
  lockOnFailedLogin: true,
  sessionTimeout: 30,
  smtpHost: 'smtp.example.com',
  smtpPort: 587,
  smtpEmail: 'noreply@example.com',
});

async function saveSettings() {
  try {
    // 保存图片搜索配置
    if (imageSearchRef.value) {
      await imageSearchRef.value.saveSettings();
    }

    // 这里可以添加其他设置的保存逻辑
    // 例如：保存基本设置、用户设置等

    Message.success('所有设置保存成功');
  } catch (error) {
    console.error('保存设置失败:', error);
    Message.error('保存设置失败');
  }
}

function resetSettings() {
  Message.info('设置已重置');
}

function goToSystemDefaults() {
  router.push('/admin/system');
}

function loadDefaults() {
  // 这个方法用于ImageSearchSettings组件的@refresh事件
  // 如果需要的话可以在这里添加刷新逻辑
  console.log('Settings refreshed');
}
</script>

<style scoped>
.settings {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 1.5rem;
}

.page-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2d3748;
  margin: 0;
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.settings-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

@media (max-width: 768px) {
  .settings-grid {
    grid-template-columns: 1fr;
  }

  .settings-actions {
    flex-direction: column;
  }
}
</style>
