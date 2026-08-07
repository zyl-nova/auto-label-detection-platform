<template>
    <div>
        <h1>Login</h1>
        <form @submit.prevent="login">
            <input v-model="username" placeholder="Username" />
            <input type="password" v-model="password" placeholder="Password" />
            <button type="submit" >登录</button>
        </form  >
            
    </div>
  </template>
  
  <script lang="ts" setup>
    import request from '@/utils/request';
    import { ref } from 'vue';
    import {useRouter} from 'vue-router'
    import axios from 'axios';

    const router = useRouter()
    const username = ref('')
    const password = ref('')
    const login = async() =>{
        try {
            
            const response = await request.post('/AuthServer/login',null, {params:{
                    username: username.value,
                    password: password.value,
                },
                headers: {
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })
            if (response.data.code == 200) {
                localStorage.setItem('jwt_token', response.data.data);
                router.push('/fileManager')
            }
        } catch (error) {
          console.error('Login error:', error);
        }
    }

  </script>
