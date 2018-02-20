import { ActionTree } from 'vuex'
import { State } from '@/store'
import { YNABClient } from '@/helpers/ynab'
import { SaveBugetSettingsPayload } from '@/store/types'

interface SetupSelectedAccountsPayload {
  budgetId: string
  accountIds: string[]
}

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
    commit('saveUserAccounts', { budgetId, accounts })
  },
  setupAccessToken: async ({ commit, dispatch }, accessToken: string) => {
    commit('saveAccessToken', accessToken)
    await dispatch('loadBudgets')
  },
  setupSelectedBudget: async ({ commit, dispatch }, budgetId: string) => {
    const payload: SaveBugetSettingsPayload = { budgetId, accounts: [] }
    commit('saveBudgetSettings', payload)
    await dispatch('loadBudgetAccounts', budgetId)
  },
  setupSelectedAccounts: async (
    { commit },
    payload: SetupSelectedAccountsPayload
  ) => {
    const { budgetId, accountIds } = payload
    const accounts = accountIds.map(accountId => ({ accountId }))
    commit('saveBudgetSettings', { budgetId, accounts })
  }
}

export default actions
