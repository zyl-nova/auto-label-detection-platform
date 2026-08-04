<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索文件名 / 项目名" :prefix-icon="Search" clearable @keyup.enter="loadFiles" />
      <el-select v-model="typeFilter" placeholder="数据类型" @change="loadFiles">
        <el-option label="全部" value="全部" />
        <el-option label="图像" value="图像" />
        <el-option label="视频" value="视频" />
        <el-option label="其他" value="其他" />
      </el-select>
      <el-button :loading="loading" @click="loadFiles">刷新</el-button>
      <el-button type="primary" @click="router.push('/fileManager/toUpload')">上传文件</el-button>
    </div>

    <el-alert v-if="offlineMode" class="hint" type="warning" show-icon :closable="false" title="暂时没有连上后端，当前显示的是页面缓存数据。启动后端后点击刷新即可读取数据库。" />

    <el-table v-loading="loading" :data="filteredFiles" height="calc(100vh - 250px)" empty-text="暂无文件">
      <el-table-column prop="name" label="文件名" min-width="180" />
      <el-table-column prop="type" label="数据类型" width="100" />
      <el-table-column prop="uploadTime" label="上传时间" min-width="160" />
      <el-table-column prop="projectName" label="所属项目" min-width="130" />
      <el-table-column prop="creator" label="创建人" width="110" />
      <el-table-column label="操作" width="340">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">查看</el-button>
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="primary" @click="previewFile(row)">预览</el-button>
          <el-button link type="primary" @click="createLabelTask(row)">创建标注</el-button>
          <el-button link type="danger" @click="removeFile(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="previewVisible" title="文件预览" width="720px">
      <div class="preview-box">
        <img v-if="previewTarget?.type === '图像' && previewTarget.url && !previewError" :src="previewTarget.url" alt="preview" @error="previewError = true" />
        <video v-else-if="previewTarget?.type === '视频' && previewTarget.url && !previewError" :src="previewTarget.url" controls @error="previewError = true" />
        <el-empty v-else-if="previewError" description="原文件不存在或无法读取，请预览新上传的文件" />
        <el-empty v-else description="该文件暂无可预览资源" />
      </div>
      <div v-if="previewTarget?.url" class="preview-path">{{ previewTarget.url }}</div>
    </el-dialog>

    <el-dialog v-model="detailVisible" title="文件详情" width="560px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="文件名">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="数据类型">{{ detailTarget.type }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="上传时间">{{ detailTarget.uploadTime }}</el-descriptions-item>
        <el-descriptions-item label="创建人">{{ detailTarget.creator }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ detailTarget.source }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑文件信息" width="560px">
      <el-form label-width="90px">
        <el-form-item label="文件名">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="数据类型">
          <el-select v-model="editForm.type">
            <el-option label="图像" value="图像" />
            <el-option label="视频" value="视频" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属项目">
          <el-input v-model="editForm.projectName" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveFile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'
import type { DataType, ManagedFile } from '@/stores/businessStore'
import { deleteFileRecord, listFiles, typeToCode, updateFileRecord } from '@/api/fileManager'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const typeFilter = ref<DataType | '全部'>('全部')
const previewVisible = ref(false)
const previewTarget = ref<ManagedFile>()
const previewError = ref(false)
const loading = ref(false)
const offlineMode = ref(false)
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<ManagedFile>()
const editId = ref<number>()
const editForm = ref({
  name: '',
  type: '图像' as DataType,
  projectName: '',
})

const filteredFiles = computed(() => {
  const text = keyword.value.trim()
  return business.files.filter((item) => {
    const matchType = typeFilter.value === '全部' || item.type === typeFilter.value
    const matchText = !text || `${item.name}${item.projectName}`.includes(text)
    return matchType && matchText
  })
})

const loadFiles = async () => {
  loading.value = true
  try {
    const files = await listFiles({
      keyword: keyword.value.trim(),
      fileType: typeFilter.value === '全部' ? undefined : typeToCode(typeFilter.value),
    })
    business.setFiles(files)
    offlineMode.value = false
  } catch (error) {
    offlineMode.value = true
  } finally {
    loading.value = false
  }
}

const previewFile = (file: ManagedFile) => {
  previewTarget.value = file
  previewError.value = false
  previewVisible.value = true
}

const openDetail = (file: ManagedFile) => {
  detailTarget.value = file
  detailVisible.value = true
}

const openEdit = (file: ManagedFile) => {
  editId.value = file.id
  editForm.value = {
    name: file.name,
    type: file.type,
    projectName: file.projectName,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveFile = async () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写文件名')
    return
  }
  const current = business.files.find((item) => item.id === editId.value)
  if (!current) return
  const updated = {
    ...current,
    name: editForm.value.name.trim(),
    type: editForm.value.type,
    projectName: editForm.value.projectName.trim() || '未分配项目',
  }
  business.updateFile(editId.value, updated)
  try {
    await updateFileRecord(updated)
    offlineMode.value = false
  } catch (error) {
    offlineMode.value = true
    ElMessage.warning('后端暂不可用，修改已先保存在当前页面缓存')
  }
  editVisible.value = false
  ElMessage.success('文件信息已保存')
}

const createLabelTask = (file: ManagedFile) => {
  if (file.type !== '图像') {
    ElMessage.warning('当前标注画布先支持图像文件，视频可先完成抽帧后再标注')
    return
  }
  const task = business.addLabelTask({
    name: `${file.name}-标注任务`,
    projectId: file.projectId,
    projectName: file.projectName,
    fileIds: [file.id],
    labels: ['wire', 'insulator'],
    deadline: '',
    description: `由首页文件 ${file.name} 创建。`,
  })
  ElMessage.success('已创建标注任务，正在进入标注页面')
  router.push({ path: '/label/labeling', query: { taskId: String(task.id), fileId: String(file.id) } })
}

const removeFile = (id: number) => {
  ElMessageBox.confirm('确认删除该文件记录？', '删除文件', { type: 'warning' })
    .then(async () => {
      try {
        await deleteFileRecord(id)
        offlineMode.value = false
      } catch (error) {
        offlineMode.value = true
        ElMessage.warning('后端暂不可用，已先从当前页面缓存移除')
      }
      business.deleteFile(id)
      ElMessage.success('已删除')
    })
    .catch(() => undefined)
}

onMounted(loadFiles)
</script>

<style scoped>
.page {
  padding: 22px;
}

.toolbar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 180px 90px 120px;
  gap: 14px;
  margin-bottom: 18px;
}

.hint {
  margin-bottom: 14px;
}

.preview-box {
  min-height: 320px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #111827;
}

.preview-box img,
.preview-box video {
  max-width: 100%;
  max-height: 520px;
}

.preview-path {
  margin-top: 10px;
  color: #667085;
  font-size: 12px;
  word-break: break-all;
}
</style>
