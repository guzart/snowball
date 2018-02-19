import { GetterTree } from 'vuex'
import { State } from '@/store'
import { clientFactory } from '@/helpers/ynab'

const getters: GetterTree<State, State> = {
  client: state => {
    const accessToken = state.settings.apiAccessToken
    return clientFactory(accessToken)
  }
}

export default getters
