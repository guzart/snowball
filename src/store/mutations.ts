import { MutationTree } from 'vuex'
import merge from 'lodash-es/merge'
import {
  State,
  SaveBugetSettingsPayload,
  Settings,
  SaveBudgetAccountsPayload,
  WizardStep
} from '@/store/types'
import { BudgetSummary } from '@/helpers/ynab'

export const STORAGE_KEY = 'snowball-state'

const mutations: MutationTree<State> = {
  saveAccessToken(state, accessToken: string) {
    state.settings.accessToken = accessToken
  },
  saveBudgetSettings(state, payload: SaveBugetSettingsPayload) {
    const { budgetId, accounts } = payload
    state.settings.budgets = [{ budgetId, accounts }]
  },
  saveSettings(state, settings: Partial<Settings>) {
    state.settings = merge({}, state.settings, settings)
  },
  saveUserAccounts(state, payload: SaveBudgetAccountsPayload) {
    const { accounts, budgetId } = payload
    state.userAccounts[budgetId] = accounts
  },
  saveUserBudgets(state, budgets: BudgetSummary[]) {
    state.userBudgets = budgets
  },
  saveWizardStep(state, wizardStep: WizardStep) {
    state.wizardStep = wizardStep
  }
}

export default mutations
