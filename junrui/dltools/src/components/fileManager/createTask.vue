<template>
  <div class="page">
    <el-page-header content="上传文件" @back="router.push('/fileManager')" />
    <el-form ref="formRef" :model="form" :rules="rules" label-width="110px" class="form">
      <el-form-item label="项目" prop="projectId">
        <el-select v-model="form.projectId" placeholder="选择所属项目">
          <el-option v-for="item in projectOptions" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="数据类型" prop="type">
        <el-radio-group v-model="form.type">
          <el-radio-button label="图像" />
          <el-radio-button label="视频" />
          <el-radio-button label="其他" />
        </el-radio-group>
      </el-form-item>
        <el-form-item label="文件" prop="name">
        <el-upload drag :auto-upload="false" :limit="1" :on-change="handleFileChange" :on-remove="handleRemove">
          <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
          <div class="el-upload__text">拖拽文件到这里，或点击选择</div>
          <template #tip>
            <div class="el-upload__tip">支持 .zip、.mp4、.jpg、.png 等格式</div>
          </template>
        </el-upload>
      </el-form-item>
      <el-form-item label="文件名" prop="name">
        <el-input v-model="form.name" placeholder="未选择文件时可手动填写" />
      </el-form-item>
      <el-form-item label="说明">
        <el-input v-model="form.description" type="textarea" :rows="3" placeholder="可填写文件用途或备注" />
      </el-form-item>
      <el-form-item>
        <el-button @click="router.push('/fileManager')">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitForm(formRef)">保存</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { UploadFilled } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules, UploadFile } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'
import type { DataType } from '@/stores/businessStore'
import { uploadFileRecord } from '@/api/fileManager'

const router = useRouter()
const { business } = allStore()
const formRef = ref<FormInstance>()
const rawFile = ref<File>()
const saving = ref(false)

const projectOptions = [
  { id: 2, name: '防呆1-1' },
  { id: 4, name: '防呆2-1' },
  { id: 1, name: '项目1' },
  { id: 3, name: '项目2' },
]

const form = reactive({
  projectId: 2,
  type: '图像' as DataType,
  name: '',
  url: '',
  description: '',
})

const rules = reactive<FormRules>({
  projectId: [{ required: true, message: '请选择项目', trigger: 'change' }],
  type: [{ required: true, message: '请选择数据类型', trigger: 'change' }],
  name: [{ required: true, message: '请选择或填写文件名', trigger: 'blur' }],
})

const handleFileChange = (file: UploadFile) => {
  if (!file.raw) return
  rawFile.value = file.raw
  form.name = file.raw.name
  form.url = URL.createObjectURL(file.raw)
  const fileName = file.raw.name.toLowerCase()
  if (fileName.endsWith('.zip')) {
    form.type = '图像'
    return
  }
  if (file.raw.type.startsWith('video')) form.type = '视频'
  if (file.raw.type.startsWith('image')) form.type = '图像'
}

const handleRemove = () => {
  rawFile.value = undefined
  form.url = ''
}

const uploadErrorMessage = (error: any) => {
  const status = error?.response?.status
  const serverMessage = error?.response?.data?.message
  if (status === 413) return '压缩包超过后端允许的 500MB 上限'
  if (error?.code === 'ECONNABORTED' || `${error?.message || ''}`.toLowerCase().includes('timeout')) {
    return '压缩包处理超时，请检查压缩包是否损坏或包含过多大图'
  }
  if (serverMessage) return `上传失败：${serverMessage}`
  if (error?.code === 'ERR_NETWORK') return '无法连接后端，请确认 AI 后端已启动'
  return `上传失败：${error?.message || '未知错误'}`
}

const submitForm = async (formEl?: FormInstance) => {
  if (!formEl) return
  await formEl.validate(async (valid) => {
    if (!valid) return
    if (!rawFile.value) {
      ElMessage.warning('请选择要上传的文件')
      return
    }
    if (rawFile.value.size > 500 * 1024 * 1024) {
      ElMessage.warning('文件不能超过 500MB')
      return
    }
    const project = projectOptions.find((item) => item.id === form.projectId) || projectOptions[0]
    saving.value = true
    try {
      await uploadFileRecord(rawFile.value, {
        name: form.name,
        type: form.type,
        projectId: project.id,
        description: form.description,
      })
      ElMessage.success('文件已上传并写入数据库')
      router.push('/fileManager')
    } catch (error) {
      business.addFile({
        name: form.name,
        type: form.type,
        projectId: project.id,
        projectName: project.name,
        url: form.url,
      })
      ElMessage.warning(`${uploadErrorMessage(error)}，已先保存到当前页面缓存`)
      router.push('/fileManager')
    } finally {
      saving.value = false
    }
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
