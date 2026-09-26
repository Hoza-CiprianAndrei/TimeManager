<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { activeUserId } from '../activeSession.js'

const route = useRoute()
const router = useRouter()
const API_BASE = 'http://localhost:4000/api'

const userId = activeUserId
const workingTimeId = ref(route.params.workingtimeid || route.params.workingTimeId)

const form = ref({
  start: '',
  end: ''
})

const isEditing = ref(!!workingTimeId.value)
const message = ref('')

function formatForInput(dateStr) {
  if (!dateStr) return ''
  return dateStr.replace(' ', 'T')
}

function formatForAPI(dateStr) {
  if (!dateStr) return ''
  return dateStr.replace('T', ' ') + ':00'
}

async function getSingleWorkingTime() {
  if (!isEditing.value) return
  
  try {
    const response = await axios.get(`${API_BASE}/workingtime/${userId.value}/${workingTimeId.value}`)
    const data = response.data.data
    form.value.start = formatForInput(data.start)
    form.value.end = formatForInput(data.end)
  } catch (error) {
    message.value = 'Error loading data.'
  }
}

async function createWorkingTime() {
  if (!userId.value) {
    message.value = 'No user selected! Please select a user first.'
    return
  }

  try {
    const payload = {
      working_time: {
        start: formatForAPI(form.value.start),
        end: formatForAPI(form.value.end)
      }
    }
    await axios.post(`${API_BASE}/workingtime/${userId.value}`, payload)
    router.push(`/workingTimes/${userId.value}`)
  } catch (error) {
    message.value = 'Error creating working time.'
  }
}

async function updateWorkingTime() {
  try {
    const payload = {
      working_time: {
        start: formatForAPI(form.value.start),
        end: formatForAPI(form.value.end)
      }
    }
    await axios.put(`${API_BASE}/workingtime/${workingTimeId.value}`, payload)
    router.push(`/workingTimes/${userId.value}`)
  } catch (error) {
    message.value = 'Error updating working time.'
  }
}

async function deleteWorkingTime() {
  if (!confirm('Are you sure you want to delete this working time?')) return
  
  try {
    await axios.delete(`${API_BASE}/workingtime/${workingTimeId.value}`)
    router.push(`/workingTimes/${userId.value}`)
  } catch (error) {
    message.value = 'Error deleting working time.'
  }
}

function handleSubmit() {
  if (isEditing.value) {
    updateWorkingTime()
  } else {
    createWorkingTime()
  }
}

onMounted(() => {
  getSingleWorkingTime()
})
</script>

<template>
  <div class="form-container">
    <h2>{{ isEditing ? 'Edit Working Time' : 'Create New Working Time' }}</h2>
    <p v-if="message" class="error-message">{{ message }}</p>

    <form @submit.prevent="handleSubmit" class="wt-form">
      <div class="form-group">
        <label>Start Time:</label>
        <input v-model="form.start" type="datetime-local" required />
      </div>

      <div class="form-group">
        <label>End Time:</label>
        <input v-model="form.end" type="datetime-local" required />
      </div>

      <div class="actions">
        <button type="submit" class="btn btn-primary">
          {{ isEditing ? 'Save Changes' : 'Create' }}
        </button>
        <button v-if="isEditing" type="button" class="btn btn-danger" @click="deleteWorkingTime">
          Delete Working Time
        </button>
        <button type="button" class="btn btn-secondary" @click="router.push(`/workingTimes/${userId}`)">
          Cancel
        </button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.form-container {
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 2rem;
  max-width: 600px;
  margin: 0 auto;
}

h2 { color: #f8fafc; margin-bottom: 1.5rem; }
.error-message { color: #f87171; margin-bottom: 1rem; }

.wt-form { display: flex; flex-direction: column; gap: 1.25rem; }
.form-group { display: flex; flex-direction: column; gap: 0.5rem; }

label { color: #94a3b8; font-size: 0.9rem; }
input {
  background: #0f172a;
  border: 1px solid #334155;
  color: #f8fafc;
  padding: 0.75rem;
  border-radius: 6px;
  color-scheme: dark;
}

.actions { display: flex; gap: 1rem; margin-top: 1rem; }
.btn { padding: 0.75rem 1.5rem; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; flex: 1; }
.btn-primary { background: #0284c7; color: white; }
.btn-danger { background: #dc2626; color: white; }
.btn-secondary { background: #475569; color: white; }
</style>