<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'

const route = useRoute()
const API_BASE = 'http://localhost:4000/api'

const startDateTime = ref(null)
const clockin = ref(false)

const loading = ref(false)
const message = ref('')
const isError = ref(false)
const elapsedTime = ref('00:00:00')
let timeInterval = null

function formatDateTime(date)
{
  const pad = (n) => String(n).padStart(2, '0')
  const year = date.getFullYear()
  const month = pad(date.getMonth() + 1)
  const day = pad(date.getDate())
  const hours = pad(date.getHours())
  const minutes = pad(date.getMinutes())
  const seconds = pad(date.getSeconds())
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

function showNotification(msg, error = false)
{
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 4000)
}

function updateTimer()
{
  if (!startDateTime.value || !clockin.value)
  {
    elapsedTime.value = '00:00:00'
    return
  }

  const formattedIso = String(startDateTime.value).includes('T')
    ? startDateTime.value
    : startDateTime.value.replace(' ', 'T')

  const start = new Date(formattedIso).getTime()
  const now = Date.now()

  if (isNaN(start))
  {
    elapsedTime.value = '00:00:00'
    return
  }

  const diffInSeconds = Math.max(0, Math.floor((now - start) / 1000))

  const hrs = String(Math.floor(diffInSeconds / 3600)).padStart(2, '0')
  const mins = String(Math.floor((diffInSeconds % 3600) / 60)).padStart(2, '0')
  const secs = String(diffInSeconds % 60).padStart(2, '0')

  elapsedTime.value = `${hrs}:${mins}:${secs}`
}

function startLiveCounter()
{
  stopLiveCounter()
  updateTimer()
  timeInterval = setInterval(updateTimer, 1000)
}

function stopLiveCounter()
{
  if (timeInterval)
  {
    clearInterval(timeInterval)
    timeInterval = null
  }
}

function getActiveUserId()
{
  const fromRoute = route.params.userID

  if (fromRoute)
    return fromRoute

  const savedUser = sessionStorage.getItem('activeUser')
  if (savedUser)
  {
    try {
      const parsed = JSON.parse(savedUser)
      return parsed.id
    } catch (err)
    {
      return null
    }
  }
  return null
}

async function refresh()
{
  const userID = getActiveUserId()
  
  if (!userID)
    return

  loading.value = true
  try
  {
    const response = await axios.get(`${API_BASE}/clocks/${userID}`)
    const clockData = response.data.data

    if (clockData && clockData.status)
    {
      clockin.value = true
      startDateTime.value = String(clockData.time).replace('T', ' ')
      startLiveCounter()
    }
    else
    {
      clockin.value = false
      startDateTime.value = null
      stopLiveCounter()
      elapsedTime.value = '00:00:00'
    }
  } catch (err)
  {
    console.error('Error at refresh:', err)
  } finally 
  {
    loading.value = false
  }
}

async function clock()
{
  const userID = getActiveUserId()
  if (!userID)
  {
    showNotification('Error: There is no user with this ID', true)
    return
  }

  loading.value = true

  try
  {
    const nowFormatted = formatDateTime(new Date())
    const nextStatus = !clockin.value

    const payload = {
      clock: {
        time: nowFormatted,
        status: nextStatus
      }
    }

    const response = await axios.post(`${API_BASE}/clocks/${userID}`, payload)
    const result = response.data.data

    clockin.value = Boolean(result.status)
    startDateTime.value = clockin.value ? String(result.time).replace('T', ' ') : null

    if (clockin.value)
    {
      startLiveCounter()
      showNotification(`Session started at: ${startDateTime.value}`)
    }
    else
    {
      stopLiveCounter()
      elapsedTime.value = '00:00:00'
      showNotification(`Session ended at: ${String(result.time).replace('T', ' ')}`)
    }
  } catch (err)
  {
    showNotification('Error when trying to change the clock status!', true)
    console.error("Error at clockOut:", err.response || err)
  } finally {
    loading.value = false
  }
}

watch(
  () => route.params.userID,
  (newId) => {
    if (newId)
      refresh()
  }
)

onMounted(() => {
  refresh()
})

onUnmounted(() => {
  stopLiveCounter()
})

</script>

