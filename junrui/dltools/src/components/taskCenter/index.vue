<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索任务名 / 项目名" :prefix-icon="Search" clearable />
      <el-select v-model="statusFilter" placeholder="训练状态">
        <el-option label="全部" value="全部" />
        <el-option label="训练中" value="训练中" />
        <el-option label="已完成" value="已完成" />
        <el-option label="失败" value="失败" />
      </el-select>
      <el-button type="primary" @click="router.push('/taskCenter/toTrain')">创建训练任务</el-button>
    </div>

    <div class="cards">
      <div v-for="task in filteredTasks" :key="task.id" class="card">
        <div class="card-head">
          <strong>{{ task.name }}</strong>
          <el-tag :type="statusType(task.status)">{{ task.status }}</el-tag>
        </div>
        <el-progress :percentage="task.progress" :status="task.status === '失败' ? 'exception' : undefined" />
        <div class="meta">项目：{{ task.projectName }}</div>
        <div class="meta">样本：{{ task.sampleName }}</div>
        <div class="meta">预训练模型：{{ task.modelName }}</div>
        <div class="metrics">
          <span>LR {{ task.learningRate }}</span>
          <span>Epoch {{ task.epoch }}</span>
          <span>Batch {{ task.batchSize }}</span>
        </div>
        <div class="actions">
          <el-button @click="openDetail(task)">查看</el-button>
          <el-button @click="openEdit(task)">编辑</el-button>
          <el-button @click="router.push({ name: 'trainSituation', state: { trainResult: task.status === '失败' ? 2 : task.status === '已完成' ? 1 : 0 } })">训练看板</el-button>
          <el-button type="success" :disabled="task.status === '已完成'" @click="finishTask(task.id)">完成训练</el-button>
          <el-button @click="copyTask(task.id)">复制</el-button>
          <el-button type="danger" @click="deleteTask(task.id)">删除</el-button>
        </div>
      </div>
    </div>

    <el-dialog v-model="detailVisible" title="训练任务详情" width="640px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="任务名称">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="样本集">{{ detailTarget.sampleName }}</el-descriptions-item>
        <el-descriptions-item label="预训练模型">{{ detailTarget.modelName }}</el-descriptions-item>
        <el-descriptions-item label="学习率">{{ detailTarget.learningRate }}</el-descriptions-item>
        <el-descriptions-item label="训练轮次">{{ detailTarget.epoch }}</el-descriptions-item>
        <el-descriptions-item label="批大小">{{ detailTarget.batchSize }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detailTarget.status }}</el-descriptions-item>
        <el-descriptions-item label="进度">{{ detailTarget.progress }}%</el-descriptions-item>
        <el-descriptions-item label="说明">{{ detailTarget.description || '暂无说明' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑训练任务" width="640px">
      <el-form label-width="90px">
        <el-form-item label="任务名称">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="学习率">
          <el-input-number v-model="editForm.learningRate" :min="0.0001" :step="0.001" :precision="4" />
        </el-form-item>
        <el-form-item label="训练轮次">
          <el-input-number v-model="editForm.epoch" :min="1" />
        </el-form-item>
        <el-form-item label="批大小">
          <el-input-number v-model="editForm.batchSize" :min="1" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="训练中" value="训练中" />
            <el-option label="已完成" value="已完成" />
            <el-option label="失败" value="失败" />
          </el-select>
        </el-form-item>
        <el-form-item label="进度">
          <el-slider v-model="editForm.progress" :min="0" :max="100" />
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
import type { TrainStatus, TrainTask } from '@/stores/businessStore'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const statusFilter = ref<TrainStatus | '全部'>('全部')
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<TrainTask>()
const editId = ref<number>()
const editForm = ref({
  name: '',
  learningRate: 0.01,
  epoch: 100,
  batchSize: 16,
  progress: 0,
  status: '训练中' as TrainStatus,
  description: '',
})

const filteredTasks = computed(() => {
  const text = keyword.value.trim()
  return business.trainTasks.filter((item) => {
    const matchStatus = statusFilter.value === '全部' || item.status === statusFilter.value
    const matchText = !text || `${item.name}${item.projectName}`.includes(text)
    return matchStatus && matchText
  })
})

const statusType = (status: TrainStatus) => {
  if (status === '已完成') return 'success'
  if (status === '失败') return 'danger'
  return 'warning'
}

const openDetail = (task: TrainTask) => {
  detailTarget.value = task
  detailVisible.value = true
}

const openEdit = (task: TrainTask) => {
  editId.value = task.id
  editForm.value = {
    name: task.name,
    learningRate: task.learningRate,
    epoch: task.epoch,
    batchSize: task.batchSize,
    progress: task.progress,
    status: task.status,
    description: task.description,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveTask = () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写训练任务名称')
    return
  }
  const progress = editForm.value.status === '已完成'
    ? 100
    : editForm.value.status === '失败'
      ? editForm.value.progress
      : Math.min(editForm.value.progress, 99)
  business.updateTrainTask(editId.value, {
    name: editForm.value.name.trim(),
    learningRate: editForm.value.learningRate,
    epoch: editForm.value.epoch,
    batchSize: editForm.value.batchSize,
    progress,
    status: editForm.value.status,
    description: editForm.value.description,
  })
  editVisible.value = false
  ElMessage.success('训练任务已保存')
}

const finishTask = (id: number) => {
  business.finishTrainTask(id)
  ElMessage.success('训练已完成，并生成已发布模型')
}

const copyTask = (id: number) => {
  const task = business.trainTasks.find((item) => item.id === id)
  if (!task) return
  business.addTrainTask({
    name: `${task.name}-副本`,
    projectId: task.projectId,
    projectName: task.projectName,
    sampleId: task.sampleId,
    sampleName: task.sampleName,
    modelId: task.modelId,
    modelName: task.modelName,
    learningRate: task.learningRate,
    epoch: task.epoch,
    batchSize: task.batchSize,
    description: task.description,
  })
  ElMessage.success('已复制训练任务')
}

const deleteTask = (id: number) => {
  ElMessageBox.confirm('确认删除该训练任务？', '删除训练任务', { type: 'warning' })
    .then(() => {
      business.deleteTrainTask(id)
      ElMessage.success('训练任务已删除')
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
  grid-template-columns: minmax(260px, 1fr) 180px 150px;
  gap: 14px;
  margin-bottom: 18px;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.card {
  padding: 16px;
  border: 1px solid #d8dee9;
  border-radius: 8px;
  background: #fff;
}

.card-head,
.metrics,
.actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.card-head {
  margin-bottom: 12px;
}

.meta,
.metrics {
  margin-top: 10px;
  color: #667085;
  font-size: 13px;
}

.actions {
  margin-top: 14px;
  flex-wrap: wrap;
  justify-content: flex-start;
}
</style>
