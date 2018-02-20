<template>
  <div class="WizardSetupAccountsInterest">
    <h1>Enter your account interest details</h1>
    <p>
      To calculate your debt snowball we need each of your accounts
      interest details
    </p>
    <form v-on:submit.prevent="onSubmit">
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
import { WizardStep } from '@/store/types'

export default Vue.extend({
  name: 'WizardSetupBudget',
  data() {
    return {}
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
    ActionBar
  }
})
</script>
