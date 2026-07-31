<template>
  <div class="workspace-page">
    <section class="model-panel">
      <div class="panel-title">模型选择</div>
      <el-input v-model="modelKeyword" placeholder="搜索模型名称 / 目标类别" clearable size="small" />
      <el-segmented v-model="taskType" :options="taskTypeOptions" block />
      <el-select v-model="targetType" placeholder="识别类别" size="small">
        <el-option v-for="item in targetTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
      </el-select>

      <div class="model-list">
        <button
          v-for="model in filteredModels"
          :key="model.id"
          :class="selectedModel?.id === model.id ? 'model-card active' : 'model-card'"
          @click="selectedModel = model"
        >
          <span class="model-name">{{ model.name }}</span>
          <span class="model-meta">{{ model.taskType }} / {{ model.targetType }}</span>
          <span class="model-score">mAP {{ model.map }} · 已发布</span>
        </button>
      </div>
    </section>

    <section class="run-panel">
      <div class="toolbar">
        <div>
          <h2>智能识别标注工作区</h2>
          <p>上传图像或视频后，可同屏查看原始数据与标注结果。</p>
        </div>
        <div class="toolbar-actions">
          <el-upload :auto-upload="false" :show-file-list="false" accept=".jpg,.jpeg,.png,.mp4" :on-change="handleFileChange">
            <el-button type="primary">选择文件</el-button>
          </el-upload>
          <el-button :disabled="!sourceUrl || running" @click="runDetection">
            {{ running ? '识别中...' : '开始识别' }}
          </el-button>
          <el-dropdown :disabled="results.length === 0">
            <el-button>导出结果</el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="downloadResult('json')">JSON</el-dropdown-item>
                <el-dropdown-item @click="downloadResult('csv')">CSV</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <div class="preview-grid">
        <div class="preview-block">
          <div class="preview-head">
            <span>原始数据</span>
            <small>{{ fileName || '未选择文件' }}</small>
          </div>
          <div class="media-box">
            <img v-if="fileKind === 'image'" :src="sourceUrl" alt="原始图像" />
            <video v-else-if="fileKind === 'video'" :src="sourceUrl" controls />
            <div v-else class="empty-state">请选择 .jpg、.png 或 .mp4 文件</div>
          </div>
        </div>

        <div class="preview-block">
          <div class="preview-head">
            <span>识别标注结果</span>
            <small>{{ selectedModel?.name || '未选择模型' }}</small>
          </div>
          <div class="media-box result-box">
            <template v-if="sourceUrl">
              <img v-if="fileKind === 'image'" :src="sourceUrl" alt="识别结果" />
              <video v-else-if="fileKind === 'video'" :src="sourceUrl" controls muted />
              <div v-for="item in results" :key="item.id" class="detect-box" :style="boxStyle(item)">
                <span>{{ item.label }} {{ item.confidence }}%</span>
              </div>
            </template>
            <div v-else class="empty-state">识别后将在这里显示目标框、类别与置信度</div>
          </div>
        </div>
      </div>

      <div class="result-table">
        <div class="panel-title">识别结果</div>
        <el-table :data="results" height="210" empty-text="暂无识别结果">
          <el-table-column prop="label" label="目标类别" />
          <el-table-column prop="confidence" label="置信度" width="110" />
          <el-table-column prop="x" label="X" width="80" />
          <el-table-column prop="y" label="Y" width="80" />
          <el-table-column prop="width" label="宽度" width="90" />
          <el-table-column prop="height" label="高度" width="90" />
        </el-table>
      </div>

      <div class="result-table">
        <div class="history-head">
          <div class="panel-title">历史识别结果</div>
          <el-input v-model="historyKeyword" placeholder="搜索文件 / 模型 / 类别" clearable size="small" />
        </div>
        <el-table :data="filteredHistory" height="240" empty-text="暂无历史结果">
          <el-table-column prop="fileName" label="文件名" min-width="160" />
          <el-table-column prop="modelName" label="模型" min-width="180" />
          <el-table-column prop="label" label="目标类别" width="110" />
          <el-table-column prop="confidence" label="置信度" width="100" />
          <el-table-column prop="createTime" label="识别时间" min-width="160" />
          <el-table-column label="位置" width="160">
            <template #default="{ row }">
              X{{ row.x }} Y{{ row.y }} W{{ row.width }} H{{ row.height }}
            </template>
          </el-table-column>
        </el-table>
      </div>
    </section>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { UploadFile } from 'element-plus'
import allStore from '@/stores'
import type { ModelItem } from '@/stores/businessStore'

type FileKind = 'image' | 'video' | ''

interface DetectionResult {
  id: number
  label: string
  confidence: number
  x: number
  y: number
  width: number
  height: number
}

const taskType = ref('全部')
const targetType = ref('全部')
const modelKeyword = ref('')
const { business } = allStore()
const selectedModel = ref<ModelItem>()
const sourceUrl = ref('')
const fileName = ref('')
const fileKind = ref<FileKind>('')
const running = ref(false)
const results = ref<DetectionResult[]>([])
const historyKeyword = ref('')

const taskTypeOptions = ['全部', '图像识别', '视频识别']
const targetTypeOptions = [
  { label: '全部', value: '全部' },
  { label: '车辆', value: '车辆' },
  { label: '电线', value: '电线' },
  { label: '动物', value: '动物' },
]

selectedModel.value = business.publishedModels[0]

