<template>
  <component
    v-bind:is="selectable ? 'a' : 'div'"
    v-bind:class="classObject"
    v-on:click.prevent="onClick" v-on:keydown.down="onNext" v-on:keydown.up="onPrevious"
    href="#" role="button"
  >
    <slot />
  </component>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'ListGroupItem',
  props: {
    active: {
      type: Boolean,
      default: false
    },
    selectable: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    classObject: function(): Object {
      const { active } = this
      return {
        ListGroup_Item: true,
        active
      }
    }
  },
  methods: {
    onClick() {
      this.$emit('click')
    },
    onNext() {
      this.$emit('next')
    },
    onPrevious() {
      this.$emit('previous')
    }
  }
})
</script>

<style lang="stylus">
@import '~@/styles/_shadows';
@import '~@/styles/_variables';

.ListGroup_Item {
  border: 1px solid alpha($black, 0.25);
  background-color: $white;
  color: $black;
  display: block;
  margin-bottom: -1px;
  padding: 0.75rem 1.25rem;
  position: relative;
  text-decoration: none;

  &.active {
    border-color: $bahamaBlue;
    z-index: 2;
    shadow(8);

    &:hover {
      background-color: $white;
      z-index: 2;
    }
  }

  &:hover {
    background-color: $alabasterGray;
    color: $midnightBlueDark;
    text-decoration: none;
    z-index: 1;
  }

  &:first-child {
    border-top-left-radius: $borderRadius;
    border-top-right-radius: $borderRadius;
  }

  &:last-child {
    border-bottom-left-radius: $borderRadius;
    border-bottom-right-radius: $borderRadius;
  }
}
</style>

