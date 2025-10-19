import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';
import { defineConfig } from 'vite';

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const isProduction = mode === 'production';

  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': resolve(__dirname, 'src'),
        '@components': resolve(__dirname, 'src/components'),
        '@pages': resolve(__dirname, 'src/pages'),
        '@utils': resolve(__dirname, 'src/utils'),
        '@assets': resolve(__dirname, 'src/assets'),
        '@router': resolve(__dirname, 'src/router'),
        '@styles': resolve(__dirname, 'src/styles'),
      },
    },
    server: {
      proxy: {
        '/api': {
          target: 'http://localhost:8000',
          changeOrigin: true,
        },
        '/uploads': {
          target: 'http://localhost:8000',
          changeOrigin: true,
        },
      },
    },
    build: {
      // 生产环境构建配置
      minify: 'terser',
      terserOptions: {
        compress: {
          // 移除 console.log
          drop_console: isProduction,
          // 移除 debugger
          drop_debugger: isProduction,
        },
        mangle: {
          // 混淆变量名
          toplevel: true,
        },
        format: {
          // 移除注释
          comments: !isProduction,
        },
      },
      // 启用代码分割
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['vue', 'vue-router'],
            ui: ['view-ui-plus'],
            editor: ['@toast-ui/editor'],
          },
        },
      },
      // 移除源码映射（生产环境）
      sourcemap: !isProduction,
      // 设置 chunk 大小警告限制
      chunkSizeWarningLimit: 1000,
    },
    // 定义环境变量
    define: {
      __VUE_PROD_DEVTOOLS__: false,
    },
  };
});
