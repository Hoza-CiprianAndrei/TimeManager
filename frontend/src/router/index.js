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
      component: ClockManager,
      beforeEnter: (to, from, next) => {
        const savedUserRaw = sessionStorage.getItem('activeUser')

        if (!savedUserRaw)
        {
          alert("You need to select a user first!")
          return next({path: '/'})
        }
      }
    },
    {
      path: '/chartManager/:userID',
      name: 'ChartManager',
      component: ChartManager
    }
  ],
})

export default router
