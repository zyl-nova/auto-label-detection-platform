import request from '@/utils/request'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

export interface DetectionBox {
  id: number
  label: string
  confidence: number
  x: number
  y: number
  width: number
  height: number
}

interface DetectionPayload {
  results: DetectionBox[]
}

export interface CameraDetectionState {
  running: boolean
  watchPath: string
  resultsPath: string
}

export interface CameraDetectionResult {
  imageUrl: string
  originalImage?: string
  jsonData?: string
  timestamp: number
}

export const runYoloDetection = async (payload: {
  file: File
  modelPath?: string
  conf?: number
}) => {
  const form = new FormData()
  form.append('file', payload.file)
  if (payload.modelPath) {
    form.append('modelPath', payload.modelPath)
  }
  form.append('conf', String(payload.conf ?? 0.25))
  const response = await request.post<ApiResult<DetectionPayload>>('/AIModuleServer/Detection/run', form, {
    timeout: 180000,
  })
  if (response.data.code !== 20000) {
    throw new Error(response.data.message || '识别失败')
  }
  return response.data.data.results
}

const unwrap = <T>(response: { data: ApiResult<T> }, fallback: string) => {
  if (response.data.code !== 20000) {
    throw new Error(response.data.message || fallback)
  }
  return response.data.data
}

export const startCameraDetection = async () => {
  const response = await request.post<ApiResult<CameraDetectionState>>(
    '/AIModuleServer/Detection/camera/start',
    undefined,
    { timeout: 30000 },
  )
  return unwrap(response, '启动相机监听失败')
}

export const stopCameraDetection = async () => {
  const response = await request.post<ApiResult<CameraDetectionState>>(
    '/AIModuleServer/Detection/camera/stop',
  )
  return unwrap(response, '停止相机监听失败')
}

export const getCameraDetectionStatus = async () => {
  const response = await request.get<ApiResult<CameraDetectionState>>(
    '/AIModuleServer/Detection/camera/status',
  )
  return unwrap(response, '读取相机监听状态失败')
}

export const getLatestCameraDetection = async () => {
  const response = await request.get<ApiResult<CameraDetectionResult | null>>(
    '/AIModuleServer/Detection/latest',
  )
  return unwrap(response, '读取相机识别结果失败')
}
