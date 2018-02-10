<template>
  <button
    v-bind:class="classObject"
  ><slot /></button>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'SimpleButton',
  props: {
    disabled: {
      type: Boolean,
      default: false
    },
    theme: {
      type: String,
      default: 'default'
    }
  },
  data() {
    return {
      internalDisabled: false
    }
  },
  computed: {
    classObject(): any {
      return {
        btn: true,
        [`btn-${this.theme}`]: true
      }
    },
    isDisabled(): boolean {
      return this.disabled || this.internalDisabled
    }
  }
})
</script>

<style lang="stylus">
@import '../styles/_variables';

.btn {
  border: solid 1px $gray;
  border-radius: px2rem(4);
  font-size: px2rem(14);
  font-weight: bold;
  padding: px2rem(9) px2rem(16);
  position: relative;
  cursor: pointer;

  &:not([disabled]):active {
    top: 2px;
  }

  &-default {
    &:hover:not([disabled]) {
      background-color: $mercury;
    }
  }

  &-primary {
    background-color: $bahamaBlue;
    border-color: alpha($bahamaBlue, 0.2);
    color: $white;

    &:hover:not([disabled]) {
      background-color: alpha($bahamaBlue, 0.8);
    }
  }
}
</style>
