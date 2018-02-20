import { Store as vStore } from 'vuex'
import { Account, BudgetSummary } from '@/helpers/ynab'

export interface MinimumPaymentConfig {
  percentage: number
  minimum: number
}

export interface AccountSettings {
  accountId: string
  rate?: number
  minimumPayment?: MinimumPaymentConfig
}

export interface BudgetSettings {
  accounts: AccountSettings[]
  budgetId: string
}

export interface Settings {
  accessToken: string
  budgets: BudgetSettings[]
}

export type WizardStep =
  | 'accessToken'
  | 'budget'
  | 'accounts'
  | 'accountsInterest'
  | 'complete'

export interface State {
  settings: Settings
  userAccounts: { [key: string]: Account[] }
  userBudgets: BudgetSummary[]
  wizardStep: WizardStep
}

export interface SaveBudgetAccountsPayload {
  budgetId: string
  accounts: Account[]
}

export interface SaveBugetSettingsPayload {
  budgetId: string
  accounts: AccountSettings[]
}

export type Store = vStore<State>
