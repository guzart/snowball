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

interface Account {
  id: string
  name: string
  type: 'Checking' | 'Savings' | 'CreditCard'
  on_budget: boolean
  closed: boolean
  note: string | null
  balance: number
  cleared_balance: number
  uncleared_balance: number
}

interface APIErrorResponseBody {
  error: {
    id: string
    name: string
    detail: string
  }
}

interface APIResponseDataBody<T> extends Response {
  data: T
}

type APIResponseBody<T> = APIResponseDataBody<T> | APIErrorResponseBody

const isAPIResponseError = <T>(
  response: APIResponseBody<T>
): response is APIErrorResponseBody => {
  return (<APIErrorResponseBody>response).error !== undefined
}

export class HttpError extends Error {
  status: number

  constructor(message: string, status: number) {
    super(message)
    this.status = status
  }
}

const getRequest = <T>(accessToken: string) => (
  path: string,
  options: RequestInit = {}
) =>
  fetch(
    `http://localhost:9090/papi/v1${path}`,
    merge(
      {
        headers: {
          Accept: 'application/json',
          Authorization: `Bearer ${accessToken}`
        }
      },
      options
    )
  )
    .then(r => r.json())
    .then((r: APIResponseDataBody<T>) => {
      if (isAPIResponseError(r)) {
        throw new HttpError(r.error.detail, parseInt(r.error.id, 10))
      }

      return r
    })

interface BudgetsResponse {
  budgets: BudgetSummary[]
}

export const fetchBudgets = (accessToken: string) => async () => {
  const response = await getRequest<BudgetsResponse>(accessToken)('/budgets')
  return response.data.budgets
}

interface BudgetResponse {
  budget: Budget
  server_knowledge: number
}

export const fetchBudget = (accessToken: string) => async (
  budgetId: string
) => {
  const response = await getRequest<BudgetResponse>(accessToken)(
    `/budgets/${budgetId}/accounts`
  )
  return response.data.budget
}

interface AccountsResponse {
  accounts: Account[]
}

export const fetchAccounts = (accessToken: string) => async (
  budgetId: string
) => {
  const response = await getRequest<AccountsResponse>(accessToken)(
    `/budgets/${budgetId}/accounts`
  )
  return response.data.accounts
}

export const clientFactory = (accessToken: string) => ({
  fetchAccounts: fetchAccounts(accessToken),
  fetchBudget: fetchBudget(accessToken),
  fetchBudgets: fetchBudgets(accessToken)
})

const client = clientFactory('') // use to get the type
export type YNABClient = typeof client
