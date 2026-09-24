import { createRouter, createWebHistory } from 'vue-router'
import WorkingTime from '@/components/WorkingTime.vue'
import WorkingTimes from '@/components/WorkingTimes.vue'
import ClockManager from '@/components/ClockManager.vue'
import ChartManager from '@/components/ChartManager.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/workingTimes/:userID',
      name: 'WorkingTimes',
      component: WorkingTimes,
    },
    {
      path: '/workingTime/:userID',
      name: 'WorkingTimeCreate',
      component: WorkingTime
    },
    {
      path: '/workingTime/:userID/:id',
      name: 'WorkingTimeEdit',
      component: WorkingTime
    },
    {
      path: '/clock/:userID',
      name: 'ClockManager',
      component: ClockManager
    },
    {
      path: '/chartManager/:userID',
      name: 'ChartManager',
      component: ChartManager
    }
  ],
})

export default router
