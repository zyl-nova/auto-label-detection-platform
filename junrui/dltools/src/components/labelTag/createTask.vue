<template>
  <div class="page">
    <el-page-header content="创建标注任务" @back="router.push('/label')" />
    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" class="form">
      <el-form-item label="任务名称" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="项目" prop="projectId">
        <el-select v-model="form.projectId" @change="form.fileIds = []">
          <el-option v-for="item in projectOptions" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="文件集" prop="fileIds">
        <el-select v-model="form.fileIds" multiple placeholder="选择待标注文件">
          <el-option v-for="file in filesByProject" :key="file.id" :label="file.name" :value="file.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="标签">
        <el-tag v-for="tag in form.labels" :key="tag" closable class="tag" @close="removeTag(tag)">{{ tag }}</el-tag>
        <el-input v-if="addingTag" ref="tagInputRef" v-model="tagInput" class="tag-input" size="small" @keyup.enter="addTag" @blur="addTag" />
        <el-button v-else size="small" @click="addingTag = true">新增标签</el-button>
      </el-form-item>
      <el-form-item label="截止时间">
        <el-date-picker v-model="form.deadline" value-format="YYYY-MM-DD" type="date" placeholder="选择日期" />
      </el-form-item>
      <el-form-item label="任务描述">
        <el-input v-model="form.description" type="textarea" :rows="4" />
      </el-form-item>
      <el-form-item>
        <el-button @click="router.push('/label')">取消</el-button>
        <el-button type="primary" @click="submitForm(formRef)">保存任务</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script lang="ts" setup>
import { computed, nextTick, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules, InputInstance } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'

const router = useRouter()
const { business } = allStore()
const formRef = ref<FormInstance>()
const tagInputRef = ref<InputInstance>()
const addingTag = ref(false)
const tagInput = ref('')

const projectOptions = [
  { id: 2, name: 'Node 1.1' },
  { id: 3, name: 'Node 1.2' },
  { id: 6, name: 'Node 2.1' },
]

const form = reactive({
  name: '',
  projectId: 2,
  fileIds: [] as number[],
  labels: ['wire', 'insulator'],
  deadline: '',
  description: '',
})

const rules = reactive<FormRules>({
  name: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  projectId: [{ required: true, message: '请选择项目', trigger: 'change' }],
  fileIds: [{ required: true, message: '请选择文件集', trigger: 'change' }],
})

const filesByProject = computed(() => business.files.filter((item) => item.projectId === form.projectId && item.type !== '其他'))

const addTag = () => {
  const value = tagInput.value.trim()
  if (value && !form.labels.includes(value)) form.labels.push(value)
  tagInput.value = ''
  addingTag.value = false
}

const removeTag = (tag: string) => {
  form.labels = form.labels.filter((item) => item !== tag)
}

const submitForm = async (formEl?: FormInstance) => {
  if (!formEl) return
  await formEl.validate((valid) => {
    if (!valid) return
    const project = projectOptions.find((item) => item.id === form.projectId) || projectOptions[0]
    business.addLabelTask({
      name: form.name,
      projectId: project.id,
      projectName: project.name,
      fileIds: form.fileIds,
      labels: form.labels,
      deadline: form.deadline,
      description: form.description,
    })
    ElMessage.success('标注任务已创建')
    router.push('/label')
  })
}

const focusTagInput = () => nextTick(() => tagInputRef.value?.focus())
</script>

<style scoped>
.page {
  padding: 22px;
}

.form {
  margin-top: 22px;
  max-width: 780px;
}

.tag {
  margin-right: 8px;
}

.tag-input {
  width: 120px;
}
</style>
