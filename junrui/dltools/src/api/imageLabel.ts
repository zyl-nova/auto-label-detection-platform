import request from '@/utils/request'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

export interface SavedAnnotationRecord {
  id?: string
  labelData?: string
  labelList?: string
}

export const saveImageAnnotation = async (payload: {
  taskId: number
  fileId: number
  labelData: string
  labelList: string
  picStoreUrl?: string
}) => {
  await request.post<ApiResult<number>>('/AIModuleServer/ImageLabel/saveAnnotation', payload)
}

export const getImageAnnotation = async (taskId: number, fileId: number) => {
  const response = await request.get<ApiResult<SavedAnnotationRecord | null>>('/AIModuleServer/ImageLabel/annotation', {
    params: { taskId, fileId },
  })
  return response.data.data
}
