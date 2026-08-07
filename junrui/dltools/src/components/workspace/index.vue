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
          <p v-if="isAutoMode" style="color: #22c55e; font-weight: 600;">
            📷 自动检测模式：相机实时识别中
          </p>
        </div>
        <div class="toolbar-actions">
          <el-upload
            :auto-upload="false"
            :show-file-list="false"
            accept=".jpg,.jpeg,.png,.mp4"
            :on-change="handleFileChange"
            :disabled="isAutoMode"
          >
            <el-button type="primary">选择文件</el-button>
          </el-upload>
          <el-button :disabled="!sourceUrl || running || isAutoMode" @click="runDetection">
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
          <el-button size="small" type="success" @click="toggleAutoMode">
            {{ isAutoMode ? '停止自动检测' : '启动自动检测' }}
          </el-button>
        </div>
      </div>

      <div class="preview-grid">
        <!-- ========== 左侧：原始数据（显示原图，无框） ========== -->
        <div class="preview-block">
          <div class="preview-head">
            <span>原始数据</span>
            <small>{{ fileName || (isAutoMode ? '实时相机图像' : '未选择文件') }}</small>
          </div>
          <div class="media-box">
            <!-- 自动检测模式：显示原图（无框） -->
            <img
              v-if="isAutoMode && originalImageUrl"
              :src="originalImageUrl"
              alt="原始图像"
            />
            <!-- 手动模式：显示用户上传的图片 -->
            <img
              v-else-if="fileKind === 'image'"
              :src="sourceUrl"
              alt="原始图像"
            />
            <video
              v-else-if="fileKind === 'video'"
              :src="sourceUrl"
              controls
            />
            <div v-else class="empty-state">
              {{ isAutoMode ? '等待相机新图片...' : '请选择 .jpg、.png 或 .mp4 文件' }}
            </div>
          </div>
        </div>

        <!-- ========== 右侧：识别标注结果（显示带框图片） ========== -->
        <div class="preview-block">
          <div class="preview-head">
            <span>识别标注结果</span>
            <small>{{ selectedModel?.name || '未选择模型' }}</small>
          </div>
          <div class="media-box result-box">
            <template v-if="isAutoMode && realTimeImageUrl">
              <img :src="realTimeImageUrl" alt="实时识别结果" />
              <div
                v-for="item in results"
                :key="`auto-${item.id}`"
                class="detect-box"
                :style="boxStyle(item)"
              >
                <span>{{ item.label }} {{ item.confidence }}%</span>
              </div>
            </template>
            <template v-else-if="sourceUrl">
              <img v-if="fileKind === 'image'" :src="sourceUrl" alt="识别结果" />
              <video v-else-if="fileKind === 'video'" :src="sourceUrl" controls muted />
              <div
                v-for="item in results"
                :key="item.id"
                class="detect-box"
                :style="boxStyle(item)"
              >
                <span>{{ item.label }} {{ item.confidence }}%</span>
              </div>
            </template>
            <div v-else class="empty-state">
              {{ isAutoMode ? '等待检测结果...' : '识别后将在这里显示目标框' }}
            </div>
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
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage } from 'element-plus'
import type { UploadFile } from 'element-plus'
import allStore from '@/stores'
import type { ModelItem } from '@/stores/businessStore'
import { runYoloDetection } from '@/api/detection'
import axios from 'axios'

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
const sourceFile = ref<File>()
const fileName = ref('')
const fileKind = ref<FileKind>('')
const running = ref(false)
const results = ref<DetectionResult[]>([])
const historyKeyword = ref('')

// ========== 实时检测模式 ==========
const isAutoMode = ref(false)
const realTimeImageUrl = ref('')
const originalImageUrl = ref('')
const pollingTimer = ref<number | null>(null)
const isPolling = ref(false)
const lastImage = ref('')

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
  return business.detectionResults.filter((item) =>
    `${item.fileName}${item.modelName}${item.label}`.includes(keyword)
  )
})

