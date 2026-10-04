import { createRouter, createWebHistory } from 'vue-router'
import WorkingTime from '@/components/WorkingTime.vue'
import WorkingTimes from '@/components/WorkingTimes.vue'
import ClockManager from '@/components/ClockManager.vue'
import ChartManager from '@/components/ChartManager.vue'
import Login from '@/components/Login.vue' 
import Register from '@/components/Register.vue'
import Profile from '@/components/Profile.vue'
const Dashboard = () => import('@/components/Dashboard.vue')

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/workingTimes/:userID',
    name: 'WorkingTimes',
    component: WorkingTimes,
    meta: { requiresAuth: true }
  },
  {
    path: '/workingTime/:userID',
    name: 'WorkingTimeCreate',
    component: WorkingTime,
    meta: { requiresAuth: true }
  },
  {
    path: '/workingTime/:userID/:id',
    name: 'WorkingTimeEdit',
    component: WorkingTime,
    meta: { requiresAuth: true }
  },
  {
    path: '/clock/:userID',
    name: 'ClockManager',
    component: ClockManager,
    meta: { requiresAuth: true }
  },
  {
    path: '/chartManager/:userID',
    name: 'ChartManager',
    component: ChartManager,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Enforce routing security with beforeEach()
router.beforeEach((to, from, next) => {
  const isAuthenticated = !!localStorage.getItem('csrf_token')

  if (to.meta.requiresAuth && !isAuthenticated) {
    next('/login')
  } else if (to.path === '/login' && isAuthenticated) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router