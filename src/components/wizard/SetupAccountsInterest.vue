<template>
  <div class="WizardSetupAccountsInterest">
    <h1>Enter your account interest details</h1>
    <p>
      To calculate your debt snowball we need each of your accounts
      interest details
    </p>
    <form v-on:submit.prevent="onSubmit">
      <ListGroup>
        <ListGroupItem
          v-for="account in accounts"
          v-bind:key="account.id"
          v-bind:selectable="false"
        >
          <div class="Heading">
            <h5 class="Title">{{account.account.name}}</h5>
            <small>{{account.account.type}}</small>
          </div>
          <FormInput v-bind:mode="account.settings.rate" label="Rate" />
          <FormInput v-bind:mode="account.settings.minPaymentPercent" label="Min. Payment Percentage" />
          <FormInput v-bind:mode="account.settings.minPaymentAmount" label="Min. Payment Amount" />
        </ListGroupItem>
      </ListGroup>
      <ActionBar
        v-bind:disableNext="!isValid"
        v-on:back="onBack"
      />
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import ActionBar from './ActionBar.vue'
import { State, WizardStep } from '@/store/types'
import { BudgetSettings, AccountSettings } from '@/store'
import { Account } from '@/helpers/ynab'
import FormInput from '@/components/FormInput.vue'
import ListGroup from '@/components/ListGroup.vue'
import ListGroupItem from '@/components/ListGroupItem.vue'

interface AccountConfig {
  id: string
  account: Account
  settings: AccountSettings
}

export default Vue.extend({
  name: 'WizardSetupBudget',
  data() {
    const { userAccounts } = <State>this.$store.state
    const budgetSettings: BudgetSettings = this.$store.getters
      .currentBudgetSettings
    const accountsSettings = budgetSettings.accounts
    const selectedAccountsIds = accountsSettings.map(a => a.accountId)

    const budgetAccounts = userAccounts[budgetSettings.budgetId]
    budgetSettings.accounts.map(a =>
      budgetAccounts.find(ba => a.accountId === ba.id)
    )
    const accounts: AccountConfig[] = budgetAccounts
      .filter(ba => selectedAccountsIds.indexOf(ba.id) >= 0)
      .map(ba => ({
        id: ba.id,
        account: ba,
        settings: accountsSettings.find(a => a.accountId === ba.id) || {
          accountId: ''
        }
      }))

    return {
      accounts
    }
  },
  computed: {
    isValid: function(): boolean {
      return false
    }
  },
  methods: {
    onBack() {
      const previousStep: WizardStep = 'accounts'
      this.$store.commit('saveWizardStep', previousStep)
    },
    onSubmit() {}
  },
  components: {
    ActionBar,
    FormInput,
    ListGroup,
    ListGroupItem
  }
})
</script>

<style lang="stylus">
@import '~@/styles/_variables';

.WizardSetupAccountsInterest {
  .Heading {
    align-items: center;
    display: flex;
    justify-content: space-between;
  }

  .Title {
    font-size: px2rem(16);
  }
}
</style>

