import './assets/main.css'

import "element-plus/theme-chalk/el-message-box.css"; 
import "element-plus/theme-chalk/el-message.css"; 
import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import SvgIcon from './components/svgIcon/SvgIcon.vue'
import './assets/iconfont/iconfont.js'
import { persistBusinessStore } from './stores/persistBusinessStore'

const app = createApp(App)
const pinia = createPinia()

pinia.use(persistBusinessStore)

app.use(pinia)
app.use(router)
app.component('SvgIcon',SvgIcon)

app.mount('#app')
