import { Store as vStore } from 'vuex'
import merge from 'lodash-es/merge'

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
  settings: Settings
}

export type Store = vStore<State>

export default {
  saveSettings(state: State, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  }
}
