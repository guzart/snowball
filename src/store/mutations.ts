import { MutationTree, Store as vStore } from 'vuex'
import merge from 'lodash-es/merge'
import { BudgetSummary } from '@/helpers/ynab'

export const STORAGE_KEY = 'snowball-state'

export interface MinimumPaymentConfig {
  percentage: number
  minimum: number
}

export interface AccountSettings {
  accountId: string
  rate: number
  minimumPayment: MinimumPaymentConfig
}

export interface BudgetSettings {
  budgetId: string
  accounts: AccountSettings[]
}

export interface Settings {
  apiAccessToken: string
  budgets: BudgetSettings[]
}

export interface State {
  settings: Settings
  userBudgets: BudgetSummary[]
}

export type Store = vStore<State>

const mutations: MutationTree<State> = {
  saveSettings(state, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  },
  setUserBudgets(state, budgets: BudgetSummary[]) {
    state.userBudgets = budgets
  }
}

export default mutations
