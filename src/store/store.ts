import Vue from 'vue'
import Vuex from 'vuex'
import merge from 'lodash-es/merge'

import actions from './actions'
import getters from './getters'
import mutations, { State, STORAGE_KEY } from './mutations'
import plugins from './plugins'

Vue.use(Vuex)

const defaultState: State = {
  budgets: [],
  settings: {
    apiAccessToken: '',
    budgets: []
  }
}

const state = ((): State => {
  try {
    const sourceState = JSON.parse(
      window.localStorage.getItem(STORAGE_KEY) || ''
    )
    return merge({}, defaultState, sourceState)
  } catch (error) {
    return defaultState
  }
})()

console.log(state)

const store = new Vuex.Store<State>({
  state,
  getters,
  mutations,
  actions,
  plugins
})

export default store
