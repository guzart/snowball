<template>
  <div class="Wizard_ActionBar">
    <y-simple-button
      type="button"
      v-bind:disabled="disableBack"
      v-on:click="onBack"
    >Back</y-simple-button>
    <y-loader-button
      theme="primary"
      v-bind:disabled="disableNext"
      v-bind:loading="isNextBusy"
      v-on:click="onNext"
    >Next</y-loader-button>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  props: {
    disableBack: Boolean,
    disableNext: Boolean,
    isNextBusy: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    onBack() {
      this.$emit('back')
    },
    onNext() {
      this.$emit('next')
    }
  }
})
</script>

<style lang="stylus">
@import '~@/styles/_variables';

.Wizard_ActionBar {
  display: flex;
  justify-content: space-between;
  margin-top: spacing(4);
}
</style>


