<template>
  <div>
    <SetupWizard v-if="wizardStep != 'complete'" />
    <DebtCharts v-else />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import DebtCharts from '@/components/DebtCharts.vue'
import SetupWizard from '@/components/SetupWizard.vue'
import { State, WizardStep } from '@/store/types'

export default Vue.extend({
  name: 'Dashboard',
  computed: {
    wizardStep: function(): WizardStep {
      const state = <State>this.$store.state
      return state.wizardStep
    }
  },
  components: {
    DebtCharts,
    SetupWizard
  }
})
</script>
