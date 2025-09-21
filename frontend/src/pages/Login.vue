<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('admin@example.com')
const password = ref('admin123')
const error = ref('')
const loading = ref(false)

async function login() {
  try {
    loading.value = true
    error.value = ''
    const body = new URLSearchParams()
    body.append('username', email.value)
    body.append('password', password.value)
    body.append('grant_type', '')
    const { data } = await axios.post('http://localhost:8000/api/auth/token', body, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    })
    localStorage.setItem('token', data.access_token)
    router.push('/admin/users')
  } catch (e) {
    error.value = '登录失败，请检查邮箱和密码'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50 flex items-center justify-center p-4">
    <div class="w-full max-w-6xl">
      <div class="bg-white rounded-3xl shadow-2xl border border-gray-100 overflow-hidden">
        <div class="flex min-h-[600px]">
          <!-- Left Side - Brand/Icon Section -->
          <div class="flex-1 bg-gradient-to-br from-blue-600 to-indigo-700 flex items-center justify-center p-12">
            <div class="text-center text-white">
              <!-- Main Icon -->
              <div class="inline-flex items-center justify-center w-24 h-24 bg-white/20 backdrop-blur-sm rounded-3xl mb-8">
                <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                </svg>
              </div>
              
              <!-- Brand Text -->
              <h1 class="text-4xl font-bold mb-4">MikkoBlog</h1>
              <p class="text-xl text-blue-100 mb-8">管理员登录</p>
              
              <!-- Decorative Elements -->
              <div class="space-y-4">
                <div class="flex items-center justify-center space-x-2">
                  <div class="w-2 h-2 bg-white/60 rounded-full"></div>
                  <div class="w-2 h-2 bg-white rounded-full"></div>
                  <div class="w-2 h-2 bg-white/60 rounded-full"></div>
                </div>
                <p class="text-blue-200 text-sm">安全 · 高效 · 专业</p>
              </div>
            </div>
          </div>

          <!-- Right Side - Login Form -->
          <div class="flex-1 flex items-center justify-center p-12">
            <div class="w-full max-w-md">
              <div class="text-center mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">欢迎回来</h2>
                <p class="text-gray-600">请登录您的管理员账户</p>
              </div>

              <form @submit.prevent="login" class="space-y-6">
                <!-- Email Field -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">邮箱地址</label>
                  <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                      </svg>
                    </div>
                    <input 
                      v-model="email" 
                      type="email"
                      class="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-gray-50 focus:bg-white" 
                      placeholder="admin@example.com"
                      required
                    />
                  </div>
                </div>

                <!-- Password Field -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">密码</label>
                  <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                      </svg>
                    </div>
                    <input 
                      v-model="password" 
                      type="password"
                      class="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-gray-50 focus:bg-white" 
                      placeholder="••••••••"
                      required
                    />
                  </div>
                </div>

                <!-- Error Message -->
                <div v-if="error" class="bg-red-50 border border-red-200 rounded-xl p-4">
                  <div class="flex">
                    <div class="flex-shrink-0">
                      <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                    </div>
                    <div class="ml-3">
                      <p class="text-sm text-red-800">{{ error }}</p>
                    </div>
                  </div>
                </div>

                <!-- Login Button -->
                <button 
                  :disabled="loading" 
                  class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 text-white py-3 px-4 rounded-xl font-medium hover:from-blue-700 hover:to-indigo-700 focus:ring-4 focus:ring-blue-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 transform hover:scale-[1.02] active:scale-[0.98]"
                >
                  <span v-if="!loading" class="flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
                    </svg>
                    登录
                  </span>
                  <span v-else class="flex items-center justify-center">
                    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    登录中...
                  </span>
                </button>
              </form>

              <!-- Footer -->
              <div class="mt-8 text-center">
                <router-link to="/" class="text-sm text-gray-500 hover:text-blue-600 transition-colors duration-200">
                  ← 返回首页
                </router-link>
              </div>

              <!-- Additional Info -->
              <div class="mt-6 text-center">
                <p class="text-xs text-gray-500">
                  默认管理员账号：admin@example.com / admin123
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
