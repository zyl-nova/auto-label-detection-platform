<template>
  <div class="training-page">
    <el-page-header content="训练看板" @back="router.push('/taskCenter')" />

    <el-empty v-if="!task" description="训练任务不存在" />
    <template v-else>
      <div class="summary">
        <div>
          <h2>{{ task.name }}</h2>
          <p>{{ statusMessage }}</p>
        </div>
        <el-tag :type="statusTagType" size="large">{{ task.status }}</el-tag>
      </div>

      <section class="progress-section">
        <div class="progress-title">
          <span>训练进度</span>
          <span>Epoch {{ task.currentEpoch || 0 }} / {{ task.epoch }}</span>
        </div>
        <el-progress
          :percentage="task.progress"
          :stroke-width="18"
          :status="task.status === '失败' ? 'exception' : task.status === '已完成' ? 'success' : undefined"
        />
      </section>

      <section class="metrics-grid">
        <div class="metric"><span>Box Loss</span><strong>{{ metric(task.boxLoss) }}</strong></div>
        <div class="metric"><span>Class Loss</span><strong>{{ metric(task.clsLoss) }}</strong></div>
        <div class="metric"><span>Precision</span><strong>{{ metric(task.precision) }}</strong></div>
        <div class="metric"><span>Recall</span><strong>{{ metric(task.recall) }}</strong></div>
        <div class="metric"><span>mAP@50</span><strong>{{ metric(task.map50) }}</strong></div>
        <div class="metric"><span>mAP@50:95</span><strong>{{ metric(task.map5095) }}</strong></div>
      </section>

      <section v-if="task.modelPath" class="result-section">
        <h3>训练结果</h3>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="最佳模型">{{ task.modelPath }}</el-descriptions-item>
          <el-descriptions-item label="样本集">{{ task.sampleName }}</el-descriptions-item>
          <el-descriptions-item label="预训练模型">{{ task.modelName }}</el-descriptions-item>
        </el-descriptions>
      </section>

      <section class="log-section">
        <div class="log-title">
          <h3>训练日志</h3>
          <el-button :loading="refreshing" @click="refreshStatus">刷新</el-button>
        </div>
        <pre>{{ task.logs || '等待训练进程输出...' }}</pre>
      </section>

      <div class="actions">
        <el-button @click="router.push('/taskCenter')">返回任务中心</el-button>
        <el-button v-if="task.status === '训练中' && task.jobId" type="danger" @click="stopTraining">停止训练</el-button>
      </div>
    </template>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRoute, useRouter } from 'vue-router'
import allStore from '@/stores'
import { cancelTraining, getTrainingStatus } from '@/api/training'
import type { TrainStatus } from '@/stores/businessStore'

const route = useRoute()
const router = useRouter()
const { business } = allStore()
const refreshing = ref(false)
const taskId = computed(() => Number(route.query.taskId || 0))
const task = computed(() => business.trainTasks.find((item) => item.id === taskId.value))
const statusMessage = computed(() => task.value?.message || (task.value?.status === '训练中' ? '正在等待训练进度' : ''))
const statusTagType = computed(() => task.value?.status === '已完成' ? 'success' : task.value?.status === '失败' ? 'danger' : 'warning')

const metric = (value?: number) => value === undefined || value === null ? '--' : value.toFixed(4)

const refreshStatus = async () => {
  if (!task.value?.jobId) return
  refreshing.value = true
  try {
    const status = await getTrainingStatus(task.value.jobId)
    const trainStatus:TrainStatus = status.status === 'completed'
      ? '已完成'
      : status.status === 'failed' || status.status === 'cancelled'
        ? '失败'
        : '训练中'
    business.updateTrainTask(task.value.id, {
      status: trainStatus,
      progress: status.progress || 0,
      currentEpoch: status.currentEpoch || 0,
      message: status.message,
      boxLoss: status.boxLoss,
      clsLoss: status.clsLoss,
      precision: status.precision,
      recall: status.recall,
      map50: status.map50,
      map5095: status.map5095,
      modelPath: status.modelPath,
      logs: status.logs,
      error: status.error,
    })
    if (status.status === 'completed') business.registerTrainedModel(task.value.id)
  } catch (error:any) {
    ElMessage.error(error?.message || '读取训练进度失败')
  } finally {
    refreshing.value = false
  }
}

const stopTraining = async () => {
  if (!task.value?.jobId) return
  await ElMessageBox.confirm('确认停止当前训练任务？', '停止训练', { type: 'warning' })
  await cancelTraining(task.value.jobId)
  business.updateTrainTask(task.value.id, { status: '失败', message: '训练已停止' })
  ElMessage.success('训练已停止')
}

let timer:number | undefined
onMounted(() => {
  refreshStatus()
  timer = window.setInterval(refreshStatus, 2500)
})
onUnmounted(() => window.clearInterval(timer))
</script>

<style scoped>
.training-page {
  padding: 22px;
  color: #1f2937;
}

.summary,
.progress-title,
.log-title,
.actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.summary {
  margin-top: 22px;
  border-bottom: 1px solid #d8dee9;
  padding-bottom: 14px;
}

.summary h2,
.log-title h3,
.result-section h3 {
  margin: 0;
}

.summary p {
  margin: 6px 0 0;
  color: #667085;
}

.progress-section,
.result-section,
.log-section {
  margin-top: 24px;
}

.progress-title {
  margin-bottom: 10px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(150px, 1fr));
  gap: 12px;
  margin-top: 22px;
}

.metric {
  border: 1px solid #d8dee9;
  border-radius: 6px;
  padding: 14px;
  background: #fff;
}

.metric span {
  display: block;
  color: #667085;
  font-size: 13px;
}

.metric strong {
  display: block;
  margin-top: 8px;
  font-size: 20px;
}

.log-title {
  margin-bottom: 8px;
}

pre {
  box-sizing: border-box;
  min-height: 220px;
  max-height: 360px;
  overflow: auto;
  margin: 0;
  padding: 14px;
  background: #111827;
  color: #d1d5db;
  white-space: pre-wrap;
  word-break: break-word;
  font-size: 12px;
}

.actions {
  justify-content: flex-end;
  gap: 12px;
  margin-top: 20px;
}

@media (max-width: 900px) {
  .metrics-grid {
    grid-template-columns: repeat(2, minmax(140px, 1fr));
  }
}
</style>
