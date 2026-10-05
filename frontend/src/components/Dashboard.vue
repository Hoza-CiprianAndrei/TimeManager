<template>
  <div class="admin-wrapper">
    <h2>Admin Dashboard - User Management</h2>
    <p>Manage application users and their access levels.</p>

    <div v-if="error" class="error-banner">{{ error }}</div>

    <table class="user-table" v-if="users.length > 0">
      <thead>
        <tr>
          <th>ID</th>
          <th>Username</th>
          <th>Email</th>
          <th>Role Management</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.id }}</td>
          <td>{{ user.username }}</td>
          <td>{{ user.email }}</td>
          <td>
            <!-- Dropdown for role promotion/demotion -->
            <select v-model="user.role_id" class="role-select">
              <option :value="1">Administrator</option>
              <option :value="2">User</option>
            </select>
          </td>
          <td>
            <button @click="updateUserRole(user.id, user.role_id)" class="btn-update">
              Save Role
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <p v-else-if="!error">Loading users...</p>

    <hr class="divider" />
    <h2>Team Management</h2>
    
    <div class="team-controls">
      <!-- Create Team -->
      <div class="control-group">
        <h3>Create New Team</h3>
        <input v-model="newTeamName" placeholder="Team Name" class="input-field" />
        <button @click="createTeam" class="btn-create">Create Team</button>
      </div>

      <!-- Assign User to Team -->
      <div class="control-group">
        <h3>Assign User to Team</h3>
        <select v-model="selectedTeamId" class="select-field">
          <option disabled value="">Select a Team...</option>
          <option v-for="team in teams" :key="team.id" :value="team.id">
            {{ team.name }}
          </option>
        </select>

        <select v-model="selectedUserId" class="select-field">
          <option disabled value="">Select a User...</option>
          <option v-for="user in users" :key="user.id" :value="user.id">
            {{ user.username }} ({{ user.email }})
          </option>
        </select>

        <button @click="addUserToTeam" class="btn-update">Assign User</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const users = ref([])
const error = ref('')
const csrfToken = localStorage.getItem('csrf_token')

// Team State variables
const teams = ref([])
const newTeamName = ref('')
const selectedTeamId = ref('')
const selectedUserId = ref('')

// Fetch all users
const fetchUsers = async () => {
  const apiUrl = import.meta.env.VITE_API_URL
  try {
    const response = await fetch(`${apiUrl}/users`, {
      credentials: 'include',
      headers: {
        'Accept': 'application/json',
        'x-csrf-token': csrfToken
      }
    })
    
    if (!response.ok) throw new Error('Failed to fetch users. Check your permissions.')
    
    const data = await response.json()
    users.value = data.data 
  } catch (err) {
    error.value = err.message
  }
}

// Send PUT request to promote or demote the user
const updateUserRole = async (userId, newRoleId) => {
  try {
    const apiUrl = import.meta.env.VITE_API_URL
    const response = await fetch(`${apiUrl}/users/${userId}`, {
      method: 'PUT',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrfToken
      },
      body: JSON.stringify({
        user: { role_id: parseInt(newRoleId) }
      })
    })

    if (!response.ok) throw new Error('Failed to update user role.')
    
    alert('User role successfully updated!')
  } catch (err) {
    alert(err.message)
  }
}

// Fetch existing teams
const fetchTeams = async () => {
  try {
    const apiUrl = import.meta.env.VITE_API_URL
    const response = await fetch(`${apiUrl}/teams`, {
      credentials: 'include',
      headers: { 'Accept': 'application/json', 'x-csrf-token': csrfToken }
    })
    if (response.ok) {
      const data = await response.json()
      teams.value = data.data
    }
  } catch (err) {
    console.error('Failed to fetch teams:', err)
  }
}

// Create a new team
const createTeam = async () => {
  if (!newTeamName.value) return alert('Enter a team name')
  try {
    const apiUrl = import.meta.env.VITE_API_URL
    const response = await fetch(`${apiUrl}/teams`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrfToken
      },
      body: JSON.stringify({ team: { name: newTeamName.value } })
    })
    if (response.ok) {
      alert('Team created!')
      newTeamName.value = ''
      fetchTeams() // Refresh the dropdown
    }
  } catch (err) {
    alert('Failed to create team.')
  }
}

// Assign user to team
const addUserToTeam = async () => {
  if (!selectedTeamId.value || !selectedUserId.value) return alert('Select both a team and a user')
  try {
    const apiUrl = import.meta.env.VITE_API_URL
    const response = await fetch(`${apiUrl}/teams/${selectedTeamId.value}/users`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'x-csrf-token': csrfToken
      },
      body: JSON.stringify({ user_id: selectedUserId.value })
    })
    if (response.ok) {
      alert('User successfully assigned to team!')
      selectedUserId.value = ''
    } else {
      alert('Failed to assign user. They might already be in this team.')
    }
  } catch (err) {
    alert('Error assigning user.')
  }
}

onMounted(() => {
  fetchUsers()
  fetchTeams()
})
</script>

<style scoped>
.admin-wrapper {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background-color: #4d769f;
  border-radius: 8px;
}
.user-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
  background-color: white;
}
.user-table th, .user-table td {
  border: 1px solid #ddd;
  padding: 12px;
  text-align: left;
  color: #2c3e50;
}
.user-table th {
  background-color: #2c3e50;
  color: white;
}
.role-select {
  padding: 0.4rem;
  border-radius: 4px;
}
.btn-update {
  background-color: #28a745;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}
.btn-update:hover {
  background-color: #218838;
}
.error-banner {
  background-color: #f8d7da;
  color: #721c24;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}
.divider { margin: 2rem 0; border: 0; border-top: 1px solid #ddd; }
.team-controls { display: flex; gap: 2rem; margin-top: 1rem; }
.control-group { background: white; padding: 1.5rem; border-radius: 8px; border: 1px solid #ddd; flex: 1; }
.control-group h3 { margin-top: 0; color: #2c3e50; }
.input-field, .select-field { width: 100%; padding: 0.5rem; margin-bottom: 1rem; box-sizing: border-box; }
.btn-create { background-color: #007bff; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; }
.btn-create:hover { background-color: #0056b3; }
</style>