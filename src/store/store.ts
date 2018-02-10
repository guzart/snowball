import Vue from 'vue'
import Vuex from 'vuex'
import plugins from './plugins'
import mutations, { State, STORAGE_KEY } from './mutations'

Vue.use(Vuex)

const defaultState: State = {
  settings: {
    apiAccessToken: '',
    debtAccounts: {}
  }
}

const state = ((): State => {
  try {
    return JSON.parse(window.localStorage.getItem(STORAGE_KEY) || '')
  } catch (error) {
    return defaultState
  }
})()

const store = new Vuex.Store<State>({
  state,
  mutations,
  actions: {},
  plugins
})

export default store
