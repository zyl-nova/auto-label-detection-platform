import axios from 'axios';
import {useRouter} from 'vue-router'
const router = useRouter()
// 创建axios实例
const request = axios.create({
    baseURL: '/api', // 你的API地址
    timeout: 10000, // 请求超时
  });
  
  // 请求拦截器
  request.interceptors.request.use(
    (config) => {
      // 从本地存储中获取 JWT Token
      const token = localStorage.getItem('jwt_token')
      if (token) {
        // 在请求头中添加 Authorization
        config.headers['Authorization'] = `Bearer ${token}`
      }
      return config
    },
    (error) => {
      // 请求错误时的处理
      return Promise.reject(error);
    }
  );
  
  // 响应拦截器
  request.interceptors.response.use(

    (response) => {
      // 正常响应处理
      if(response.data.code === 401){
        // 处理401未授权（如Token过期等）
        // 可以在此进行重定向到登录页面等操作
        console.log('Unauthorized, redirecting to login...')
        // 清除JWT token并重定向到登录页面
        localStorage.removeItem('jwt_token')
        window.location.href = '/login'
      }else if(response.data.code === 403){
        // 处理403禁止访问
        console.log('Forbidden')
      }
      // console.log(response)
      return response
    },
    (error) => {
        console.log(error)
      
      return Promise.reject(error)
    }
  );
  
  export default request