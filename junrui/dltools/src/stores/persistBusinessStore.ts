import type { PiniaPluginContext } from 'pinia'
import { loadBusinessState, saveBusinessState } from '@/api/businessState'

const STORAGE_KEY = 'auto-label-detection:business-store'
const BUSINESS_STORE_ID = 'business'

const persistedKeys = [
  'nextId',
  'files',
  'labelTasks',
  'samples',
  'models',
  'trainTasks',
  'detectionResults',
] as const

export const persistBusinessStore = ({ store }: PiniaPluginContext) => {
  if (store.$id !== BUSINESS_STORE_ID) return
  let applyingRemoteState = false
  let saveTimer: ReturnType<typeof window.setTimeout> | undefined

  const saveState = (state: Record<string, any>) => {
    const data = persistedKeys.reduce<Record<string, unknown>>((result, key) => {
      result[key] = state[key]
      return result
    }, {})
    const stateData = JSON.stringify(data)
    localStorage.setItem(STORAGE_KEY, stateData)
    return stateData
  }

  const saveRemoteState = (state: Record<string, any>) => {
    if (applyingRemoteState) return
    const stateData = saveState(state)
    if (saveTimer) {
      window.clearTimeout(saveTimer)
    }
    saveTimer = window.setTimeout(() => {
      saveBusinessState(stateData).catch((error) => {
        console.warn('Business state saved locally, remote sync failed.', error)
      })
    }, 600)
  }

  const saved = localStorage.getItem(STORAGE_KEY)
  if (saved) {
    try {
      store.$patch(JSON.parse(saved))
    } catch (error) {
      console.error(error)
      localStorage.removeItem(STORAGE_KEY)
    }
  }

  store.$subscribe(
    (_mutation, state) => {
      saveState(state)
      saveRemoteState(state)
    },
    { detached: true },
  )

  loadBusinessState()
    .then((record) => {
      if (!record?.stateData) {
        saveRemoteState(store.$state)
        return
      }
      applyingRemoteState = true
      store.$patch(JSON.parse(record.stateData))
      localStorage.setItem(STORAGE_KEY, record.stateData)
      applyingRemoteState = false
    })
    .catch(() => {
      saveRemoteState(store.$state)
    })
}
