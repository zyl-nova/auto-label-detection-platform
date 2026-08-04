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
