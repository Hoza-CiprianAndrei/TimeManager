<script setup>
import { ref, watch } from 'vue'
import { RouterLink, RouterView, useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

// Reactive references to your security data
const isAuthenticated = ref(!!localStorage.getItem('csrf_token'))
const activeId = ref(localStorage.getItem('user_id'))
const userRole = ref(localStorage.getItem('user_role'))

// Automatically update the navbar whenever the route changes (like after login/logout)
watch(route, () => {
  isAuthenticated.value = !!localStorage.getItem('csrf_token')
  activeId.value = localStorage.getItem('user_id')
  userRole.value = localStorage.getItem('user_role')
})

const logout = () => {
  localStorage.clear() // Wipes the tokens
  router.push('/login')
}
</script>

<template>
  <div id="app-container">
    <header class="app-header">
      <div class="logo">
        <h1>Time Manager</h1>
      </div>

      <nav class="nav-links">
        <!-- Links shown ONLY to logged-in users -->
        <template v-if="isAuthenticated">
          <RouterLink v-if="userRole === 'Administrator'" to="/dashboard">Admin Dashboard</RouterLink>
          
          <RouterLink :to="'/clock/' + activeId">Clock Manager</RouterLink>
          <RouterLink :to="'/workingTimes/' + activeId">Working Times</RouterLink>
          <RouterLink :to="'/workingTime/' + activeId">New Working Time</RouterLink>
          <RouterLink :to="'/chartManager/' + activeId">Charts</RouterLink>
          <RouterLink to="/profile">My Profile</RouterLink>
          
          <button @click="logout" class="logout-btn">Logout</button>
        </template>
        
        <!-- Links shown ONLY to guests -->
        <template v-else>
          <RouterLink to="/login">Sign In</RouterLink>
          <RouterLink to="/register">Register</RouterLink>
        </template>
      </nav>
    </header>

    <main class="content-area">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
#app-container {
  font-family: Arial, sans-serif;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #eee;
  padding-bottom: 1rem;
  margin-bottom: 1.5rem;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.nav-links a {
  text-decoration: none;
  color: #2c3e50;
  font-weight: bold;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
}

.nav-links a.router-link-active {
  background-color: #42b883;
  color: white;
}

.logout-btn {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.2s;
}

.logout-btn:hover {
  background-color: #c82333;
}

.content-area {
  padding: 1rem 0;
}
</style>