<template>
  <div class="SimpleCard">
    <slot />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'SimpleCard'
})
</script>

<style lang="stylus">
@import '~@/styles/_variables';

.SimpleCard {
  background-clip: border-box;
  background-color: $white;
  border-radius: $borderRadius;
  border: 1px solid alpha($black, 0.25);
  display: flex;
  flex-direction: column;
  min-width: 0;
  position: relative;
  text-align: left;
  word-wrap: break-word;

  &_Body {
    flex: 1 1 auto;
    padding: 1.25rem;
  }

  &_Title {
    font-size: 1.25rem;
    margin: 0 0 0.75rem 0;
  }

  &_Subtitle {
    color: $doveGray;
    font-size: 1rem;
    margin: -0.375rem 0 0.5rem;
  }
}
</style>


