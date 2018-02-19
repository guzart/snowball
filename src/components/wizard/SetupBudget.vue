<template>
  <div>
    <h1>Choose a budget</h1>
    <p>
      Choose the budget you want to work with
    </p>
    <form v-on:submit.prevent="onSubmit">
      <ListGroup>
        <ListGroupItem
          v-for="budget in userBudgets"
          v-bind:key="budget.id"
          v-bind:active="budget.id === selectedBudgetId"
          v-on:click="selectedBudgetId = budget.id"
        >
          <div>
            <h5>{{budget.name}}</h5>
            <small>{{formatLastModified(budget.last_modified_on)}}</small>
          </div>
          <p>
            Budgeted months: {{formatMonth(budget.first_month)}} &ndash; {{formatMonth(budget.last_month)}}
          </p>
        </ListGroupItem>
      </ListGroup>
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
import * as moment from 'moment'
import Vue from 'vue'
import { mapState } from 'vuex'
import ListGroup from '@/components/ListGroup.vue'
import ListGroupItem from '@/components/ListGroupItem.vue'
import ActionBar from '@/components/wizard/ActionBar.vue'
import { HttpError } from '@/helpers/ynab'
import { State, WizardStep } from '@/store/mutations'

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
    formatLastModified(lastModifiedOn: string) {
      return moment(lastModifiedOn, moment.ISO_8601).format(
        'dddd, MMMM Do YYYY, h:mm:ss a'
      )
    },
    formatMonth(month: string) {
      return moment(month, 'Y-MM-DD').format('MMMM Y')
    },
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
    ActionBar,
    ListGroup,
    ListGroupItem
  }
})
</script>

<style lang="stylus">
</style>
