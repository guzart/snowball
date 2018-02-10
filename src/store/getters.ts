import { GetterTree } from 'vuex'
import { State } from '@/store'

const getters: GetterTree<State, State> = {
  budgetIds: state => {
    return state.settings.budgets.map(b => b.budgetId)
  },
  isSetup: (_, getters) => {
    return getters.budgetIds.length > 0
  }
}

export default getters
