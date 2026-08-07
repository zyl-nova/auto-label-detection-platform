import request from '@/utils/request'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

export interface SavedAnnotationRecord {
  id?: string
  imageIndex?: number
  labelData?: string
  labelList?: string
}

export const saveImageAnnotation = async (payload: {
  taskId: number
  fileId: string | number
  imageIndex: number
  labelData: string
  labelList: string
  picStoreUrl?: string
}) => {
  await request.post<ApiResult<number>>('/AIModuleServer/ImageLabel/saveAnnotation', payload)
}

export const getImageAnnotation = async (taskId: number, fileId: string | number, imageIndex = 0) => {
  const response = await request.get<ApiResult<SavedAnnotationRecord | null>>('/AIModuleServer/ImageLabel/annotation', {
    params: { taskId, fileId, imageIndex },
  })
  return response.data.data
}
