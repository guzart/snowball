import { ActionTree } from 'vuex'
import { State } from '@/store'
import { YNABClient } from '@/helpers/ynab'

const actions: ActionTree<State, State> = {
  loadBudgets: async ({ commit, getters }) => {
    const client: YNABClient = getters.client
    const budgets = await client.fetchBudgets()
    commit('saveUserBudgets', budgets)
    return budgets
  },
  loadBudgetAccounts: async ({ commit, getters }, budgetId: string) => {
    const client: YNABClient = getters.client
    const accounts = await client.fetchAccounts(budgetId)
    commit('saveBudgetAccounts', accounts)
  },
  setupAccessToken: async ({ commit, dispatch }, accessToken: string) => {
    commit('saveAccessToken', accessToken)
    await dispatch('loadBudgets')
  }
}

export default actions
