import Vue from 'vue'
import Vuex from 'vuex'
import merge from 'lodash-es/merge'

Vue.use(Vuex)

interface Settings {
  apiAccessToken: string
  debtAccounts: { [key: string]: string }
}

export interface State {
  settings: Settings
}

const store = new Vuex.Store<State>({
  state: {
    settings: {
      apiAccessToken: '',
      debtAccounts: {}
    }
  },
  mutations: {
    saveSettings(state, settings: Partial<Settings>) {
      state.settings = merge({}, state.settings, settings)
    }
  },
  actions: {}
})

export type Store = typeof store

export default store
