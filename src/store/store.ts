import Vue from 'vue'
import Vuex from 'vuex'
import every from 'lodash-es/every'
import isEmpty from 'lodash-es/isEmpty'
import merge from 'lodash-es/merge'

import actions from './actions'
import getters from './getters'
import mutations, { STORAGE_KEY } from './mutations'
import { State, WizardStep, AccountSettings } from './types'
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
  if (isEmpty(settings.accessToken)) {
    return 'accessToken'
  }

  const { budgets } = settings
  if (isEmpty(budgets)) {
    return 'budget'
  }

  const { accounts } = budgets[0]
  if (isEmpty(accounts)) {
    return 'accounts'
  }

  const isValidConfig = (settings: AccountSettings) =>
    settings.minimumPayment != null && settings.rate != null
  if (every(accounts, isValidConfig)) {
    return 'accountsInterest'
  }

  return 'complete'
}

const state = ((): State => {
  let outputState: State = defaultState
  const sourceState = JSON.parse(
    window.localStorage.getItem(STORAGE_KEY) || '{}'
  )
  outputState = merge({}, defaultState, sourceState)
  outputState.wizardStep = calculateWizardStep(outputState)
  return outputState
})()

const store = new Vuex.Store<State>({
  state,
  getters,
  mutations,
  actions,
  plugins
})

export default store
