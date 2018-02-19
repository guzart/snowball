<template>
  <div>
    <h1>Choose your accounts</h1>
    <p>
      Choose the accounts you want to work with
    </p>
    <span>{{budgetAccounts}}</span>
    <form v-on:submit.prevent="onSubmit">
      <ActionBar
        v-bind:disableNext="!hasSelectedBudget"
      />
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { mapState } from 'vuex'
import { State } from '@/store/mutations'
import ActionBar from './ActionBar.vue'

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
  },
  components: {
    ActionBar
  }
})
</script>
