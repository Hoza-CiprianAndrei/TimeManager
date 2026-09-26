<script setup>
import { ref, computed, onMounted, watch} from 'vue'
import { useRoute } from 'vue-router'
import axios from 'axios'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  ArcElement,
  Filler
} from 'chart.js'
import { Bar, Line, Doughnut} from 'vue-chartjs'
import { globalState } from '../state.js'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  ArcElement,
  Filler
)

const route = useRoute()
const API_BASE = 'http://localhost:4000/api'

const loading = ref(false)
const rawWorkingTimes = ref([])
const errorMessage = ref('')

function getActiveUserId() 
{
  return route.params.userID || globalState.currentUser?.id || null
}

async function fetchWorkingTimes() 
{
  const userID = getActiveUserId()
  
  if (!userID)
    return

  loading.value = true
  errorMessage.value = ''

  try
  {
    const response = await axios.get(`${API_BASE}/workingtimes/${userID}`)
    rawWorkingTimes.value = response.data?.data || []
  } catch (err)
  {
    console.error('Error when trying to fetch the worked hours:', err)
    errorMessage.value = 'Could not load the graphs data!'
  } finally
  {
    loading.value = false
  }
}

function getDurationInHours(startStr, endStr)
{
  if (!startStr || !endStr) 
    return 0
  const start = new Date(startStr.includes('T') ? startStr : startStr.replace(' ', 'T')).getTime()
  const end = new Date(endStr.includes('T') ? endStr : endStr.replace(' ', 'T')).getTime()
  const diffHours = (end - start) / (1000 * 60 * 60)
  return Math.max(0, parseFloat(diffHours.toFixed(2)))
}

const processedDays = computed(() => {
  const map = {}
  rawWorkingTimes.value.forEach((item) => {
    if (item.start || !item.end)
      return
    const dayKey = item.start.split('T')[0].split(' ')[0]
    const hours = getDurationInHours(item.start, item.end)
    map[dayKey] = (map[dayKey] || 0) + hours
  })

  const sortedDays = Object.keys(map).sort()
  return {
    labels: sortedDays.length ? sortedDays : ['No data'],
    values: sortedDays.length ? sortedDays.map((d) => parseFloat(map[d].toFixed(2))) : [0]
  }
})

const TARGET_HOURS = 40 //changeable

const totalHoursWorked = computed(() => {
  const total = rawWorkingTimes.value.reduce((acc, curr) => {
    return acc + getDurationInHours(curr.start, curr.end)
  }, 0)
  return parseFloat(total.toFixed(2)) 
})

const averageDailyHours = computed(() => {
  const daysCount = processedDays.value.labels.filter((l) => l !== 'No data').length
    if (!daysCount)
      return 0
    return parseFloat((totalHoursWorked.value / daysCount).toFixed(2))
  })

const barData = computed(() => ({
  labels: processedDays.value.labels,
  datasets: [
     {
      label: 'Hours worked',
      backgroundColor: '#38bdf8',
      borderRadius: 6,
      data: processedDays.value.values
    }
  ]
}))

const barOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { labels: { color: '#94a3b8' } }
  },
  scales: {
    x: { ticks: { color: '#94a3b8' }, grid: { color: '#334155' } },
    y: { ticks: { color: '#94a3b8' }, grid: { color: '#334155' }, beginAtZero: true }
  }
}

const lineData = computed(() => ({
  labels: processedDays.value.labels,
  datasets: [
    {
      label: 'Daily tendency (Hours)',
      borderColor: '#818cf8',
      backgroundColor: 'rgba(129, 140, 248, 0.15)',
      fill: true,
      tension: 0.35,
      pointBackgroundColor: '#818cf8',
      pointBorderColor: '#fff',
      pointRadius: 5,
      data: processedDays.value.values
    }
  ]
}))

const lineOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { labels: { color: '#94a3b8' } }
  },
  scales: {
    x: { ticks: { color: '#94a3b8' }, grid: { color: '#334155' } },
    y: { ticks: { color: '#94a3b8' }, grid: { color: '#334155' }, beginAtZero: true }
  }
}

