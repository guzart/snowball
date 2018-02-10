<template>
  <div>
    <DebtSnowball v-if="isSetup" />
    <SetupWizard v-else />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { mapGetters } from 'vuex'
import DebtSnowball from '@/components/DebtSnowball.vue'
import SetupWizard from '@/components/SetupWizard.vue'

export default Vue.extend({
  name: 'home',
  components: {
    DebtSnowball,
    SetupWizard
  },
  computed: mapGetters(['isSetup'])
})
</script>
