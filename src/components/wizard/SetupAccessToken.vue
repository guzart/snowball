<template>
  <div>
    <h1>Welcome</h1>
    <p>
      Start by adding your YNAB acess token
    </p>
    <form v-on:submit.prevent="onNext">
      <FormInput
        id="setting-api-access-token"
        label="API Access Token"
        v-model="accessToken"
        v-bind:errorMessage="errorMessage"
      />
      <ActionBar
        v-bind:disableBack="true"
        v-bind:disableNext="!hasAccessToken"
        v-bind:isNextBusy="isBusy"
      />
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import FormInput from '@/components/FormInput.vue'
import { HttpError } from '@/helpers/ynab'
import { State, WizardStep } from '@/store/types'

import ActionBar from './ActionBar.vue'

export default Vue.extend({
  name: 'WizardSetupAccessToken',
  data() {
    const state: State = this.$store.state
    return {
      accessToken: state.settings.accessToken,
      errorMessage: '',
      isBusy: false
    }
  },
  computed: {
    hasAccessToken: function(): boolean {
      return this.accessToken.length > 0
    },
    isDirty: function(): boolean {
      const state = <State>this.$store.state
      const { accessToken } = state.settings
      return this.accessToken !== accessToken
    }
  },
  methods: {
    onNext() {
      const { accessToken } = this
      const nextStep: WizardStep = 'budget'
      const moveToNextStep = () =>
        this.$store.commit('saveWizardStep', nextStep)

      if (!this.isDirty) {
        moveToNextStep()
        return
      }

      this.isBusy = true
      this.$store
        .dispatch('setupAccessToken', accessToken)
        .then(() => {
          this.isBusy = false
          this.errorMessage = ''
          moveToNextStep()
        })
        .catch((error: HttpError) => {
          this.isBusy = false
          this.errorMessage =
            error.status === 401
              ? 'This access token is not valid :-('
              : error.message
        })
    }
  },
  components: {
    ActionBar,
    FormInput
  }
})
</script>
