<script setup>
import { ref, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { activeUserId } from '../activeSession.js'

const route = useRoute()
const router = useRouter()
const API_BASE = 'http://localhost:4000/api'

const currentUserId = computed(() => {
  return activeUserId.value || route.params.userID || route.params.userId || route.params.userid
})

const workingTimes = ref([])
const loading = ref(false)

async function getWorkingTimes() {
  const id = currentUserId.value
  if (!id || id === 'undefined' || id === 'null') {
    workingTimes.value = []
    return
  }
  
  if (loading.value)
    return

  loading.value = true

  try {
    const response = await axios.get(`${API_BASE}/workingtime/${id}`)
    workingTimes.value = response.data.data || []
  } catch (error) {
    console.error('Error fetching working times:', error)
    workingTimes.value = []
  } finally {
    loading.value = false
  }
}

function editWorkingTime(workingTimeId) {
  router.push(`/workingTime/${currentUserId.value}/${workingTimeId}`)
}

watch(
  () => [activeUserId.value, route.params],
  () => {
    getWorkingTimes()
  },
  { immediate: true, deep: true}
)

function formatDisplayDate(dateString) {
  if (!dateString)
    return ''

  return dateString.replace('T', ' ')
}
</script>

<template>
  <div v-if="currentUserId && currentUserId !== 'undefined' && currentUserId !== 'null'" class="working-times-container">
    <div class="header">
      <h2>Working Times</h2>
      <button class="btn btn-primary" @click="router.push(`/workingTime/${currentUserId}`)">
        + Add New Working Time
      </button>
    </div>

    <div v-if="loading" class="loading">Loading data...</div>
    
    <table v-else class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Start Time</th>
          <th>End Time</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="wt in workingTimes" :key="wt.id">
          <td>#{{ wt.id }}</td>
          <td>{{ formatDisplayDate(wt.start) }}</td>
          <td>{{ formatDisplayDate(wt.end) }}</td>
          <td>
            <button class="btn btn-secondary btn-sm" @click="editWorkingTime(wt.id)">
              Edit
            </button>
          </td>
        </tr>
        <tr v-if="workingTimes.length === 0">
          <td colspan="4" class="empty-state">No records found for this user.</td>
        </tr>
      </tbody>
    </table>
  </div>
  <div v-else class="working-times-container empty-state">
    <h2>Working Times</h2>
    <p style="margin-top: 1rem;">Please select an active user from the User Management page to view their records.</p>
  </div>
</template>

<style scoped>
.working-times-container {
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4);
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

h2 { color: #f8fafc; font-size: 1.25rem; }

.data-table {
  width: 100%;
  border-collapse: collapse;
  color: #f8fafc;
}

.data-table th, .data-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #334155;
}

.data-table th { color: #94a3b8; font-weight: 600; text-transform: uppercase; font-size: 0.85rem; }
.data-table tr:hover { background: #0f172a; }

.btn { padding: 0.5rem 1rem; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; }
.btn-primary { background: #0284c7; color: white; }
.btn-secondary { background: #475569; color: white; }
.btn-sm { padding: 0.25rem 0.75rem; font-size: 0.85rem; }
.empty-state { text-align: center; color: #94a3b8; font-style: italic; }
</style>