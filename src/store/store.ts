import Vue from 'vue'
import Vuex from 'vuex'
import merge from 'lodash-es/merge'

import actions from './actions'
import getters from './getters'
import mutations, { State, STORAGE_KEY, WizardStep } from './mutations'
import plugins from './plugins'

Vue.use(Vuex)

const defaultState: State = {
  userAccounts: {},
  userBudgets: [],
  settings: {
    accessToken: '',
    budgets: []
  },
  wizardStep: 'complete'
}

const calculateWizardStep = (state: State): WizardStep => {
  const { settings } = state
  if (settings.accessToken === '') {
    return 'accessToken'
  }

  const { budgets } = settings
  if (budgets.length === 0) {
    return 'budget'
  }

  if (budgets[0].accounts.length === 0) {
    return 'accounts'
  }

  return 'complete'
}

const state = ((): State => {
  try {
    const sourceState = JSON.parse(
      window.localStorage.getItem(STORAGE_KEY) || ''
    )
    const outputState: State = merge({}, defaultState, sourceState)
    outputState.wizardStep = calculateWizardStep(outputState)
    return outputState
  } catch (error) {
    return defaultState
  }
})()

const store = new Vuex.Store<State>({
  state,
  getters,
  mutations,
  actions,
  plugins
})

export default store
