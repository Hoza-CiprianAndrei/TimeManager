import { reactive } from 'vue'

const savedUser = sessionStorage.getItem('activeUser')

export const globalState = reactive({
    currentUser: savedUser ? JSON.parse(savedUser) : null,

    setUser(user)
    {
        this.currentUser = user
        if (user)
            sessionStorage.setItem('activeUser', JSON.stringify(user))
        else
            sessionStorage.removeItem('activeUser')
    },

    clearUser()
    {
        this.currentUser = null
        sessionStorage.removeItem('activeUser')
    }
})