<template>
  <div class="clock-card">
    <div class="card-header">
      <div class="header-info">
        <h3>Clock Manager</h3>
        <span class="user-tag">User ID: #{{ getActiveUserId() || 'Not set' }}</span>
      </div>
      <button class="btn-refresh" @click="refresh" :disabled="loading" title="Refresh">
        Refresh
      </button>
    </div>

    <div v-if="message" :class="['alert', isError ? 'alert-danger' : 'alert-success']">
      {{ message }}
    </div>

    <div class="status-panel">
      <div class="indicator-row">
        <span class="pulse-dot" :class="{ 'pulse-active': clockin }"></span>
        <span class="status-text">
          Status: <strong>{{ clockin ? 'ACTIVE SESSION' : 'INACTIVE' }}</strong>
        </span>
      </div>

      <div class="time-display">
        <span class="timer-label">Elapsed Time</span>
        <span class="timer-digits">{{ elapsedTime }}</span>
      </div>

      <div class="info-row">
        <div class="info-block">
          <span class="label">Started at:</span>
          <span class="value">{{ startDateTime || '—' }}</span>
        </div>
        <div class="info-block">
          <span class="label">Session status:</span>
          <span class="value">{{ clockin ? 'true' : 'false' }}</span>
        </div>
      </div>
    </div>

    <div class="action-panel">
      <button
        class="clock-btn"
        :class="clockin ? 'clock-out' : 'clock-in'"
        @click="clock"
        :disabled="loading"
      >
        <span v-if="loading">Loading...</span>
        <span v-else>
          {{ clockin ? 'Clock Out' : 'Clock In' }}
        </span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.clock-card {
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #334155;
}

.header-info h3 {
  font-size: 1.25rem;
  color: #f8fafc;
  font-weight: 600;
  margin: 0;
}

.user-tag {
  display: inline-block;
  margin-top: 0.3rem;
  font-size: 0.85rem;
  color: #94a3b8;
}

.btn-refresh {
  background: #334155;
  border: 1px solid #475569;
  color: #f8fafc;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-refresh:hover:not(:disabled) {
  background: #475569;
}

.status-panel {
  background: #0f172a;
  border: 1px solid #334155;
  border-radius: 12px;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.indicator-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.pulse-dot {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #64748b;
}

.pulse-active {
  background: #22c55e;
  box-shadow: 0 0 12px #22c55e;
  animation: pulse-animation 2s infinite;
}

@keyframes pulse-animation {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7); }
  70% { transform: scale(1.1); box-shadow: 0 0 0 8px rgba(34, 197, 94, 0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34, 197, 94, 0); }
}

.status-text {
  font-size: 1rem;
  color: #cbd5e1;
}

.time-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.timer-label {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #64748b;
  font-weight: 600;
}

.timer-digits {
  font-family: 'Courier New', Courier, monospace;
  font-size: 3rem;
  font-weight: 700;
  color: #38bdf8;
  letter-spacing: 2px;
}

.info-row {
  display: flex;
  width: 100%;
  justify-content: space-around;
  border-top: 1px solid #1e293b;
  padding-top: 1.25rem;
}

.info-block {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  text-align: center;
}

.info-block .label {
  font-size: 0.78rem;
  color: #94a3b8;
}

.info-block .value {
  font-size: 0.95rem;
  color: #f8fafc;
  font-weight: 600;
}

.action-panel {
  margin-top: 1.75rem;
  display: flex;
  justify-content: center;
}

.clock-btn {
  width: 100%;
  max-width: 400px;
  padding: 1rem 2rem;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.clock-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.clock-in {
  background: linear-gradient(135deg, #16a34a, #22c55e);
  color: white;
  box-shadow: 0 4px 15px rgba(34, 197, 94, 0.35);
}

.clock-in:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(34, 197, 94, 0.45);
}

.clock-out {
  background: linear-gradient(135deg, #dc2626, #ef4444);
  color: white;
  box-shadow: 0 4px 15px rgba(239, 68, 68, 0.35);
}

.clock-out:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(239, 68, 68, 0.45);
}

.alert {
  padding: 0.8rem 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
  text-align: center;
}

.alert-success {
  background: rgba(34, 197, 94, 0.12);
  border: 1px solid rgba(74, 222, 128, 0.3);
  color: #4ade80;
}

.alert-danger {
  background: rgba(239, 68, 68, 0.12);
  border: 1px solid rgba(248, 113, 113, 0.3);
  color: #f87171;
}
</style>