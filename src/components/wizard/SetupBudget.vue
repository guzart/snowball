<template>
  <div>
    <h1>Choose a budget</h1>
    <p>
      Choose the budget you want to work with
    </p>
    <form v-on:submit.prevent="onSubmit">
      <span>{{userBudgets}}</span>
      <ActionBar
        v-bind:disableBack="false"
        v-bind:disableNext="!hasSelectedBudget"
        v-bind:isNextBusy="isBusy"
        v-on:back="onBack"
      />
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import ActionBar from '@/components/wizard/ActionBar.vue'
import { State, WizardStep } from '@/store/mutations'
import { mapState } from 'vuex'
import { HttpError } from '@/helpers/ynab'

export default Vue.extend({
  name: 'WizardSetupBudget',
  data() {
    const { settings: { budgets: budgetsSettings } } = <State>this.$store.state
    const selectedBudgetId =
      budgetsSettings.length > 0 ? budgetsSettings[0].budgetId : ''

    return {
      errorMessage: '',
      isBusy: false,
      selectedBudgetId
    }
  },
  computed: {
    hasSelectedBudget: function(): boolean {
      return this.selectedBudgetId !== ''
    },
    ...mapState(['userBudgets'])
  },
  methods: {
    onBack() {
      const prevStep: WizardStep = 'accessToken'
      this.$store.commit('saveWizardStep', prevStep)
    },
    onSubmit() {
      const { selectedBudgetId } = this
      this.isBusy = true
      this.$store
        .dispatch('setupSelectedBudget', selectedBudgetId)
        .then(() => {
          this.isBusy = false
          this.errorMessage = ''
        })
        .catch((error: HttpError) => {
          this.isBusy = false
          this.errorMessage = error.message
        })
    }
  },
  components: {
    ActionBar
  }
})
</script>


<style lang="stylus" scoped>
@import '~@/styles/_variables';

.actions {
  display: flex;
  justify-content: space-between;
  margin-top: spacing(4);
}
</style>
