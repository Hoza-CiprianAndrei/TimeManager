<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { activeUserId } from '../activeSession.js'

const router = useRouter()
const API_URL = 'http://localhost:4000/api/users'

const currentUser = ref(null)

const searchId = ref('')
const searchEmail = ref('')
const searchUsername = ref('')

const form = ref({
  username: '',
  email: ''
})

const message = ref('')
const isError = ref(false)

function showNotification(msg, error = false) {
  message.value = msg
  isError.value = error
  setTimeout(() =>{
    message.value = ''
  }, 4000)
}

async function getUser() {
  try 
  {
    let response

    if (searchId.value) 
      response = await axios.get(`${API_URL}/${searchId.value}`)
    else if (searchEmail.value && searchUsername.value)
      response = await axios.get(`${API_URL}?email=${searchEmail.value}&username=${searchUsername.value}`)
    else
    {
      showNotification('Please enter an ID or search the user by email and username!', true)
      return
    }

    currentUser.value = response.data.data
    activeUserId.value = currentUser.value.id
    form.value.username = currentUser.value.username
    form.value.email = currentUser.value.email
    showNotification(`User found: ${currentUser.value.username}!`)

    router.push(`/clock/${currentUser.value.id}`)
  } catch (err)
  {
    showNotification(err.response?.data?.error || 'The requested user was not found!', true)
    currentUser.value = null
  }
}

async function createUser() {
  if (!form.value.username || !form.value.email)
  {
    showNotification('Username and email are required!', true)
    return
  }

  try
  {
    const payload = {
      user: {
        username: form.value.username,
        email: form.value.email
      }
    }

    const response = await axios.post(API_URL, payload)
    currentUser.value = response.data.data
    activeUserId.value = currentUser.value.id
    showNotification(`The user ${currentUser.value.username} was created with the ID: ${currentUser.value.id}`)
    router.push(`/clock/${currentUser.value.id}`)
  } catch (err)
  {
    showNotification('There was an error while trying to create the user. A user with the given credentials might already exists!', true)
  }
}

async function updateUser()
{
  if (!currentUser.value)
  {
    showNotification('There is no user selected!', true)
    return
  }

  try 
  {
    const payload = {
      user: {
        username: form.value.username,
        email: form.value.email
      }
    }

    const response = await axios.put(`${API_URL}/${currentUser.value.id}`, payload)
    currentUser.value = response.data.data
    showNotification('The user data is updated!')
  } catch (err)
  {
    showNotification('Error when trying to update the user data', true)
  }
}

async function deleteUser()
{
  if (!currentUser.value)
  {
    showNotification('There was no user selected for deletion!', true)
    return
  }

  const confirmDelete = confirm(`Are you sure you want to delete the user ${currentUser.value.username}?`)
  if (!confirmDelete)
    return

  try
  {
    await axios.delete(`${API_URL}/${currentUser.value.id}`)
    showNotification(`The user ${currentUser.value.username} was deleted!`)
    currentUser.value = null
    activeUserId.value = null
    form.value.username = ''
    form.value.email = ''
    searchId.value = ''
    router.push('/')
  } catch (err)
  {
    showNotification('There was an error when trying to delete the given user!', true)
  }
}
</script>

<template>
  <div class="user-container">
    <div class="user-header">
      <h2>User Management</h2>
      <div v-if="currentUser" class="active-badge">
        Active user: <strong>{{ currentUser.username }}</strong> (ID: {{ currentUser.id }})
      </div>
      <div v-else class="inactive-badge">
        No user selected!
      </div>
    </div>

    <p v-if="message" :class="['alert', isError ? 'alert-danger' : 'alert-success']">
      {{ message }}
    </p>

    <div class="user-grid">
      <div class="card">
        <h3>Search for a user</h3>
        <div class="form-group">
          <label>By ID:</label>
          <input v-model="searchId" type="number" placeholder="Ex: 1" />
        </div>
        <p class="separator">or</p>
        <div class="form-group">
          <label>By email & username:</label>
          <input v-model="searchEmail" type="email" placeholder="email@example.com" />
          <input v-model="searchUsername" type="text" placeholder="Username" />
        </div>
        <button class="btn btn-secondary" @click="getUser">Search user</button>
      </div>

      <div class="card">
        <h3>{{ currentUser ? 'Modify credentials or delete user' : 'Create a new user' }}</h3>
        <div class="form-group">
          <label>Username:</label>
          <input v-model="form.username" type="text" placeholder="Username" required />
        </div>
        <div class="form-group">
          <label>Email:</label>
          <input v-model="form.email" type="email" placeholder="Email address" required />
        </div>

        <div class="actions">
          <button v-if="!currentUser" class="btn btn-primary" @click="createUser">
            Create user
          </button>
          
          <template v-else>
            <button class="btn btn-warning" @click="updateUser">
              Update
            </button>
            <button class="btn btn-danger" @click="deleteUser">
              Delete
            </button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.user-container {
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 1.75rem 2rem;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4);
}

.user-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #334155;
}

.user-header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
  font-weight: 600;
  letter-spacing: -0.3px;
}

.active-badge {
  background: rgba(34, 197, 94, 0.12);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.25);
  padding: 0.45rem 1.1rem;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 600;
}

.inactive-badge {
  background: rgba(239, 68, 68, 0.12);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.25);
  padding: 0.45rem 1.1rem;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 600;
}

.user-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.75rem;
}

@media (max-width: 900px) {
  .user-grid {
    grid-template-columns: 1fr;
  }
}

.card {
  background: #0f172a;
  border: 1px solid #334155;
  padding: 1.5rem;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
}

.card h3 {
  font-size: 1rem;
  color: #94a3b8;
  margin-bottom: 1.25rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
  margin-bottom: 1rem;
}

label {
  font-size: 0.82rem;
  color: #94a3b8;
  font-weight: 500;
}

input {
  background: #1e293b;
  border: 1px solid #334155;
  color: #f8fafc;
  padding: 0.65rem 0.9rem;
  border-radius: 8px;
  font-size: 0.92rem;
  outline: none;
  transition: all 0.2s ease;
}

input::placeholder {
  color: #475569;
}

input:focus {
  border-color: #38bdf8;
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

.separator {
  text-align: center;
  margin: 0.6rem 0;
  color: #64748b;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1.5px;
}

.actions {
  display: flex;
  gap: 0.75rem;
  margin-top: auto;
  padding-top: 1rem;
}

.btn {
  padding: 0.65rem 1.25rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.btn:active {
  transform: translateY(1px);
}

.btn-primary {
  background: #0284c7;
  color: #ffffff;
  width: 100%;
}
.btn-primary:hover {
  background: #0369a1;
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);
}

.btn-secondary {
  background: #334155;
  color: #f8fafc;
  width: 100%;
}
.btn-secondary:hover {
  background: #475569;
}

.btn-warning {
  background: #d97706;
  color: #ffffff;
  flex: 1;
}
.btn-warning:hover {
  background: #b45309;
}

.btn-danger {
  background: #dc2626;
  color: #ffffff;
  flex: 1;
}
.btn-danger:hover {
  background: #b91c1c;
}

.alert {
  padding: 0.8rem 1rem;
  border-radius: 8px;
  margin-bottom: 1.25rem;
  font-size: 0.9rem;
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