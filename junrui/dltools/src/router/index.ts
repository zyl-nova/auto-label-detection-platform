import { createRouter, createWebHistory } from 'vue-router'

import Login from '@/views/LoginView.vue'
import Main from '@/views/MainView.vue'
import FileManager from '@/components/fileManager/index.vue'
import FileManagerCreateTask from '@/components/fileManager/createTask.vue'
import Label from '@/components/labelTag/index.vue'
import LabelCreateTask from '@/components/labelTag/createTask.vue'
import Labeling from '@/components/labelTag/labeling.vue'
import SampleCenter from '@/components/sampleCenter/index.vue'
import SampleUpload from '@/components/sampleCenter/toUpload.vue'
import TaskCenter from '@/components/taskCenter/index.vue'
import ToTrain from '@/components/taskCenter/toTrain.vue'
import TrainSituation from '@/components/taskCenter/trainSituation.vue'
import ModelCenter from '@/components/modelCenter/index.vue'
import ToImport from '@/components/modelCenter/toImport.vue'
import Workspace from '@/components/workspace/index.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path:'/login',
      component:Login
      
    },
    {
      path:'/',
      redirect:'/home'
    },
    {
      path:'/home',
      component: Main,
      children:[
        {
          path:'/fileManager',
          components:{
            main: FileManager,
          },
        },
        {
          path:'/fileManager/toUpload',
          components:{
            main: FileManagerCreateTask
          }
        },
        {
          path:'/label',
          components:{
            main: Label
          }
        },
        {
          path:'/label/createTask',
          components:{
            main: LabelCreateTask
          }
        },
        {
          path:'/label/labeling',
          components:{
            main: Labeling
          }
        },
        {
          path:'/sampleCenter',
          components:{
            main: SampleCenter
          }
        }
        ,
        {
          path:'/sampleCenter/toUpload',
          components:{
            main: SampleUpload
          }
        },
        {
          path:'/taskCenter',
          components:{
            main: TaskCenter
          }
        },
        {
          path:'/taskCenter/toTrain',
          components:{
            main: ToTrain
          }
        },
        {
          name:'trainSituation',
          path:'/taskCenter/toTrain/trainSituation',
          components:{
            main: TrainSituation
          }
        },
        {
          path:'/modelCenter',
          components:{
            main: ModelCenter
          }
        },
        {
          path:'/modelCenter/toImport',
          components:{
            main: ToImport
          }
        },
        {
          path:'/workspace',
          components:{
            main: Workspace
          }
        }
      ]
    },
    
    
    
    

  ]
})

// 导航守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('jwt_token');
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    if (!token) {
      // 如果没有Token，重定向到登录页面
      next({ path: '/login' });
    } else {
      next();
    }
  } else {
    // 确保总是调用 next()
    next(); 
  }
})

export default router
