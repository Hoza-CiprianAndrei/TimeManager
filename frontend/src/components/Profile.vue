<template>
  <div class="profile-wrapper">
    <h2>My Profile</h2>
    
    <form @submit.prevent="updateProfile">
      <div class="form-group">
        <label>Username</label>
        <input v-model="user.username" type="text" required />
      </div>
      <div class="form-group">
        <label>Email</label>
        <input v-model="user.email" type="email" required />
      </div>
      <div class="form-group">
      <label>My Teams</label>
      <div v-if="user.teams && user.teams.length > 0" class="team-badges">
        <span v-for="team in user.teams" :key="team.id" class="badge">
          {{ team.name }}
        </span>
      </div>
      <div v-else class="empty-state">
        <p>You are not assigned to any teams yet.</p>
      </div>
    </div>
      
      <button type="submit" class="btn-update">Update Profile</button>
      <button type="button" @click="deleteAccount" class="btn-delete">Delete Account</button>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const userId = localStorage.getItem('user_id')
const csrfToken = localStorage.getItem('csrf_token')

const user = ref({
  username: localStorage.getItem('username') || '',
  email: ''
})

onMounted(async () => {
  const apiUrl = import.meta.env.VITE_API_URL
  const response = await fetch(`${apiUrl}/users/${userId}`, {
    credentials: 'include', 
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'x-csrf-token': csrfToken
    }
  })
  if (response.ok) {
    const data = await response.json()
    user.value = data.data
  }
})

const updateProfile = async () => {
  const apiUrl = import.meta.env.VITE_API_URL
  const response = await fetch(`${apiUrl}/users/${userId}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'x-csrf-token': csrfToken
    },
    body: JSON.stringify({ user: user.value })
  })
  
  if (response.ok) {
    alert('Profile updated successfully!')
    localStorage.setItem('username', user.value.username)
  }
}

const deleteAccount = async () => {
  if (!confirm('Are you sure you want to delete your account? This cannot be undone.')) return

  const apiUrl = import.meta.env.VITE_API_URL
  const response = await fetch(`${apiUrl}/users/${userId}`, {
    method: 'DELETE',
    headers: {
      'x-csrf-token': csrfToken
    }
  })
  
  if (response.ok) {
    localStorage.clear()
    router.push('/register')
  }
}
</script>

<style scoped>
.profile-wrapper { max-width: 500px; margin: 2rem auto; padding: 2rem; border: 1px solid #eee; }
.form-group { margin-bottom: 1rem; display: flex; flex-direction: column; }
input { padding: 0.5rem; }
.btn-update { background-color: #007bff; color: white; padding: 0.5rem 1rem; border: none; cursor: pointer; margin-right: 1rem; }
.btn-delete { background-color: #dc3545; color: white; padding: 0.5rem 1rem; border: none; cursor: pointer; }
.team-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.badge {
  background-color: #374151; /* Match a dark gray/blue aesthetic */
  color: #f3f4f6;
  padding: 0.4rem 0.8rem;
  border-radius: 9999px; /* Pill shape */
  font-size: 0.875rem;
  font-weight: 500;
  border: 1px solid #4b5563;
}

.empty-state p {
  color: #9ca3af;
  font-size: 0.9rem;
  margin-top: 0.5rem;
  font-style: italic;
}
</style>