const filteredModels = computed(() => {
  const keyword = modelKeyword.value.trim()
  return business.publishedModels.filter((model) => {
    const matchTask = taskType.value === '全部' || model.taskType === taskType.value
    const matchTarget = targetType.value === '全部' || model.targetType === targetType.value
    const matchKeyword = !keyword || `${model.name}${model.targetType}`.includes(keyword)
    return matchTask && matchTarget && matchKeyword
  })
})

const filteredHistory = computed(() => {
  const keyword = historyKeyword.value.trim()
  if (!keyword) return business.detectionResults
  return business.detectionResults.filter((item) => `${item.fileName}${item.modelName}${item.label}`.includes(keyword))
})

const handleFileChange = (uploadFile: UploadFile) => {
  const raw = uploadFile.raw
  if (!raw) return

  if (sourceUrl.value) URL.revokeObjectURL(sourceUrl.value)

  fileName.value = raw.name
  sourceUrl.value = URL.createObjectURL(raw)
  fileKind.value = raw.type.startsWith('video') ? 'video' : 'image'
  results.value = []
}

const runDetection = () => {
  if (!selectedModel.value) {
    ElMessage.warning('请先选择模型')
    return
  }
  if (!sourceUrl.value) {
    ElMessage.warning('请先选择文件')
    return
  }

  running.value = true
  window.setTimeout(() => {
    const labels = selectedModel.value?.targetType === '车辆'
      ? ['car', 'truck']
      : selectedModel.value?.targetType === '电线'
        ? ['wire', 'insulator']
        : ['cat', 'dog']

    results.value = [
      { id: 1, label: labels[0], confidence: 94, x: 18, y: 22, width: 34, height: 28 },
      { id: 2, label: labels[1], confidence: 87, x: 56, y: 48, width: 25, height: 23 },
    ]
    business.addDetectionResults(results.value.map((item) => ({
      fileName: fileName.value,
      modelName: selectedModel.value?.name || '',
      label: item.label,
      confidence: item.confidence,
      x: item.x,
      y: item.y,
      width: item.width,
      height: item.height,
    })))
    running.value = false
    ElMessage.success('识别完成，结果已生成')
  }, 900)
}

const boxStyle = (item: DetectionResult) => ({
  left: `${item.x}%`,
  top: `${item.y}%`,
  width: `${item.width}%`,
  height: `${item.height}%`,
})

const downloadResult = (type: 'json' | 'csv') => {
  const data = results.value.map((item) => ({
    fileName: fileName.value,
    modelName: selectedModel.value?.name,
    ...item,
  }))
  const content = type === 'json'
    ? JSON.stringify(data, null, 2)
    : [
        'fileName,modelName,label,confidence,x,y,width,height',
        ...data.map((item) => `${item.fileName},${item.modelName},${item.label},${item.confidence},${item.x},${item.y},${item.width},${item.height}`),
      ].join('\n')

  const blob = new Blob([content], { type: type === 'json' ? 'application/json' : 'text/csv' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `detection-result.${type}`
  link.click()
  URL.revokeObjectURL(url)
}
</script>

<style lang="scss" scoped>
.workspace-page {
  display: grid;
  grid-template-columns: 280px 1fr;
  height: 92vh;
  background: #f5f7fb;
  color: #1f2937;
}

.model-panel {
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding: 18px;
  border-right: 1px solid #d8dee9;
  background: #ffffff;
}

.panel-title {
  font-size: 16px;
  font-weight: 700;
}

.model-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  overflow: auto;
}

.model-card {
  display: flex;
  flex-direction: column;
  gap: 7px;
  padding: 12px;
  text-align: left;
  border: 1px solid #d8dee9;
  border-radius: 8px;
  background: #ffffff;
  cursor: pointer;
}

.model-card.active {
  border-color: #2563eb;
  background: #eef5ff;
}

.model-name {
  font-weight: 700;
}

.model-meta,
.model-score,
.preview-head small,
.toolbar p {
  color: #667085;
  font-size: 12px;
}

.run-panel {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 18px;
  overflow: auto;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.toolbar h2 {
  margin: 0 0 6px;
  font-size: 22px;
}

.toolbar p {
  margin: 0;
}

.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.preview-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.preview-block,
.result-table {
  border: 1px solid #d8dee9;
  border-radius: 8px;
  background: #ffffff;
}

.preview-head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 14px;
  border-bottom: 1px solid #e5e7eb;
  font-weight: 700;
}

.media-box {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 360px;
  overflow: hidden;
  background: #111827;
}

.media-box img,
.media-box video {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.empty-state {
  color: #98a2b3;
}

.detect-box {
  position: absolute;
  border: 2px solid #22c55e;
  box-shadow: 0 0 0 1px rgba(17, 24, 39, 0.45);
}

.detect-box span {
  position: absolute;
  left: -2px;
  top: -26px;
  padding: 3px 7px;
  border-radius: 4px;
  background: #22c55e;
  color: #ffffff;
  font-size: 12px;
  white-space: nowrap;
}

.result-table {
  padding: 14px;
}

.result-table .panel-title {
  margin-bottom: 12px;
}

.history-head {
  display: grid;
  grid-template-columns: 160px minmax(220px, 360px);
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 12px;
}

.history-head .panel-title {
  margin-bottom: 0;
}

@media (max-width: 1100px) {
  .workspace-page {
    grid-template-columns: 1fr;
    height: auto;
  }

  .preview-grid {
    grid-template-columns: 1fr;
  }

  .toolbar {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
