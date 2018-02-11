<template>
  <div>
    <div>
      <h1>Choose your Budget</h1>
      {{ budgets }}
      <LoaderMessage v-if="loading">Loading available budgets...</LoaderMessage>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import LoaderMessage from '@/components/LoaderMessage.vue'
import { State } from '@/store/mutations'

export default Vue.extend({
  name: 'SetupWizard',
  data() {
    return {
      loading: false
    }
  },
  created() {
    const store = this.$store
    const state: State = store.state
    if (state.budgets.length === 0) {
      this.loading = true
      store
        .dispatch('loadBudgets')
        .then(() => {
          this.loading = false
        })
        .catch(() => {
          this.loading = false
        })
    }
  },
  computed: {
    budgets() {},
    hasBudgets() {
      const state: State = this.$store.state
      return state.budgets.length > 0
    }
  },
  components: {
    LoaderMessage
  }
})
</script>
