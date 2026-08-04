<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索任务名 / 项目名" :prefix-icon="Search" clearable />
      <el-select v-model="statusFilter" placeholder="状态">
        <el-option label="全部" value="全部" />
        <el-option label="待标注" value="待标注" />
        <el-option label="标注中" value="标注中" />
        <el-option label="待审核" value="待审核" />
        <el-option label="已完成" value="已完成" />
        <el-option label="审核未通过" value="审核未通过" />
      </el-select>
      <el-button type="primary" @click="router.push('/label/createTask')">创建标注任务</el-button>
    </div>

    <el-table :data="filteredTasks" height="calc(100vh - 250px)" empty-text="暂无标注任务">
      <el-table-column prop="name" label="任务名称" min-width="180" />
      <el-table-column prop="projectName" label="所属项目" width="130" />
      <el-table-column label="标签" min-width="160">
        <template #default="{ row }">
          <el-tag v-for="tag in row.labels" :key="tag" class="tag">{{ tag }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="deadline" label="截止时间" width="130" />
      <el-table-column prop="status" label="状态" width="120" />
      <el-table-column label="进度" width="180">
        <template #default="{ row }">
          <el-progress :percentage="row.progress" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="380">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">查看</el-button>
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="primary" @click="startLabel(row.id)">开始标注</el-button>
          <el-button link type="primary" @click="completeTask(row.id)">完成</el-button>
          <el-button link type="success" :disabled="row.status !== '已完成'" @click="importSample(row.id)">导入样本</el-button>
          <el-button link type="danger" @click="deleteTask(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="标注任务详情" width="620px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="任务名称">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="关联文件">{{ fileNames(detailTarget.fileIds) }}</el-descriptions-item>
        <el-descriptions-item label="标签">{{ detailTarget.labels.join('、') }}</el-descriptions-item>
        <el-descriptions-item label="截止时间">{{ detailTarget.deadline || '未设置' }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detailTarget.status }}</el-descriptions-item>
        <el-descriptions-item label="进度">{{ detailTarget.progress }}%</el-descriptions-item>
        <el-descriptions-item label="说明">{{ detailTarget.description || '暂无说明' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑标注任务" width="620px">
      <el-form label-width="90px">
        <el-form-item label="任务名称">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="editForm.labels" multiple filterable allow-create default-first-option>
            <el-option v-for="item in labelOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="截止时间">
          <el-date-picker v-model="editForm.deadline" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="待标注" value="待标注" />
            <el-option label="标注中" value="标注中" />
            <el-option label="待审核" value="待审核" />
            <el-option label="已完成" value="已完成" />
            <el-option label="审核未通过" value="审核未通过" />
          </el-select>
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="editForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveTask">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'
import type { LabelTask, TaskStatus } from '@/stores/businessStore'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const statusFilter = ref<TaskStatus | '全部'>('全部')
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<LabelTask>()
const editId = ref<number>()
const labelOptions = ['wire', 'insulator', 'car', 'truck', 'cat', 'dog', 'person']
const editForm = ref({
  name: '',
  labels: [] as string[],
  deadline: '',
  status: '待标注' as TaskStatus,
  description: '',
})

const filteredTasks = computed(() => {
  const text = keyword.value.trim()
  return business.labelTasks.filter((item) => {
    const matchStatus = statusFilter.value === '全部' || item.status === statusFilter.value
    const matchText = !text || `${item.name}${item.projectName}`.includes(text)
    return matchStatus && matchText
  })
})

const fileNames = (ids: number[]) => {
  return ids.map((id) => business.files.find((item) => item.id === id)?.name || `文件${id}`).join('、')
}

const openDetail = (task: LabelTask) => {
  detailTarget.value = task
  detailVisible.value = true
}

const openEdit = (task: LabelTask) => {
  editId.value = task.id
  editForm.value = {
    name: task.name,
    labels: [...task.labels],
    deadline: task.deadline,
    status: task.status,
    description: task.description,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveTask = () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写任务名称')
    return
  }
  business.updateLabelTask(editId.value, {
    name: editForm.value.name.trim(),
    labels: editForm.value.labels,
    deadline: editForm.value.deadline,
    status: editForm.value.status,
    progress: editForm.value.status === '已完成'
      ? 100
      : editForm.value.status === '待审核'
        ? 80
        : editForm.value.status === '标注中'
          ? 50
          : editForm.value.status === '待标注'
            ? 0
            : 20,
    description: editForm.value.description,
  })
  editVisible.value = false
  ElMessage.success('标注任务已保存')
}

const startLabel = (id: number) => {
  business.updateLabelTaskStatus(id, '标注中')
  router.push({ path: '/label/labeling', query: { taskId: String(id) } })
}

const completeTask = (id: number) => {
  business.updateLabelTaskStatus(id, '已完成')
  ElMessage.success('标注任务已完成，可导入样本中心')
}

const importSample = (id: number) => {
  business.importSampleFromLabelTask(id)
  ElMessage.success('已导入样本中心')
  router.push('/sampleCenter')
}

const deleteTask = (id: number) => {
  ElMessageBox.confirm('确认删除该标注任务？', '删除标注任务', { type: 'warning' })
    .then(() => {
      business.deleteLabelTask(id)
      ElMessage.success('已删除')
    })
    .catch(() => undefined)
}
</script>

<style scoped>
.page {
  padding: 22px;
}

.toolbar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 180px 140px;
  gap: 14px;
  margin-bottom: 18px;
}

.tag {
  margin-right: 6px;
}
</style>
