import { defineStore } from 'pinia'

export type DataType = '图像' | '视频' | '其他'
export type TaskStatus = '待标注' | '标注中' | '待审核' | '已完成' | '审核未通过'
export type TrainStatus = '训练中' | '已完成' | '失败'

export interface ManagedFile {
  id: number
  name: string
  type: DataType
  projectId: number
  projectName: string
  creator: string
  uploadTime: string
  source: string
  url?: string
}

export interface LabelTask {
  id: number
  name: string
  projectId: number
  projectName: string
  fileIds: number[]
  labels: string[]
  deadline: string
  status: TaskStatus
  progress: number
  description: string
}

export interface SampleSet {
  id: number
  name: string
  type: '图像' | '结构化数据'
  projectId: number
  projectName: string
  count: number
  sourceTaskId?: number
  creator: string
  createTime: string
  description: string
}

export interface ModelItem {
  id: number
  name: string
  taskType: '图像识别' | '视频识别'
  targetType: '车辆' | '电线' | '动物'
  projectId: number
  projectName: string
  status: '已导入' | '已发布'
  source: '外部导入' | '训练生成'
  map: string
  description: string
}

export interface TrainTask {
  id: number
  name: string
  projectId: number
  projectName: string
  sampleId: number
  sampleName: string
  modelId: number
  modelName: string
  learningRate: number
  epoch: number
  batchSize: number
  progress: number
  status: TrainStatus
  description: string
}

export interface DetectionResult {
  id: number
  fileName: string
  modelName: string
  label: string
  confidence: number
  x: number
  y: number
  width: number
  height: number
  createTime: string
}

const nowText = () => new Date().toLocaleString('zh-CN', { hour12: false })

