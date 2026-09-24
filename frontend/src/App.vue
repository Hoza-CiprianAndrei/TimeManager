<script setup>
import { RouterLink, RouterView } from 'vue-router'
import User from './components/User.vue';
</script>

<template>
  <div id="app-container">
    <header class="app-header">
      <div class="logo">
        <h1>Time Manager</h1>
      </div>

      <nav class="nav-links">
        <RouterLink to="/clock/1">Clock Manager</RouterLink>
        <RouterLink to="/workingTimes/1">Working Times</RouterLink>
        <RouterLink to="/workingTime/1">New Working Time</RouterLink>
        <RouterLink to="/chartManager/1">Charts</RouterLink>
      </nav>
    </header>

    <section class="user-section">
      <User />
    </section>

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

.user-section {
  width: 95%;
  max-width: 1400px;
  margin: 1.5rem auto 1rem auto;
  background: transparent; /* Asigură fundal transparent fără chenar */
  border: none;
  padding: 0;
}

.content-area {
  padding: 1rem 0;
}
</style>
