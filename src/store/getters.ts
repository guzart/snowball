import { GetterTree } from 'vuex'
import { State } from '@/store'
import { clientFactory } from '@/helpers/ynab'

const getters: GetterTree<State, State> = {
  client: state => {
    const accessToken = state.settings.accessToken
    return clientFactory(accessToken)
  },
  currentBudget: state => {
    const firstBudgetId = state.settings.budgets.map(b => b.budgetId)[0] || ''
    if (firstBudgetId === '') {
      return
    }

    return state.userBudgets.find(b => b.id === firstBudgetId)
  }
}

export default getters
