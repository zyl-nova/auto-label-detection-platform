import request from '@/utils/request'
import type { DataType, ManagedFile } from '@/stores/businessStore'

interface PageResult<T> {
  list: T[]
  total: number
}

interface ApiResult<T> {
  code: number
  message: string
  data: T
}

interface FileManagerRecord {
  id: string
  eName?: string
  cName?: string
  ename?: string
  cname?: string
  projId?: string
  projName?: string
  originalFileType?: number
  createTime?: string
  updateTime?: string
  des?: string
  status?: number
  originalFileStoreUrl?: string
  disposedFileStoreUrl?: string
  createUserName?: string
}

export const typeToCode = (type: DataType) => {
  if (type === '图像') return 0
  if (type === '视频') return 1
  return 2
}

export const codeToType = (code?: number): DataType => {
  if (code === 0) return '图像'
  if (code === 1) return '视频'
  return '其他'
}

const fileNameFromPath = (path?: string) => {
  if (!path) return ''
  return path.split(/[\\/]/).pop() || ''
}

export const mapFileRecord = (item: FileManagerRecord): ManagedFile => {
  const id = Number(item.id)
  return {
    id,
    name: item.cName || item.cname || item.eName || item.ename || fileNameFromPath(item.originalFileStoreUrl) || `文件${item.id}`,
    type: codeToType(item.originalFileType),
    projectId: Number(item.projId || 0),
    projectName: item.projName || `项目${item.projId || ''}`,
    creator: item.createUserName || '本地用户',
    uploadTime: item.createTime || item.updateTime || '',
    source: item.des || '数据库记录',
    url: `/api/AIModuleServer/FileManager/preview?id=${item.id}`,
  }
}

export const listFiles = async (params?: { keyword?: string; fileType?: number }) => {
  const form = new FormData()
  form.append('startPage', '1')
  form.append('pageSize', '200')
  form.append('projId', '')
  form.append('mainInfo', params?.keyword || '')
  form.append('isDesc', 'true')
  form.append('fileType', params?.fileType === undefined ? '-1' : String(params.fileType))

  const response = await request.post<ApiResult<PageResult<FileManagerRecord>>>('/AIModuleServer/FileManager/list', form)
  return response.data.data.list.map(mapFileRecord)
}

export const uploadFileRecord = async (file: File, payload: { name: string; type: DataType; projectId: number; description?: string }) => {
  const form = new FormData()
  form.append('file', file)
  form.append('fileManager', JSON.stringify({
    eName: payload.name,
    cName: payload.name,
    projId: String(payload.projectId),
    originalFileType: typeToCode(payload.type),
    des: payload.description || '本地上传',
  }))
  form.append('chunkNumber', '0')
  form.append('totalChunks', '1')
  form.append('addFileUserId', '48')
  const response = await request.post<ApiResult<string>>('/AIModuleServer/FileManager/addFile', form)
  if (response.data.code !== 20000) {
    throw new Error(response.data.message || '文件上传失败')
  }
}

export const updateFileRecord = async (file: ManagedFile) => {
  await request.post('/AIModuleServer/FileManager/updateFile', {
    id: String(file.id),
    eName: file.name,
    cName: file.name,
    projId: String(file.projectId || 2),
    originalFileType: typeToCode(file.type),
    des: file.source || '本地上传',
    status: 2,
    logicalDelete: 0,
    originalFileStoreUrl: file.url?.startsWith('/api/') ? undefined : file.url,
  })
}

export const deleteFileRecord = async (id: number) => {
  const form = new FormData()
  form.append('id', String(id))
  await request.post('/AIModuleServer/FileManager/deleteFile', form)
}
