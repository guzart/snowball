<template>
  <div>
    <SetupWizard />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import SetupWizard from '@/components/SetupWizard.vue'

export default Vue.extend({
  name: 'home',
  components: {
    SetupWizard
  }
})
</script>
