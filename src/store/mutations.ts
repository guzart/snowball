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
  accounts: AccountSettings[]
  budgetId: string
}

export interface Settings {
  accessToken: string
  budgets: BudgetSettings[]
}

export type WizardStep = 'accessToken' | 'budget' | 'accounts' | 'complete'

export interface State {
  settings: Settings
  userBudgets: BudgetSummary[]
  wizardStep: WizardStep
}

export type Store = vStore<State>

const mutations: MutationTree<State> = {
  saveAccessToken(state, accessToken: string) {
    state.settings.accessToken = accessToken
  },
  saveBudgetSettings(
    state,
    budgetId: string,
    accounts: AccountSettings[] = []
  ) {
    state.settings.budgets = [{ budgetId, accounts }]
  },
  saveSettings(state, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  },
  saveUserBudgets(state, budgets: BudgetSummary[]) {
    state.userBudgets = budgets
  },
  saveWizardStep(state, wizardStep: WizardStep) {
    state.wizardStep = wizardStep
  }
}

export default mutations
