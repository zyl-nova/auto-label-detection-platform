import request from '@/utils/request'

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

interface BusinessStateRecord {
  stateKey: string
  stateData: string
  updateTime?: string
}

export const loadBusinessState = async () => {
  const response = await request.get<ApiResult<BusinessStateRecord | null>>('/AIModuleServer/BusinessState/load', {
    params: { stateKey: 'business' },
  })
  return response.data.data
}

export const saveBusinessState = async (stateData: string) => {
  await request.post<ApiResult<number>>('/AIModuleServer/BusinessState/save', {
    stateKey: 'business',
    stateData,
  })
}
