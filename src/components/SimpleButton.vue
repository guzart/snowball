<template>
  <button
    v-bind:class="classObject"
    v-bind:disabled="isDisabled"
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
    size: {
      type: String,
      default: ''
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
      const { size, theme } = this
      const classes = ['btn', `btn-${theme}`]
      if (this.size != '') {
        classes.push(`btn-${size}`)
      }
      return classes
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

  &[disabled] {
    cursor: default;
    filter: grayscale(80%);
    opacity: 0.6;
  }

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

  &-danger {
    color: $negativeRed;
    border-color: alpha($negativeRed, 0.2);

    &:hover:not([disabled]) {
      color: $white;
      background: alpha($negativeRed, 0.8);
    }
  }

  &-cancel {
    color: $black;
    border-color: alpha($black, 0.2);

    &:hover:not([disabled]) {
      color: $white;
      background: alpha($midnightBlue, 0.8);
    }
  }

  &-medium {
    font-size: px2rem(16);
    padding: px2rem(11) px2rem(24);
  }

  &-large {
    background: $everyDollarOrange;
    color: $white;
    font-size: px2rem(20);
    padding: px2rem(20) px2rem(32);

    &:hover:not([disabled]) {
      background: alpha($everyDollarOrange, 0.8);
    }
  }
}
</style>