const doughnutData = computed(() => {
  const completed = totalHoursWorked.value
  const remaining = Math.max(0, TARGET_HOURS - completed)

  return {
    labels: ['Completed', 'Left workload'],
    datasets: [
      {
        backgroundColor: ['#22c55e', '#334155'],
        borderColor: '#1e293b',
        borderWidth: 2,
        data: [completed, remaining]
      }
    ]
  }
})

const doughnutOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: { color: '#94a3b8' }
    }
  }
}

watch(
  () => route.params.userID,
  (newId) => {
    if (newId)
      fetchWorkingTimes()
  }
)

onMounted(() => {
  fetchWorkingTimes()
})
</script>

<template>
  <div class="charts-container">
    <div class="charts-header">
      <div>
        <h3>Graphs and Statistics</h3>
        <span class="user-tag">User ID: #{{ getActiveUserId() || 'Not set' }}</span>
      </div>
      <button class="btn-refresh" @click="fetchWorkingTimes" :disabled="loading">
        Update data
      </button>
    </div>

    <div v-if="errorMessage" class="alert alert-danger">
      {{ errorMessage }}
    </div>

    <div class="kpi-grid">
      <div class="kpi-card">
        <span class="kpi-label">Work Sessions</span>
        <span class="kpi-val">{{ rawWorkingTimes.length }}</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Total worked hours</span>
        <span class="kpi-val">{{ totalHoursWorked }} h</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Average daily hours</span>
        <span class="kpi-val">{{ averageDailyHours }} h</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Weekly workload</span>
        <span class="kpi-val">{{ TARGET_HOURS }} h</span>
      </div>
    </div>

    <div class="charts-layout">
      <div class="chart-card">
        <h4>1. Hours worked / days</h4>
        <div class="canvas-wrapper">
          <Bar v-if="!loading" :data="barData" :options="barOptions" />
          <div v-else class="loading-state">Loading...</div>
        </div>
      </div>

      <div class="chart-card">
        <h4>2. Evolution and Tendency</h4>
        <div class="canvas-wrapper">
          <Line v-if="!loading" :data="lineData" :options="lineOptions" />
          <div v-else class="loading-state">Loading...</div>
        </div>
      </div>

      <div class="chart-card full-width">
        <h4>3. Workload Progress</h4>
        <div class="canvas-wrapper doughnut-height">
          <Doughnut v-if="!loading" :data="doughnutData" :options="doughnutOptions" />
          <div v-else class="loading-state">Loading...</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.charts-container {
  max-width: 1100px;
  margin: 0 auto 3rem auto;
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4);
  box-sizing: border-box;
}

.charts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #334155;
}

.charts-header h3 {
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

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.kpi-card {
  background: #0f172a;
  border: 1px solid #334155;
  padding: 1.2rem;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.kpi-label {
  font-size: 0.75rem;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.8px;
}

.kpi-val {
  font-size: 1.6rem;
  font-weight: 700;
  color: #38bdf8;
}

.charts-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.chart-card {
  background: #0f172a;
  border: 1px solid #334155;
  padding: 1.25rem;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.chart-card.full-width {
  grid-column: 1 / -1;
  width: 100%;
  max-width: none;
  margin: 0;
  display: flex;
  flex-direction: column;
}
.chart-card h4 {
  font-size: 0.95rem;
  color: #f8fafc;
  margin-bottom: 1rem;
  font-weight: 600;
}

.canvas-wrapper {
  position: relative;
  height: 260px;
  width: 100%;
  max-width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.doughnut-height {
  height: 240px;
  width: 100%;
  max-width: 380px;
  margin: 0 auto;
}

.loading-state {
  color: #94a3b8;
  font-size: 0.9rem;
}

.alert-danger {
  background: rgba(239, 68, 68, 0.12);
  border: 1px solid rgba(248, 113, 113, 0.3);
  color: #f87171;
  padding: 0.8rem 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

@media (max-width: 850px) {
  .charts-layout {
    grid-template-columns: 1fr;
  }
  .chart-card.full-width {
    max-width: 100%;
  }
}
</style>