export const useBusinessStore = defineStore('business', {
  state: () => ({
    nextId: 100,
    files: [
      { id: 1, name: '巡检图片-001.jpg', type: '图像', projectId: 2, projectName: 'Node 1.1', creator: '本地用户', uploadTime: '2026/7/29 09:20:00', source: '本地上传' },
      { id: 2, name: '道路车辆.mp4', type: '视频', projectId: 3, projectName: 'Node 1.2', creator: '本地用户', uploadTime: '2026/7/29 09:28:00', source: '本地上传' },
      { id: 3, name: '样本包.zip', type: '其他', projectId: 6, projectName: 'Node 2.1', creator: '本地用户', uploadTime: '2026/7/29 09:35:00', source: '本地上传' },
    ] as ManagedFile[],
    labelTasks: [
      { id: 11, name: '电线缺陷标注任务', projectId: 2, projectName: 'Node 1.1', fileIds: [1], labels: ['wire', 'insulator'], deadline: '2026-08-05', status: '已完成', progress: 100, description: '用于电线巡检图像训练。' },
      { id: 12, name: '车辆视频抽帧标注', projectId: 3, projectName: 'Node 1.2', fileIds: [2], labels: ['car', 'truck'], deadline: '2026-08-10', status: '待审核', progress: 80, description: '用于车辆检测模型。' },
    ] as LabelTask[],
    samples: [
      { id: 21, name: '电线图像样本集', type: '图像', projectId: 2, projectName: 'Node 1.1', count: 240, sourceTaskId: 11, creator: '本地用户', createTime: '2026/7/29 10:00:00', description: '由已完成标注任务导入。' },
    ] as SampleSet[],
    models: [
      { id: 31, name: 'YOLOv8-车辆检测模型', taskType: '视频识别', targetType: '车辆', projectId: 3, projectName: 'Node 1.2', status: '已发布', source: '训练生成', map: '0.91', description: '用于道路车辆视频识别。' },
      { id: 32, name: 'YOLOv5-电线巡检模型', taskType: '图像识别', targetType: '电线', projectId: 2, projectName: 'Node 1.1', status: '已发布', source: '训练生成', map: '0.88', description: '用于电线和绝缘子检测。' },
      { id: 33, name: 'YOLOv10-动物识别模型', taskType: '图像识别', targetType: '动物', projectId: 6, projectName: 'Node 2.1', status: '已导入', source: '外部导入', map: '0.86', description: '外部导入模型。' },
    ] as ModelItem[],
    trainTasks: [
      { id: 41, name: '电线模型训练-第一版', projectId: 2, projectName: 'Node 1.1', sampleId: 21, sampleName: '电线图像样本集', modelId: 32, modelName: 'YOLOv5-电线巡检模型', learningRate: 0.01, epoch: 100, batchSize: 16, progress: 100, status: '已完成', description: '基础训练任务。' },
    ] as TrainTask[],
    detectionResults: [] as DetectionResult[],
  }),
  getters: {
    publishedModels: (state) => state.models.filter((item) => item.status === '已发布'),
    completedLabelTasks: (state) => state.labelTasks.filter((item) => item.status === '已完成'),
  },
  actions: {
    createId() {
      this.nextId += 1
      return this.nextId
    },
    addFile(payload: Omit<ManagedFile, 'id' | 'uploadTime' | 'creator' | 'source'>) {
      this.files.unshift({ ...payload, id: this.createId(), uploadTime: nowText(), creator: '本地用户', source: '本地上传' })
    },
    setFiles(files: ManagedFile[]) {
      this.files = files
    },
    deleteFile(id: number) {
      this.files = this.files.filter((item) => item.id !== id)
    },
    updateFile(id: number, payload: Partial<Omit<ManagedFile, 'id'>>) {
      const file = this.files.find((item) => item.id === id)
      if (file) Object.assign(file, payload)
    },
    addLabelTask(payload: Omit<LabelTask, 'id' | 'status' | 'progress'>) {
      this.labelTasks.unshift({ ...payload, id: this.createId(), status: '待标注', progress: 0 })
    },
    updateLabelTask(id: number, payload: Partial<Omit<LabelTask, 'id'>>) {
      const task = this.labelTasks.find((item) => item.id === id)
      if (task) Object.assign(task, payload)
    },
    deleteLabelTask(id: number) {
      this.labelTasks = this.labelTasks.filter((item) => item.id !== id)
    },
    updateLabelTaskStatus(id: number, status: TaskStatus) {
      const task = this.labelTasks.find((item) => item.id === id)
      if (!task) return
      task.status = status
      task.progress = status === '已完成' ? 100 : status === '待审核' ? 80 : status === '标注中' ? 50 : task.progress
    },
    importSampleFromLabelTask(taskId: number) {
      const task = this.labelTasks.find((item) => item.id === taskId)
      if (!task || this.samples.some((item) => item.sourceTaskId === taskId)) return
      this.samples.unshift({
        id: this.createId(),
        name: `${task.name}-样本集`,
        type: '图像',
        projectId: task.projectId,
        projectName: task.projectName,
        count: Math.max(task.fileIds.length * 120, 120),
        sourceTaskId: task.id,
        creator: '本地用户',
        createTime: nowText(),
        description: '由审核通过的标注任务导入。',
      })
    },
    addSample(payload: Omit<SampleSet, 'id' | 'creator' | 'createTime'>) {
      this.samples.unshift({ ...payload, id: this.createId(), creator: '本地用户', createTime: nowText() })
    },
    deleteSample(id: number) {
      this.samples = this.samples.filter((item) => item.id !== id)
    },
    updateSample(id: number, payload: Partial<Omit<SampleSet, 'id'>>) {
      const sample = this.samples.find((item) => item.id === id)
      if (sample) Object.assign(sample, payload)
    },
    addModel(payload: Omit<ModelItem, 'id' | 'status' | 'source' | 'map'>) {
      this.models.unshift({ ...payload, id: this.createId(), status: '已导入', source: '外部导入', map: '待评估' })
    },
    updateModel(id: number, payload: Partial<Omit<ModelItem, 'id'>>) {
      const model = this.models.find((item) => item.id === id)
      if (model) Object.assign(model, payload)
    },
    deleteModel(id: number) {
      this.models = this.models.filter((item) => item.id !== id)
    },
    publishModel(id: number) {
      const model = this.models.find((item) => item.id === id)
      if (model) model.status = '已发布'
    },
    addTrainTask(payload: Omit<TrainTask, 'id' | 'progress' | 'status'>) {
      this.trainTasks.unshift({ ...payload, id: this.createId(), progress: 15, status: '训练中' })
    },
    updateTrainTask(id: number, payload: Partial<Omit<TrainTask, 'id'>>) {
      const task = this.trainTasks.find((item) => item.id === id)
      if (task) Object.assign(task, payload)
    },
    deleteTrainTask(id: number) {
      this.trainTasks = this.trainTasks.filter((item) => item.id !== id)
    },
    finishTrainTask(id: number) {
      const task = this.trainTasks.find((item) => item.id === id)
      if (!task) return
      task.status = '已完成'
      task.progress = 100
      if (!this.models.some((item) => item.name === `${task.name}-发布模型`)) {
        this.models.unshift({
          id: this.createId(),
          name: `${task.name}-发布模型`,
          taskType: '图像识别',
          targetType: '电线',
          projectId: task.projectId,
          projectName: task.projectName,
          status: '已发布',
          source: '训练生成',
          map: '0.90',
          description: `由训练任务 ${task.name} 生成。`,
        })
      }
    },
    addDetectionResults(results: Omit<DetectionResult, 'id' | 'createTime'>[]) {
      results.forEach((item) => {
        this.detectionResults.unshift({ ...item, id: this.createId(), createTime: nowText() })
      })
    },
  },
})