// ========== 拉取最新实时检测结果 ==========
const fetchLatest = async () => {
  if (!isAutoMode.value || isPolling.value) return
  isPolling.value = true
  try {
    const res = await axios.get('/api/Detection/latest')
    console.log('📡 fetchLatest 响应:', res.data)

    if (res.data?.code === 200 || res.data?.code === 20000) {
      const data = res.data.data
      console.log('📡 data:', data)

      if (data?.imageUrl) {
        // 直接更新，不判断是否相同
        console.log('🖼️ 更新图片:', data.imageUrl)

        // 右侧：带框图片
        realTimeImageUrl.value = data.imageUrl

        // 左侧：原图（优先使用 originalImage，否则尝试构造）
        if (data.originalImage) {
          originalImageUrl.value = data.originalImage
        } else {
          originalImageUrl.value = data.imageUrl.replace('/det_', '/orig_')
        }
        console.log('🖼️ 原图 URL:', originalImageUrl.value)
        console.log('🖼️ 带框图片 URL:', realTimeImageUrl.value)

        fileName.value = '相机实时拍摄'

        // 解析检测结果
        if (data.jsonData) {
          try {
            const json = JSON.parse(data.jsonData)
            console.log('📄 解析后的 JSON:', json)
            const list = json.detections || []
            results.value = list.map((it: any, i: number) => ({
              id: i,
              label: it.class || it.label,
              confidence: Math.round(it.confidence * 100),
              x: it.bbox ? Math.round(it.bbox[0]) : it.x,
              y: it.bbox ? Math.round(it.bbox[1]) : it.y,
              width: it.bbox ? Math.round(it.bbox[2] - it.bbox[0]) : it.width,
              height: it.bbox ? Math.round(it.bbox[3] - it.bbox[1]) : it.height,
            }))
            console.log('✅ 更新结果:', results.value.length, '个目标')
          } catch (e) {
            console.error('❌ 解析 JSON 失败:', e)
          }
        }
      } else {
        console.log('⚠️ data.imageUrl 为空')
      }
    }
  } catch (e) {
    console.error('❌ fetchLatest 失败:', e)
  } finally {
    isPolling.value = false
  }
}

// ========== 启动/停止轮询 ==========
const startAutoDetect = () => {
  clearAutoTimer()
  fetchLatest()
  pollingTimer.value = window.setInterval(fetchLatest, 2000)
  console.log('📷 开始轮询')
}

const clearAutoTimer = () => {
  if (pollingTimer.value) {
    clearInterval(pollingTimer.value)
    pollingTimer.value = null
    console.log('📷 停止轮询')
  }
}

const toggleAutoMode = () => {
  isAutoMode.value = !isAutoMode.value
  if (isAutoMode.value) {
    startAutoDetect()
    ElMessage.success('已启动相机实时自动检测')
  } else {
    clearAutoTimer()
    realTimeImageUrl.value = ''
    originalImageUrl.value = ''
    results.value = []
    ElMessage.info('已停止自动检测')
  }
}

// ========== 原有手动上传逻辑 ==========
const handleFileChange = (uploadFile: UploadFile) => {
  const raw = uploadFile.raw
  if (!raw) return
  if (sourceUrl.value) URL.revokeObjectURL(sourceUrl.value)
  fileName.value = raw.name
  sourceFile.value = raw
  sourceUrl.value = URL.createObjectURL(raw)
  fileKind.value = raw.type.startsWith('video') ? 'video' : 'image'
  results.value = []
  if (isAutoMode.value) {
    clearAutoTimer()
    isAutoMode.value = false
  }
}

const runDetection = async () => {
  if (!selectedModel.value) {
    ElMessage.warning('请先选择模型')
    return
  }
  if (!sourceUrl.value || !sourceFile.value) {
    ElMessage.warning('请先选择文件')
    return
  }
  if (fileKind.value !== 'image') {
    ElMessage.warning('当前仅支持图片识别')
    return
  }

  running.value = true
  try {
    const res = await runYoloDetection({ file: sourceFile.value, conf: 0.25 })
    results.value = res
    business.addDetectionResults(res.map(item => ({
      fileName: fileName.value,
      modelName: selectedModel.value?.name || '',
      label: item.label,
      confidence: item.confidence,
      x: item.x,
      y: item.y,
      width: item.width,
      height: item.height,
    })))
    ElMessage.success(`识别完成，检测到 ${res.length} 个目标`)
  } catch (error: any) {
    ElMessage.error(error.message || '识别失败')
  } finally {
    running.value = false
  }
}

const boxStyle = (item: DetectionResult) => ({
  left: `${item.x}%`,
  top: `${item.y}%`,
  width: `${item.width}%`,
  height: `${item.height}%`,
})

const downloadResult = (type: 'json' | 'csv') => {
  const data = results.value.map(item => ({
    fileName: fileName.value,
    modelName: selectedModel.value?.name,
    ...item,
  }))
  const content = type === 'json'
    ? JSON.stringify(data, null, 2)
    : [
        'fileName,modelName,label,confidence,x,y,width,height',
        ...data.map(it => `${it.fileName},${it.modelName},${it.label},${it.confidence},${it.x},${it.y},${it.width},${it.height}`),
      ].join('\n')
  const blob = new Blob([content], { type: type === 'json' ? 'application/json' : 'text/csv' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `detection-result.${type}`
  a.click()
  URL.revokeObjectURL(url)
}

// ========== 生命周期钩子 ==========
onMounted(() => {

})

onBeforeUnmount(() => {
  clearAutoTimer()
})
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
  background: #fff;
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
  background: #fff;
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
  flex-wrap: wrap;
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
  background: #fff;
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
  color: #fff;
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