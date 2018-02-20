<template>
  <div class="SimpleCardDeck">
    <slot />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'SimpleCardDeck'
})
</script>

<style lang="stylus">
.SimpleCardDeck {
  display: flex;
  flex-flow: row wrap;
  margin-left: -15px;
  margin-right: -15px;

  > .SimpleCard {
    display: flex;
    flex: 1 0 0%;
    flex-direction: column;
    margin-left: 15px;
    margin-bottom: 0;
    margin-right: 15px;
  }
}
</style>
