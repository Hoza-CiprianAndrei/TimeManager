import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'

axios.defaults.withCredentials = true

axios.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('csrf_token')

        if (token)
            config.headers['x-csrf-token'] = token
        return config
    },
    (error) => {
        return Promise.reject(error)
    }
)

const app = createApp(App)

app.use(router)

app.mount('#app')
