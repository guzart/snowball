import { Store, STORAGE_KEY } from './mutations'

const localStoragePlugin = (store: Store) => {
  store.subscribe((_mutation, state) => {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
  })
}

export default [localStoragePlugin]
