<template>
  <div class="WizardSetupAccounts">
    <h1>Choose your accounts</h1>
    <p>
      Choose the accounts you want to work with
    </p>
    <ListGroup class="AccountsList">
      <ListGroupItem
        v-for="account in accounts"
        v-bind:key="account.id"
        v-on:click="toggle(account.id)"
        v-bind:active="selectedAccounts.indexOf(account.id) >= 0"
      >
        <div class="Heading">
          <h5 class="Title">{{account.name}}</h5>
          <small>{{account.type}}</small>
        </div>
        <p>
          {{accountDescription(account)}}
        </p>
      </ListGroupItem>
    </ListGroup>
    <form v-on:submit.prevent="onSubmit">
      <ActionBar
        v-bind:disableNext="!hasSelectedAccounts"
        v-on:back="onBack"
      />
    </form>
  </div>
</template>

<script lang="ts">
import isEmpty from 'lodash-es/isEmpty'
import Vue from 'vue'
import { State, BudgetSettings, WizardStep } from '@/store/mutations'
import ListGroup from '@/components/ListGroup.vue'
import ListGroupItem from '@/components/ListGroupItem.vue'
import { formatCurrency, Account, BudgetSummary } from '@/helpers/ynab'
import ActionBar from './ActionBar.vue'

export default Vue.extend({
  name: 'WizardSetupBudget',
  data() {
    const { settings } = <State>this.$store.state
    const { budgets } = settings
    const budgetSetting: BudgetSettings | null =
      budgets.length > 0 ? budgets[0] : null
    const selectedAccounts = budgetSetting
      ? budgetSetting.accounts.map(a => a.accountId)
      : []

    return {
      selectedAccounts
    }
  },
  computed: {
    accounts: function(): Account[] {
      const { userAccounts, settings } = <State>this.$store.state
      const budgetId = settings.budgets.map(b => b.budgetId)[0] || ''
      return userAccounts[budgetId] || []
    },
    currentBudget: function(): BudgetSummary | undefined {
      return this.$store.getters.currentBudget
    },
    hasSelectedAccounts: function(): boolean {
      return this.selectedAccounts.length > 0
    }
  },
  methods: {
    accountDescription(account: Account) {
      const currencyFormat = this.currentBudget
        ? this.currentBudget.currency_format
        : undefined

      return !isEmpty(account.note)
        ? account.note
        : `Balance: ${formatCurrency(currencyFormat)(account.balance)}`
    },
    onBack() {
      const previousStep: WizardStep = 'budget'
      this.$store.commit('saveWizardStep', previousStep)
    },
    onSubmit() {
      // const { selectedBudgetId } = this
      // this.$store.commit('saveBudgetSettings', selectedBudgetId)
    },
    toggle(accountId: string) {
      const { selectedAccounts } = this
      const accountIndex = selectedAccounts.indexOf(accountId)
      if (accountIndex < 0) {
        selectedAccounts.push(accountId)
      } else {
        selectedAccounts.splice(accountIndex, 1)
      }
    }
  },
  components: {
    ActionBar,
    ListGroup,
    ListGroupItem
  }
})
</script>

<style lang="stylus">
@import '~@/styles/_variables';

.WizardSetupAccounts {
  .AccountsList {
    text-align: left;
  }

  .Heading {
    align-items: center;
    display: flex;
    justify-content: space-between;

    .Title {
      font-size: px2rem(18);
      margin: 0;
    }
  }
}
</style>

