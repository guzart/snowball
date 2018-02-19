<template>
  <div>
    <DebtSnowball />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
// import { mapGetters } from 'vuex'
import DebtSnowball from '@/components/DebtSnowball.vue'

export default Vue.extend({
  name: 'home',
  components: {
    DebtSnowball
  }
  // computed: mapGetters(['isSetup'])
})
</script>
