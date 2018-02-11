import { ActionTree } from 'vuex'
import { State } from '@/store'
import { YNABClient } from '@/helpers/ynab'

const actions: ActionTree<State, State> = {
  loadBudgets: ctx => {
    const client: YNABClient = ctx.getters.ynabClient
    return client.fetchBudgets().then(budgets => {
      ctx.commit('setBudgets', budgets)
      return budgets
    })
  }
}

export default actions
