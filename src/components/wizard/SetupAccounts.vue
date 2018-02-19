<template>
  <div>
    <h1>Choose your accounts</h1>
    <p>
      Choose the accounts you want to work with
    </p>
    <span>{{budgetAccounts}}</span>
    <form v-on:submit.prevent="onSubmit">
      <div class="actions">
        <y-simple-button type="button">Back</y-simple-button>
        <y-loader-button
          theme="primary"
          v-bind:disabled="!hasSelectedBudget"
        >Next</y-loader-button>
      </div>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { State } from '@/store/mutations'
import { mapState } from 'vuex'

export default Vue.extend({
  name: 'WizardSetupBudget',
  data() {
    const { settings: { budgets: budgetsSettings } } = <State>this.$store.state
    const selectedBudgetId =
      budgetsSettings.length > 0 ? budgetsSettings[0].budgetId : ''

    return {
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
    onSubmit() {
      const { selectedBudgetId } = this
      this.$store.commit('saveBudgetSettings', selectedBudgetId)
    }
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
