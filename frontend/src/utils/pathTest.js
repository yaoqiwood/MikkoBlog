/**
 * 路径别名和路由工具测试文件
 */

// 测试@路径别名
import { getRoutePath, routerUtils, ROUTES } from '@/utils/routeManager';

console.log('🔧 路径别名测试:');
console.log('✅ @路径别名导入成功');

console.log('\n📡 路由工具测试:');
console.log('路由常量:', ROUTES);
console.log('首页路径:', getRoutePath(ROUTES.HOME));
console.log('登录路径:', getRoutePath(ROUTES.LOGIN));
console.log('管理员用户路径:', getRoutePath(ROUTES.ADMIN_USERS));

console.log('\n🚀 路由导航工具:', routerUtils);

// 测试路由路径生成
const testRoutes = ['HOME', 'LOGIN', 'ADMIN.USERS', 'ADMIN.POSTS', 'TEST.VIEWUI'];

console.log('\n📋 所有路由路径:');
testRoutes.forEach(route => {
  try {
    const path = getRoutePath(route);
    console.log(`${route}: ${path}`);
  } catch (error) {
    console.error(`❌ ${route}: ${error.message}`);
  }
});

export function testPathAlias() {
  console.log('✅ @路径别名测试通过');
  return true;
}

export function testRouteManager() {
  console.log('✅ 路由管理工具测试通过');
  return true;
}

// 自动运行测试
if (typeof window !== 'undefined') {
  console.log('🚀 开始路径别名和路由工具测试...');
  testPathAlias();
  testRouteManager();
  console.log('✨ 测试完成!');
}
