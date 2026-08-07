import axios from 'axios'
import request from '@/utils/request'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

export interface TrainingStatus {
  jobId: string
  status: 'preparing' | 'running' | 'completed' | 'failed' | 'cancelled'
  progress: number
  currentEpoch: number
  totalEpochs: number
  sampleCount: number
  message?: string
  boxLoss?: number
  clsLoss?: number
  dflLoss?: number
  precision?: number
  recall?: number
  map50?: number
  map5095?: number
  modelPath?: string
  resultDir?: string
  classNames?: string[]
  logs?: string
  error?: string
  processAlive?: boolean
}

const trainingError = (error: unknown, fallback: string) => {
  if (!axios.isAxiosError(error)) return error instanceof Error ? error : new Error(fallback)
  const responseMessage = error.response?.data?.message || error.response?.data?.error
  if (responseMessage) return new Error(String(responseMessage))
  if (error.response?.status === 500) {
    return new Error('训练后端未正常运行，请启动 AIModuleServer 后重试')
  }
  return new Error(error.message || fallback)
}

export const startTraining = async (payload: {
  labelTaskId: number
  taskName: string
  epochs: number
  batchSize: number
  learningRate: number
  modelPath?: string
}) => {
  try {
    const response = await request.post<ApiResult<{ jobId: string; sampleCount: number }>>(
      '/AIModuleServer/Training/start',
      payload,
      { timeout: 120000 },
    )
    if (response.data.code !== 20000) throw new Error(response.data.message || '启动训练失败')
    return response.data.data
  } catch (error) {
    throw trainingError(error, '启动训练失败')
  }
}

export const getTrainingStatus = async (jobId: string) => {
  try {
    const response = await request.get<ApiResult<TrainingStatus>>(`/AIModuleServer/Training/status/${jobId}`)
    if (response.data.code !== 20000) throw new Error(response.data.message || '读取训练进度失败')
    return response.data.data
  } catch (error) {
    throw trainingError(error, '读取训练进度失败')
  }
}

export const cancelTraining = async (jobId: string) => {
  try {
    const response = await request.post<ApiResult<string>>(`/AIModuleServer/Training/cancel/${jobId}`)
    if (response.data.code !== 20000) throw new Error(response.data.message || '停止训练失败')
  } catch (error) {
    throw trainingError(error, '停止训练失败')
  }
}
