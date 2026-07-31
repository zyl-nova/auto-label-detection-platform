<template>
  <div class="page">
    <el-page-header content="导入样本" @back="router.push('/sampleCenter')" />
    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" class="form">
      <el-form-item label="样本名称" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="项目" prop="projectId">
        <el-select v-model="form.projectId">
          <el-option v-for="item in projectOptions" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="样本类型" prop="type">
        <el-radio-group v-model="form.type">
          <el-radio-button label="图像" />
          <el-radio-button label="结构化数据" />
        </el-radio-group>
      </el-form-item>
      <el-form-item label="样本量" prop="count">
        <el-input-number v-model="form.count" :min="1" />
      </el-form-item>
      <el-form-item label="样本描述">
        <el-input v-model="form.description" type="textarea" :rows="4" />
      </el-form-item>
      <el-form-item>
        <el-button @click="router.push('/sampleCenter')">取消</el-button>
        <el-button type="primary" @click="submitForm(formRef)">保存样本</el-button>
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
  type: '图像' as '图像' | '结构化数据',
  count: 100,
  description: '',
})

const rules = reactive<FormRules>({
  name: [{ required: true, message: '请输入样本名称', trigger: 'blur' }],
  projectId: [{ required: true, message: '请选择项目', trigger: 'change' }],
  count: [{ required: true, message: '请输入样本量', trigger: 'change' }],
})

const submitForm = async (formEl?: FormInstance) => {
  if (!formEl) return
  await formEl.validate((valid) => {
    if (!valid) return
    const project = projectOptions.find((item) => item.id === form.projectId) || projectOptions[0]
    business.addSample({
      name: form.name,
      type: form.type,
      projectId: project.id,
      projectName: project.name,
      count: form.count,
      description: form.description,
    })
    ElMessage.success('样本已导入')
    router.push('/sampleCenter')
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
