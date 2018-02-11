import merge from 'lodash-es/merge'

export interface CurrencyFormat {
  locale: string
}

export interface DateFormat {
  locale: string
}

export interface BudgetSummary {
  id: string
  name: string
  last_modified_on?: string
  date_format?: {
    locale: string
  }
  currency_format?: {
    locale: string
  }
}

export interface CategoryGroup {
  id: string
  name: string
  hidden: boolean
}

export interface Category {
  id: string
  category_group_id: string
  name: string
  hidden: boolean
  note: string
  budgeted: number
  activity: number
  balance: number
}

export interface Payee {
  id: string
  name: string
  transfer_account_id: string
}

export interface PayeeLocation {
  id: string
  payee_id: string
  latitude: string
  longitude: string
}

export interface MonthDetail {
  month: string
  note: string
  to_be_budgeted: number
  age_of_money: number
  categories: Array<Category>
}

export enum FrequencyEnum {
  Never = 'never',
  Daily = 'daily',
  Weekly = 'weekly',
  EveryOtherWeek = 'everyOtherWeek',
  TwiceAMonth = 'twiceAMonth',
  Every4Weeks = 'every4Weeks',
  Monthly = 'monthly',
  EveryOtherMonth = 'everyOtherMonth',
  Every3Months = 'every3Months',
  Every4Months = 'every4Months',
  TwiceAYear = 'twiceAYear',
  Yearly = 'yearly',
  EveryOtherYear = 'everyOtherYear'
}

export interface ScheduledTransactionSummary {
  id: string
  date_first: string
  date_next: string
  frequency: FrequencyEnum
  amount: number
  memo: string
  flag_color: string
  account_id: string
  payee_id: string
  category_id: string
  transfer_account_id: string
}

export interface TransactionSummary {
  id: string
  date: string
  amount: number
  memo: string
  cleared: ClearedEnum
  approved: boolean
  flag_color: string
  account_id: string
  payee_id: string
  category_id: string
  transfer_account_id: string
}

export enum ClearedEnum {
  Cleared = 'cleared',
  Uncleared = 'uncleared',
  Reconciled = 'reconciled'
}

export interface ScheduledSubTransaction {
  id: string
  scheduled_transaction_id: string
  amount: number
  memo: string
  payee_id: string
  category_id: string
  transfer_account_id: string
}

export interface SubTransaction {
  id: string
  transaction_id: string
  amount: number
  memo: string
  payee_id: string
  category_id: string
  transfer_account_id: string
}

export interface Budget extends BudgetSummary {
  accounts?: Account[]
  payees?: Payee[]
  payee_locations?: PayeeLocation[]
  category_groups?: CategoryGroup[]
  categories?: Category[]
  months?: MonthDetail[]
  transactions?: TransactionSummary[]
  subtransactions?: SubTransaction[]
  scheduled_transactions?: ScheduledTransactionSummary[]
  scheduled_subtransactions?: ScheduledSubTransaction[]
}

interface Response<T> {
  data: T
}

const getRequest = <T>(accessToken: string) => (
  path: string,
  options: RequestInit = {}
) =>
  fetch(
    `https://api.youneedabudget.com/v1${path}`,
    merge(
      {
        // mode: 'no-cors',
        // credentials: 'include',
        headers: {
          Accept: 'application/json',
          Authorization: `Bearer ${accessToken}`
        }
      },
      options
    )
  ).then(response => response.json() as Promise<T>)

type BudgetsResponse = Response<{ budgets: BudgetSummary[] }>

export const fetchBudgets = (accessToken: string) => async () => {
  const response = await getRequest<BudgetsResponse>(accessToken)('/budgets')
  return response.data.budgets
}

type BudgetResponse = Response<{ budget: Budget }>

export const fetchBudget = (accessToken: string) => async (
  budgetId: string
) => {
  const response = await getRequest<BudgetResponse>(accessToken)(
    `/budget/${budgetId}`
  )
  return response.data.budget
}

export const clientFactory = (accessToken: string) => ({
  fetchBudget: fetchBudget(accessToken),
  fetchBudgets: fetchBudgets(accessToken)
})

const client = clientFactory('')
export type YNABClient = typeof client
