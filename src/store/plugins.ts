import { STORAGE_KEY } from './mutations'
import { Store } from '@/store/types'

const localStoragePlugin = (store: Store) => {
  store.subscribe((_mutation, state) => {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
  })
}

export default [localStoragePlugin]
