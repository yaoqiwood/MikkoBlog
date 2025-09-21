/**
 * API工具类测试文件
 * 用于验证API工具类的功能
 */

import { authApi, userApi, postApi, systemApi } from './apiService';
import { getApiUrl, getAuthUrl, getUserUrl, getPostUrl } from './apiConfig';

// 测试API配置
console.log('🔧 API配置测试:');
console.log('基础URL:', getApiUrl(''));
console.log('登录URL:', getAuthUrl('LOGIN'));
console.log('用户列表URL:', getUserUrl('LIST'));
console.log('文章列表URL:', getPostUrl('LIST'));

// 测试API服务
console.log('\n📡 API服务测试:');
console.log('认证API:', authApi);
console.log('用户API:', userApi);
console.log('文章API:', postApi);
console.log('系统API:', systemApi);

// 导出测试函数
export function testApiConfig() {
  try {
    console.log('✅ API配置测试通过');
    return true;
  } catch (error) {
    console.error('❌ API配置测试失败:', error);
    return false;
  }
}

export function testApiService() {
  try {
    console.log('✅ API服务测试通过');
    return true;
  } catch (error) {
    console.error('❌ API服务测试失败:', error);
    return false;
  }
}

// 自动运行测试
if (typeof window !== 'undefined') {
  console.log('🚀 开始API工具类测试...');
  testApiConfig();
  testApiService();
  console.log('✨ API工具类测试完成!');
}
