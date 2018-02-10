<template>
  <div>
    <div>
      <h1>Choose your Budget</h1>
      <LoaderMessage>Loading available budgets...</LoaderMessage>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import LoaderMessage from '@/components/LoaderMessage.vue'

export default Vue.extend({
  name: 'SetupWizard',
  components: {
    LoaderMessage
  }
})
</script>
