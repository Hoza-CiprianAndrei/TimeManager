<template>
  <div class="login-wrapper">
    <h2>Time Manager - Sign In</h2>
    
    <form @submit.prevent="handleLogin">
      <div class="form-group">
        <label for="email">Email</label>
        <input 
          v-model="email" 
          type="email" 
          id="email" 
          placeholder="admin@timemanager.com" 
          required 
        />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input 
          v-model="password" 
          type="password" 
          id="password" 
          required 
        />
      </div>

      <button type="submit">Login</button>
    </form>

    <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>
  </div>
</template>

<script setup>
import { includeIgnoreFile } from 'eslint/config'
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const errorMessage = ref('')
const router = useRouter()

const handleLogin = async () => {
  errorMessage.value = ''

  const apiUrl = import.meta.env.API_URL

  try {
    const response = await fetch(`${apiUrl}/api/login`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        email: email.value,
        password: password.value
      })
    })

    if (!response.ok) {
      throw new Error('Invalid email or password')
    }

    const data = await response.json()
    
    localStorage.setItem('csrf_token', data.csrf_token)
    const userRole = data.user.role_id || data.user.role
    localStorage.setItem('user_role', data.user.role)
    localStorage.setItem('user_id', data.user.id)
    localStorage.setItem('username', data.user.username)

    sessionStorage.setItem('activeUser', JSON.stringify(data.user))
    if (userRole === 1) {
      router.push('/dashboard') 
    } else {
      router.push(`/clock/${data.user.id}`)
    }
    
  } catch (error) {
    errorMessage.value = error.message
  }
}
</script>

<style scoped>
.login-wrapper {
  max-width: 400px;
  margin: 2rem auto;
  padding: 2rem;
  border: 1px solid #ddd;
  border-radius: 8px;
}
.form-group {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
input {
  padding: 0.5rem;
  margin-top: 0.25rem;
}
button {
  width: 100%;
  padding: 0.75rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.error-text {
  color: red;
  margin-top: 1rem;
  text-align: center;
}
</style>