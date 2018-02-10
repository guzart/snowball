import { Store as vStore } from 'vuex'
import merge from 'lodash-es/merge'

export const STORAGE_KEY = 'snowball-state'

export interface Settings {
  apiAccessToken: string
  debtAccounts: { [key: string]: string }
}

export interface State {
  settings: Settings
}

export type Store = vStore<State>

export default {
  saveSettings(state: State, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  }
}
