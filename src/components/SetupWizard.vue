<template>
  <div>
    <SetupAccessToken v-if="wizardStep === 'accessToken'" />
    <SetupBudget v-else-if="wizardStep === 'budget'" />
    <SetupAccounts v-else-if="wizardStep === 'accounts'" />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import SetupAccessToken from '@/components/wizard/SetupAccessToken.vue'
import SetupAccounts from '@/components/wizard/SetupAccounts.vue'
import SetupBudget from '@/components/wizard/SetupBudget.vue'
// import { State } from '@/store/mutations'
import { mapState } from 'vuex'

export default Vue.extend({
  name: 'SetupWizard',
  computed: {
    ...mapState(['wizardStep'])
  },
  components: {
    SetupAccessToken,
    SetupAccounts,
    SetupBudget
  }
})
</script>
