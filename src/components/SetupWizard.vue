<template>
  <div>
    <SetupAccessToken v-if="wizardStep === 'accessToken'" />
    <SetupBudget v-else-if="wizardStep === 'budget'" />
    <SetupAccounts v-else-if="wizardStep === 'accounts'" />
    <SetupAccountsInterest v-else-if="wizardStep === 'accountsInterest'" />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import SetupAccessToken from '@/components/wizard/SetupAccessToken.vue'
import SetupAccounts from '@/components/wizard/SetupAccounts.vue'
import SetupAccountsInterest from '@/components/wizard/SetupAccountsInterest.vue'
import SetupBudget from '@/components/wizard/SetupBudget.vue'
import { mapState } from 'vuex'

export default Vue.extend({
  name: 'SetupWizard',
  computed: {
    ...mapState(['wizardStep'])
  },
  components: {
    SetupAccessToken,
    SetupAccounts,
    SetupAccountsInterest,
    SetupBudget
  }
})
</script>
