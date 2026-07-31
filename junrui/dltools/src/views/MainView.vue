<template>
    <div class="app-container">
      <el-container >
        <el-header style="height: 8vh;width: 100vw;padding: 0;"><Header></Header></el-header>
        <el-container>
          
          <el-aside v-if="!editingModel" style="height: 92vh;width: 15vw;"><AsideContainer></AsideContainer></el-aside>
          <el-main style="padding: 0;">
            <router-view name="main" />
          </el-main>
        </el-container>
      </el-container>
    </div>
  </template>
  
  <script setup lang="ts">
  import {onMounted } from 'vue';
  import Header from './HeaderView.vue'
  import AsideContainer from './AsideView.vue';
  import allStore from '../stores';
  import { storeToRefs } from 'pinia';
  
  const {aside} = allStore()
  
  const {editingModel} = storeToRefs(aside)
  onMounted(() => {
    
  });
  
  </script>
  
  
  <style>
  body{
    margin: 0;
  }
  .app-container{
    width: 100vw;
    height: 100vh;
    padding: 0;
    margin: 0;
  }
  .custom-header {
    height: 25%;
  }
  </style>
  