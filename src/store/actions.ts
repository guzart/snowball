import { ActionTree } from 'vuex'
import { State } from '@/store'
import { YNABClient } from '@/helpers/ynab'

const actions: ActionTree<State, State> = {
  loadBudgets: async ctx => {
    const client: YNABClient = ctx.getters.client
    const budgets = await client.fetchBudgets()
    ctx.commit('setUserBudgets', budgets)
    return budgets
  }
}

export default actions
