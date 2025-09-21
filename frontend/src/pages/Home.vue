<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const api = axios.create({ baseURL: 'http://localhost:8000/api' })

const posts = ref([])
const title = ref('')
const content = ref('')
const summary = ref('')
const loading = ref(false)
const error = ref('')

async function fetchPosts() {
  const { data } = await api.get('/posts/')
  posts.value = data
}

async function createPost() {
  try {
    loading.value = true
    error.value = ''
    const payload = { title: title.value, content: content.value, summary: summary.value }
    await api.post('/posts/', payload)
    title.value = ''
    content.value = ''
    summary.value = ''
    await fetchPosts()
  } catch (e) {
    error.value = '创建失败'
  } finally {
    loading.value = false
  }
}

onMounted(fetchPosts)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-3xl mx-auto py-10 px-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold">MikkoBlog Posts</h1>
        <div class="space-x-3">
          <router-link to="/login" class="text-blue-600">登录</router-link>
          <router-link to="/admin/users" class="text-blue-600">用户管理</router-link>
        </div>
      </div>

      <form @submit.prevent="createPost" class="bg-white rounded shadow p-4 mb-8 space-y-3">
        <div>
          <label class="block text-sm font-medium mb-1">标题</label>
          <input v-model="title" class="w-full border rounded px-3 py-2" placeholder="文章标题" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">摘要</label>
          <input v-model="summary" class="w-full border rounded px-3 py-2" placeholder="简要摘要" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">内容</label>
          <textarea v-model="content" rows="4" class="w-full border rounded px-3 py-2" placeholder="Markdown 内容或纯文本"></textarea>
        </div>
        <div class="flex items-center gap-3">
          <button :disabled="loading" class="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50">提交</button>
          <span v-if="error" class="text-red-600 text-sm">{{ error }}</span>
        </div>
      </form>

      <div class="space-y-4">
        <div v-for="p in posts" :key="p.id" class="bg-white rounded shadow p-4">
          <h2 class="text-xl font-semibold">{{ p.title }}</h2>
          <p class="text-gray-600">{{ p.summary }}</p>
          <p class="mt-2 whitespace-pre-wrap">{{ p.content }}</p>
        </div>
      </div>
    </div>
  </div>
</template>


