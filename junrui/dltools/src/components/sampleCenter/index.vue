<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索样本名 / 项目名" :prefix-icon="Search" clearable />
      <el-select v-model="typeFilter" placeholder="样本类型">
        <el-option label="全部" value="全部" />
        <el-option label="图像" value="图像" />
        <el-option label="结构化数据" value="结构化数据" />
      </el-select>
      <el-button type="primary" @click="router.push('/sampleCenter/toUpload')">导入样本</el-button>
    </div>

    <el-alert class="hint" type="info" show-icon :closable="false" title="已完成的标注任务可以在“标注”页面一键导入为样本集，训练任务会直接读取这里的样本。" />

    <el-table :data="filteredSamples" height="calc(100vh - 300px)" empty-text="暂无样本">
      <el-table-column prop="id" label="样本ID" width="100" />
      <el-table-column prop="name" label="样本名称" min-width="180" />
      <el-table-column prop="type" label="样本类型" width="120" />
      <el-table-column prop="count" label="样本量" width="120" />
      <el-table-column prop="projectName" label="所属项目" min-width="130" />
      <el-table-column prop="createTime" label="录入时间" min-width="160" />
      <el-table-column prop="creator" label="录入人" width="110" />
      <el-table-column label="操作" width="360">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">查看</el-button>
          <el-button link type="primary" @click="openSamplePreview(row)">查看样本</el-button>
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="primary" @click="createTrainTask(row)">创建训练</el-button>
          <el-button link type="danger" @click="deleteSample(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="样本集详情" width="600px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="样本名称">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="样本类型">{{ detailTarget.type }}</el-descriptions-item>
        <el-descriptions-item label="样本数量">{{ detailTarget.count }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="来源任务">{{ sourceTaskName(detailTarget.sourceTaskId) }}</el-descriptions-item>
        <el-descriptions-item label="录入时间">{{ detailTarget.createTime }}</el-descriptions-item>
        <el-descriptions-item label="说明">{{ detailTarget.description || '暂无说明' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="samplePreviewVisible" title="样本图片" width="820px">
      <div class="preview-meta">
        <span>{{ previewTarget?.name }}</span>
        <span>第 {{ previewImages.length ? previewIndex + 1 : 0 }} / {{ previewImages.length }} 张</span>
        <span class="preview-name">{{ currentPreviewImage?.name || '' }}</span>
        <el-tag :type="annotationCount > 0 ? 'success' : 'info'">
          {{ annotationCount > 0 ? `已叠加 ${annotationCount} 个标注` : annotationStatus }}
        </el-tag>
      </div>
      <div v-loading="previewLoading" class="preview-box">
        <el-button class="preview-nav left" circle :disabled="previewImages.length <= 1" @click="changePreview(-1)">‹</el-button>
        <img
          v-if="renderedPreviewUrl && !previewError"
          :key="renderedPreviewUrl"
          :src="renderedPreviewUrl"
          alt="sample preview"
          @error="previewError = true"
        />
        <el-empty v-else-if="previewError" description="该图片无法读取" />
        <el-empty v-else description="该样本集暂无可预览图片" />
        <el-button class="preview-nav right" circle :disabled="previewImages.length <= 1" @click="changePreview(1)">›</el-button>
      </div>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑样本集" width="600px">
      <el-form label-width="90px">
        <el-form-item label="样本名称">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="样本类型">
          <el-select v-model="editForm.type">
            <el-option label="图像" value="图像" />
            <el-option label="结构化数据" value="结构化数据" />
          </el-select>
        </el-form-item>
        <el-form-item label="样本数量">
          <el-input-number v-model="editForm.count" :min="1" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="editForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveSample">保存</el-button>
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
import type { SampleSet } from '@/stores/businessStore'
import { listPreviewImages, previewImageUrl } from '@/api/fileManager'
import { getImageAnnotation } from '@/api/imageLabel'
import { fabric } from 'fabric'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const typeFilter = ref<'全部' | '图像' | '结构化数据'>('全部')
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<SampleSet>()
const editId = ref<number>()
const samplePreviewVisible = ref(false)
const previewTarget = ref<SampleSet>()
const previewImages = ref<Array<{ name: string; url: string; backendId: string; imageIndex: number }>>([])
const previewIndex = ref(0)
const previewError = ref(false)
const previewLoading = ref(false)
const renderedPreviewUrl = ref('')
const annotationCount = ref(0)
const annotationStatus = ref('未标注')
let previewRenderToken = 0
const editForm = ref({
  name: '',
  type: '图像' as SampleSet['type'],
  count: 1,
  description: '',
})

const filteredSamples = computed(() => {
  const text = keyword.value.trim()
  return business.samples.filter((item) => {
    const matchType = typeFilter.value === '全部' || item.type === typeFilter.value
    const matchText = !text || `${item.name}${item.projectName}`.includes(text)
    return matchType && matchText
  })
})

const sourceTaskName = (id?: number) => {
  if (!id) return '手动导入'
  return business.labelTasks.find((item) => item.id === id)?.name || `任务${id}`
}

const currentPreviewImage = computed(() => previewImages.value[previewIndex.value])

const openSamplePreview = async (sample: SampleSet) => {
  previewTarget.value = sample
  previewImages.value = []
  previewIndex.value = 0
  previewError.value = false
  samplePreviewVisible.value = true

  const task = sample.sourceTaskId
    ? business.labelTasks.find((item) => item.id === sample.sourceTaskId)
    : undefined
  const fileIds = sample.fileIds?.length ? sample.fileIds : task?.fileIds || []
  const files = fileIds
    .map((id) => business.files.find((file) => file.id === id))
    .filter(Boolean) as typeof business.files

  for (const file of files) {
    const backendId = file.backendId || String(file.id)
    try {
      const names = await listPreviewImages(backendId)
      if (names.length) {
        names.forEach((name, imageIndex) => {
          previewImages.value.push({
            name,
            url: previewImageUrl(backendId, imageIndex),
            backendId,
            imageIndex,
          })
        })
        continue
      }
    } catch (error) {
      console.warn('样本图片列表读取失败。', error)
    }
    if (file.url) {
      previewImages.value.push({ name: file.name, url: file.url, backendId, imageIndex: 0 })
    }
  }
  await renderCurrentPreview()
}

const loadFabricImage = (url: string) => new Promise<fabric.Image>((resolve, reject) => {
  fabric.Image.fromURL(url, (image) => {
    if (image) resolve(image)
    else reject(new Error('图片加载失败'))
  })
})

const enlivenFabricObjects = (objects: any[]) => new Promise<any[]>((resolve) => {
  fabric.util.enlivenObjects(objects, (result:any[]) => resolve(result), '')
})

const renderCurrentPreview = async () => {
  const image = currentPreviewImage.value
  const taskId = previewTarget.value?.sourceTaskId
  const token = ++previewRenderToken
  previewError.value = false
  annotationCount.value = 0
  annotationStatus.value = '未标注'
  renderedPreviewUrl.value = image?.url || ''
  if (!image || !taskId) return

  previewLoading.value = true
  try {
    const record = await getImageAnnotation(taskId, image.backendId, image.imageIndex)
    if (!record?.labelData) return
    const saved = typeof record.labelData === 'string' ? JSON.parse(record.labelData) : record.labelData
    const annotations = Array.isArray(saved) ? saved : saved.annotations || []
    if (!annotations.length) {
      annotationStatus.value = '已保存，无标注框'
      return
    }

    const background = await loadFabricImage(image.url)
    const maxRight = Math.max(...annotations.map((item:any) => {
      const object = item.fabricObj || {}
      return (object.left || 0) + (object.width || 0) * (object.scaleX || 1)
    }), background.width || 1)
    const maxBottom = Math.max(...annotations.map((item:any) => {
      const object = item.fabricObj || {}
      return (object.top || 0) + (object.height || 0) * (object.scaleY || 1)
    }), background.height || 1)
    // Legacy annotations stored absolute Fabric coordinates but no canvas size.
    // Recreate the labeling page's 70vw x 55.2vh canvas so its centered image
    // and shapes share the same coordinate system.
    const legacyCanvasWidth = Math.round(window.innerWidth * 0.7)
    const legacyCanvasHeight = Math.round(window.innerHeight * 0.92 * 0.6)
    const canvasWidth = Math.ceil(saved.canvas?.width || Math.max(legacyCanvasWidth, maxRight))
    const canvasHeight = Math.ceil(saved.canvas?.height || Math.max(legacyCanvasHeight, maxBottom))
    const element = document.createElement('canvas')
    const previewCanvas = new fabric.StaticCanvas(element, {
      width: canvasWidth,
      height: canvasHeight,
      renderOnAddRemove: false,
    })

    if (saved.image?.width && saved.image?.height) {
      background.set({
        left: saved.image.left || 0,
        top: saved.image.top || 0,
        scaleX: saved.image.width / (background.width || 1),
        scaleY: saved.image.height / (background.height || 1),
      })
    } else if ((background.width || 0) > canvasWidth || (background.height || 0) > canvasHeight) {
      const scale = Math.min(canvasWidth / (background.width || 1), canvasHeight / (background.height || 1))
      background.scale(scale)
    } else {
      background.set({
        left: (canvasWidth - (background.width || 0)) / 2,
        top: (canvasHeight - (background.height || 0)) / 2,
      })
    }

    previewCanvas.setBackgroundImage(background, () => undefined)
    const objects = await enlivenFabricObjects(annotations.map((item:any) => item.fabricObj))
    objects.forEach((object:any) => {
      object.set({ selectable: false, evented: false })
      previewCanvas.add(object)
    })
    previewCanvas.renderAll()
    const dataUrl = previewCanvas.toDataURL({ format: 'png', multiplier: 1 })
    previewCanvas.dispose()
    if (token !== previewRenderToken) return
    renderedPreviewUrl.value = dataUrl
    annotationCount.value = annotations.length
    annotationStatus.value = '已标注'
  } catch (error) {
    console.warn('标注预览生成失败，将显示原图。', error)
    annotationStatus.value = '标注加载失败，显示原图'
  } finally {
    if (token === previewRenderToken) previewLoading.value = false
  }
}

const changePreview = async (step: number) => {
  if (previewImages.value.length <= 1) return
  previewIndex.value = (previewIndex.value + step + previewImages.value.length) % previewImages.value.length
  previewError.value = false
  await renderCurrentPreview()
}

const openDetail = (sample: SampleSet) => {
  detailTarget.value = sample
  detailVisible.value = true
}

const openEdit = (sample: SampleSet) => {
  editId.value = sample.id
  editForm.value = {
    name: sample.name,
    type: sample.type,
    count: sample.count,
    description: sample.description,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveSample = () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写样本名称')
    return
  }
  business.updateSample(editId.value, {
    name: editForm.value.name.trim(),
    type: editForm.value.type,
    count: editForm.value.count,
    description: editForm.value.description,
  })
  editVisible.value = false
  ElMessage.success('样本集已保存')
}

const createTrainTask = (sample: SampleSet) => {
  router.push({ path: '/taskCenter/toTrain', query: { sampleId: sample.id } })
}

const deleteSample = (id: number) => {
  ElMessageBox.confirm('确认删除该样本集？', '删除样本集', { type: 'warning' })
    .then(() => {
      business.deleteSample(id)
      ElMessage.success('样本已删除')
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
  grid-template-columns: minmax(260px, 1fr) 180px 120px;
  gap: 14px;
  margin-bottom: 14px;
}

.hint {
  margin-bottom: 14px;
}

.preview-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  margin-bottom: 10px;
  color: #344054;
}

.preview-name {
  color: #667085;
  word-break: break-all;
}

.preview-box {
  position: relative;
  min-height: 420px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: #111827;
}

.preview-box img {
  max-width: 100%;
  max-height: 62vh;
  object-fit: contain;
}

.preview-nav {
  position: absolute;
  top: 50%;
  z-index: 2;
  transform: translateY(-50%);
}

.preview-nav.left {
  left: 14px;
}

.preview-nav.right {
  right: 14px;
}
</style>
