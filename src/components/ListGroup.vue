<template>
  <div class="listGroup" role="tablist">
    <slot />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'ListGroup'
})
</script>

<style lang="stylus">
.listGroup {
  display: flex;
  flex-direction: column;
  margin-bottom: 0;
  padding-left: 0;
}
</style>


