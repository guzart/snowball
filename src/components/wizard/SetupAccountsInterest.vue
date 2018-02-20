<template>
  <div class="WizardSetupAccountsInterest">
    <h1>Enter your account interest details</h1>
    <p>
      To calculate your debt snowball we need each of your accounts
      interest details
    </p>
    <form v-on:submit.prevent="onSubmit" class="form">
      <SimpleCardDeck>
        <SimpleCard
          v-for="account in accounts"
          v-bind:key="account.id"
          v-bind:selectable="false"
        >
          <div class="SimpleCard_Body">
            <h5 class="SimpleCard_Title">{{account.account.name}}</h5>
            <h6 class="SimpleCard_Subtitle">{{account.account.type}}</h6>
            <p>
              <FormInput v-bind:mode="account.settings.rate" label="Rate" />
              <FormInput v-bind:mode="account.settings.minPaymentPercent" label="Min. Payment Percentage" />
              <FormInput v-bind:mode="account.settings.minPaymentAmount" label="Min. Payment Amount" />
            </p>
          </div>
        </SimpleCard>
      </SimpleCardDeck>
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
import SimpleCard from '@/components/SimpleCard.vue'
import SimpleCardDeck from '@/components/SimpleCardDeck.vue'

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
    SimpleCard,
    SimpleCardDeck
  }
})
</script>

<style lang="stylus">
@import '~@/styles/_variables';
@import '~@/styles/_breakpoints';

.WizardSetupAccountsInterest {
  .SimpleCardDeck .SimpleCard {
    +mediaBreakpointUp(xs) {
      flex: 0 0 100%;
    }

    +mediaBreakpointUp(sm) {
      flex: '0 0 calc(50% - %s)' % $gridGutterWidth;
    }

    +mediaBreakpointUp(lg) {
      flex: '0 0 calc(%s - %s)' % (percentage((1 / 3)) $gridGutterWidth);
    }
  }
}
</style>

