<template>
  <div class="page">
    <el-page-header content="导入模型" @back="router.push('/modelCenter')" />
    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" class="form">
      <el-form-item label="模型名称" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="项目" prop="projectId">
        <el-select v-model="form.projectId">
          <el-option v-for="item in projectOptions" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="任务类型" prop="taskType">
        <el-radio-group v-model="form.taskType">
          <el-radio-button label="图像识别" />
          <el-radio-button label="视频识别" />
        </el-radio-group>
      </el-form-item>
      <el-form-item label="识别类别" prop="targetType">
        <el-select v-model="form.targetType">
          <el-option label="车辆" value="车辆" />
          <el-option label="电线" value="电线" />
          <el-option label="动物" value="动物" />
        </el-select>
      </el-form-item>
      <el-form-item label="模型描述">
        <el-input v-model="form.description" type="textarea" :rows="4" />
      </el-form-item>
      <el-form-item>
        <el-button @click="router.push('/modelCenter')">取消</el-button>
        <el-button type="primary" @click="submitForm(formRef)">保存模型</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'

const router = useRouter()
const { business } = allStore()
const formRef = ref<FormInstance>()

const projectOptions = [
  { id: 2, name: 'Node 1.1' },
  { id: 3, name: 'Node 1.2' },
  { id: 6, name: 'Node 2.1' },
]

const form = reactive({
  name: '',
  projectId: 2,
  taskType: '图像识别' as '图像识别' | '视频识别',
  targetType: '电线' as '车辆' | '电线' | '动物',
  description: '',
})

const rules = reactive<FormRules>({
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  taskType: [{ required: true, message: '请选择任务类型', trigger: 'change' }],
  targetType: [{ required: true, message: '请选择识别类别', trigger: 'change' }],
})

const submitForm = async (formEl?: FormInstance) => {
  if (!formEl) return
  await formEl.validate((valid) => {
    if (!valid) return
    const project = projectOptions.find((item) => item.id === form.projectId) || projectOptions[0]
    business.addModel({
      name: form.name,
      projectId: project.id,
      projectName: project.name,
      taskType: form.taskType,
      targetType: form.targetType,
      description: form.description,
    })
    ElMessage.success('模型已导入，发布后可在工作区调用')
    router.push('/modelCenter')
  })
}
</script>

<style scoped>
.page {
  padding: 22px;
}

.form {
  margin-top: 22px;
  max-width: 760px;
}
</style>
