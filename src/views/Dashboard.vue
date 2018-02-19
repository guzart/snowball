<template>
  <div>
    <WizardAccessToken />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
// import { mapGetters } from 'vuex'
import WizardAccessToken from '@/components/wizard/AccessToken.vue'

export default Vue.extend({
  name: 'home',
  components: {
    WizardAccessToken
  }
  // computed: mapGetters(['isSetup'])
})
</script>
