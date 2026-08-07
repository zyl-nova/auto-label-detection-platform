<template>
  <div class="header-container">
    <el-row>
      <el-col :span="5">
        <img :src="logo" class="logo" />
      </el-col>
      <el-col :span="19" class="nav-col">
        <el-space spacer="|">
          <div class="module-tabs">
            <div v-for="item in moduleList" :key="item.id">
              <div
                :class="activeName === item.eName ? 'tab-pane active' : 'tab-pane'"
                @click="handleSwitch(item.eName, item.url)"
              >
                {{ item.name }}
              </div>
            </div>
          </div>

          <div class="button">
            <el-button class="button-content" type="primary" link>
              <el-icon class="help-icon"><QuestionFilled /></el-icon>
              帮助
            </el-button>
            <el-button class="button-content" type="primary" link>
              <el-avatar :size="20" :src="circleUrl" class="avatar" />
              {{ currentUserName || '用户' }}
            </el-button>
          </div>
        </el-space>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { QuestionFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'
import allStore from '@/stores'
import { storeToRefs } from 'pinia'

const { currentUser } = allStore()
const { currentUserName } = storeToRefs(currentUser)
const router = useRouter()
const route = useRoute()

const moduleList = ref([
  { id: 0, name: '首页', eName: 'file', url: '/fileManager' },
  { id: 1, name: '标注', eName: 'label', url: '/label' },
  { id: 2, name: '样本中心', eName: 'sample', url: '/sampleCenter' },
  { id: 3, name: '模型中心', eName: 'model', url: '/modelCenter' },
  { id: 4, name: '任务中心', eName: 'task', url: '/taskCenter' },
  { id: 5, name: '工作区', eName: 'workspace', url: '/workspace' },
])

const logo = ref(new URL('@/assets/image/logo.png', import.meta.url).href)
const activeName = computed(() => {
  const currentModule = moduleList.value.find((item) => (
    route.path === item.url || route.path.startsWith(`${item.url}/`)
  ))
  return currentModule?.eName || ''
})
const circleUrl = ref('https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png')

const handleSwitch = (newdata: string, url: string) => {
  if (activeName.value !== newdata || route.path !== url) {
    router.push(url)
  }
}

onMounted(() => {
  request.post('/UserServer/user/getUserName', null, {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8'
    }
  }).then((response) => {
    if (response.data?.data) {
      currentUser.setCurrentUserId(response.data.data.id)
      currentUser.setCurrentUserName(response.data.data.username)
    }
  }).catch(() => {
    currentUser.setCurrentUserName('本地用户')
  })
})
</script>

<style lang="scss" scoped>
.header-container {
  width: 100%;
  height: 100%;
  background-color: rgb(10, 35, 54);
  color: white;
}

.logo {
  height: 8vh;
}

.nav-col {
  display: flex;
  justify-content: end;
  align-items: center;
}

.module-tabs {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 8vh;
}

.tab-pane {
  font-size: 15px;
  height: 8vh;
  width: 5.6vw;
  min-width: 76px;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  cursor: pointer;
}

.tab-pane::after {
  content: '';
  display: block;
  width: 0;
  position: absolute;
  border-bottom: 0.3vw solid rgb(44, 88, 236);
  bottom: 0.3vh;
  transition: width 0.3s ease;
}

.tab-pane.active {
  font-weight: bold;
  color: rgb(94, 139, 255);
}

.tab-pane.active::after {
  width: 100%;
}

.button {
  width: 10vw;
  min-width: 150px;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.button-content {
  color: white;
}

.help-icon,
.avatar {
  margin-right: 0.5em;
}
</style>
