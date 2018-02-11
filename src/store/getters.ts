import { GetterTree } from 'vuex'
import { State } from '@/store'
import { clientFactory } from '@/helpers/ynab'

const getters: GetterTree<State, State> = {
  isSetup: state => {
    return state.settings.budgets.map(b => b.budgetId).length > 0
  },
  ynabClient: state => {
    const accessToken = state.settings.apiAccessToken
    console.log(accessToken)
    return clientFactory(accessToken)
  }
}

export default getters
