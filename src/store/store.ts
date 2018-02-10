import Vue from 'vue'
import Vuex from 'vuex'

import getters from './getters'
import mutations, { State, STORAGE_KEY } from './mutations'
import plugins from './plugins'

Vue.use(Vuex)

const defaultState: State = {
  settings: {
    apiAccessToken: '',
    budgets: []
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
  getters,
  mutations,
  plugins
})

export default store
