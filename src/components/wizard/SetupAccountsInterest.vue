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
          v-for="accountConfig in accountsConfig"
          :key="accountConfig.id"
          :selectable="false"
        >
          <div class="SimpleCard_Body">
            <h5 class="SimpleCard_Title">{{accountConfig.account.name}}</h5>
            <h6 class="SimpleCard_Subtitle">{{accountConfig.account.type}}</h6>
            <p>
              <strong>Balance </strong>
              <span>{{currency(accountConfig.account.balance)}}</span>
            </p>
            <p>
              <FormInput
                type="number"
                v-model="accountConfig.settings.rate"
                :min="0"
                :max="1000"
                :step="0.1"
                suffix="%"
                label="Interest Rate"
              />
              <FormInput
                type="number"
                v-model="accountConfig.settings.minPaymentPercent"
                :min="0"
                :max="100"
                :step="0.1"
                suffix="%"
                label="Min. Payment Percentage"
              />
              <FormInput
                type="number"
                v-model="accountConfig.settings.minPaymentAmount"
                :min="0"
                :step="10"
                prefix="$"
                label="Min. Payment Amount"
              />
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
import * as validate from 'validate.js'

import ActionBar from './ActionBar.vue'
import { State, WizardStep } from '@/store/types'
import { BudgetSettings, AccountSettings } from '@/store'
import { formatCurrency, Account, BudgetSummary } from '@/helpers/ynab'
import FormInput from '@/components/FormInput.vue'
import SimpleCard from '@/components/SimpleCard.vue'
import SimpleCardDeck from '@/components/SimpleCardDeck.vue'

interface AccountConfig {
  id: string
  account: Account
  settings: AccountSettings
}

const constraints = {
  rate: {
    presence: true,
    numericality: { greaterThanOrEqualTo: 0 }
  },
  minPaymentPercent: {
    presence: true,
    numericality: { greaterThanOrEqualTo: 0 }
  },
  minPaymentAmount: {
    presence: true,
    numericality: { greaterThanOrEqualTo: 0 }
  }
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
    const accountsConfig: AccountConfig[] = budgetAccounts
      .filter(ba => selectedAccountsIds.indexOf(ba.id) >= 0)
      .map(ba => ({
        id: ba.id,
        account: ba,
        settings: accountsSettings.find(a => a.accountId === ba.id) || {
          accountId: ''
        }
      }))

    return {
      accountsConfig
    }
  },
  computed: {
    currentBudget: function(): BudgetSummary | undefined {
      return this.$store.getters.currentBudget
    },
    isValid: function(): boolean {
      const errors = this.accountsConfig.map(config =>
        validate.validate(config.settings, constraints)
      )

      return errors.filter(e => e != null).length === 0
    }
  },
  methods: {
    currency(value: number) {
      if (!this.currentBudget) {
        return value.toString()
      }

      return formatCurrency(this.currentBudget.currency_format)(value)
    },
    onBack() {
      const previousStep: WizardStep = 'accounts'
      this.$store.commit('saveWizardStep', previousStep)
    },
    onSubmit() {
      if (!this.isValid) {
        return
      }

      console.log('show errors')
    }
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
    margin-bottom: spacing(2);

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

  .Wizard_ActionBar {
    margin-top: 0;
  }
}
</style>

