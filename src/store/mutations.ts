import { MutationTree, Store as vStore } from 'vuex'
import merge from 'lodash-es/merge'
import { BudgetSummary } from '@/helpers/ynab'

export const STORAGE_KEY = 'snowball-state'

export interface MinimumPaymentConfig {
  percentage: number
  minimum: number
}

export interface AccountConfig {
  accountId: string
  rate: number
  minimumPayment: MinimumPaymentConfig
}

export interface BudgetConfig {
  budgetId: string
  accounts: AccountConfig[]
}

export interface Settings {
  apiAccessToken: string
  budgets: BudgetConfig[]
}

export interface State {
  budgets: BudgetSummary[]
  settings: Settings
}

export type Store = vStore<State>

const mutations: MutationTree<State> = {
  setBudgets(state, budgets: BudgetSummary[]) {
    state.budgets = budgets
  },
  saveSettings(state, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  }
}

export default mutations
