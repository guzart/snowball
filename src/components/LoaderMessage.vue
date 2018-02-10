<template>
  <p>
    <RegularIcon icon="spinner" spin pulse size="lg" />
    &nbsp;&nbsp;
    <slot />
  </p>
</template>

<script lang="ts">
import Vue from 'vue'
import RegularIcon from '@/components/RegularIcon.vue'

export default Vue.extend({
  name: 'LoaderMessage',
  components: {
    RegularIcon
  }
})
</script>

