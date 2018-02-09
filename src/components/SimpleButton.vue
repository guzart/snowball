<template>
  <button v-bind:class="classObject"><slot /></button>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'SimpleButton',
  computed: {
    classObject(): any {
      return {
        btn: true,
        [`btn-${this.theme}`]: true
      }
    }
  },
  props: {
    theme: {
      type: String,
      default: 'default'
    }
  }
})
</script>

<style lang="stylus" scoped>
@import '../styles/_variables';

.btn {
  border-radius: px2rem(4);
  font-size: px2rem(14);
  font-weight: bold;
  padding: px2rem(9) px2rem(16);
  cursor: pointer;
}
</style>
