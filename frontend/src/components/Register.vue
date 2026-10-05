<template>
  <div class="auth-wrapper">
    <h2>Time Manager - Register</h2>
    
    <form @submit.prevent="handleRegister">
      <div class="form-group">
        <label for="username">Username</label>
        <input v-model="username" type="text" id="username" required />
      </div>

      <div class="form-group">
        <label for="email">Email</label>
        <input v-model="email" type="email" id="email" required />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input v-model="password" type="password" id="password" required />
      </div>

      <button type="submit">Create Account</button>
    </form>

    <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>
    <p class="nav-link">Already have an account? <router-link to="/login">Sign In</router-link></p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const username = ref('')
const email = ref('')
const password = ref('')
const errorMessage = ref('')
const router = useRouter()

const handleRegister = async () => {
  errorMessage.value = ''

  const apiUrl = import.meta.env.VITE_API_URL
  try {
    console.log("Test deploy URL:", import.meta.env.VITE_API_URL);
    const response = await fetch(`${apiUrl}/users`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        user: {
          username: username.value,
          email: email.value,
          password: password.value,
          role_id: 2
        }
      })
    })

    if (!response.ok){
        const errorDetails = await response.json()
        console.log("Detailed backend error:", errorDetails)
        throw new Error(JSON.stringify(errorDetails.errors || errorDetails))
    }

    router.push('/login')
  } catch (error) {
    errorMessage.value = error.message
  }
}
</script>

<style scoped>
.auth-wrapper { max-width: 400px; margin: 2rem auto; padding: 2rem; border: 1px solid #ddd; border-radius: 8px; }
.form-group { margin-bottom: 1rem; display: flex; flex-direction: column; }
input { padding: 0.5rem; margin-top: 0.25rem; }
button { width: 100%; padding: 0.75rem; background-color: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; }
.error-text { color: red; margin-top: 1rem; text-align: center; }
.nav-link { margin-top: 1rem; text-align: center; font-size: 0.9rem; }
</style>