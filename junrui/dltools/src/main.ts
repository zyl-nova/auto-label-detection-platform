import './assets/main.css'

import "element-plus/theme-chalk/el-message-box.css"; 
import "element-plus/theme-chalk/el-message.css"; 
import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import SvgIcon from './components/svgIcon/SvgIcon.vue'
import './assets/iconfont/iconfont.js'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.component('SvgIcon',SvgIcon)

app.mount('#app')
