import { ActionTree } from 'vuex'
import { State } from '@/store'
import { YNABClient } from '@/helpers/ynab'

const actions: ActionTree<State, State> = {
  loadBudgets: async ctx => {
    const client: YNABClient = ctx.getters.client
    const budgets = await client.fetchBudgets()
    ctx.commit('saveUserBudgets', budgets)
    return budgets
  },
  setupAccessToken: async ({ commit, dispatch }, accessToken: string) => {
    commit('saveAccessToken', accessToken)
    await dispatch('loadBudgets')
  }
}

export default actions
