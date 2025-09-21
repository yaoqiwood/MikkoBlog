<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const users = ref([])
const error = ref('')

async function fetchUsers() {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }
  try {
    const { data } = await axios.get('http://localhost:8000/api/admin/users', {
      headers: { Authorization: `Bearer ${token}` }
    })
    users.value = data
  } catch (e) {
    error.value = '需要管理员权限，请重新登录'
    router.push('/login')
  }
}

onMounted(fetchUsers)
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <div class="max-w-4xl mx-auto py-10 px-4">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold">用户管理</h1>
        <router-link to="/" class="text-blue-600">返回首頁</router-link>
      </div>
      <div v-if="error" class="text-red-600 mb-4">{{ error }}</div>
      <table class="w-full bg-white rounded shadow">
        <thead>
          <tr class="text-left">
            <th class="p-3">ID</th>
            <th class="p-3">邮箱</th>
            <th class="p-3">姓名</th>
            <th class="p-3">管理员</th>
            <th class="p-3">状态</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in users" :key="u.id" class="border-t">
            <td class="p-3">{{ u.id }}</td>
            <td class="p-3">{{ u.email }}</td>
            <td class="p-3">{{ u.full_name }}</td>
            <td class="p-3">{{ u.is_admin ? 'Yes' : 'No' }}</td>
            <td class="p-3">{{ u.is_active ? 'Active' : 'Disabled' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>


