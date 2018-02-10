<template>
<div class="form-input">
  <label v-bind:for="id">{{label}}</label>
  <input
    ref="input"
    v-bind:type="type"
    v-bind:id="id"
    v-bind:placeholder="placeholder"
    v-bind:disabled="disabled"
    v-bind:value="value"
    v-on:input="updateValue($event.target.value)"
  />
  <div v-if="successMessage" class="mod-message" >
    <SimpleIcon name="success" />{{ successMessage }}
  </div>
  <div v-else-if="errorMessage" class="mod-message">
    <SimpleIcon name="warning" />{{ errorMessage }}
  </div>
</div>
</template>

<script lang="ts">
import Vue from 'vue'
import SimpleIcon from '@/components/SimpleIcon.vue'

export default Vue.extend({
  name: 'FormInput',
  props: {
    disabled: Boolean,
    errorMessage: String,
    id: String,
    label: String,
    placeholder: String,
    successMessage: String,
    type: {
      type: String,
      default: 'text'
    },
    value: [String, Number]
  },
  components: {
    SimpleIcon
  },
  methods: {
    updateValue(value: string) {
      const input = this.$refs.input as HTMLInputElement
      input.value = value
      this.$emit('input', value)
    }
  }
})
</script>


<style lang="stylus">
@import '../styles/_variables';

.form-input {
  display: flex;
  flex-direction: column;
  text-align: left;

  label {
    // width: 100%;
    font-size: px2rem(14);
    font-weight: bold;
    line-height: px2rem(21);
  }

  input {
    // width: 100%;
    color: $midnightBlueDark;
    border: 1px solid $gray;
    border-radius: $borderRadius;
    padding: px2rem(8);
    font-size: px2rem(16);

    &:hover {
      border-color: $bahamaBlue;
    }

    &:focus {
      border-color: #85c3e9; // TODO: Needs a color name
      outline: none;
    }
  }

  &.is-disabled {
    input {
      border-color: #e9ebee; // TODO: needs a color name
      background-color: #e9ebee; // TODO: needs a color name
      color: #b6bbc2; // TODO: needs a color name
    }
  }

  &.mod-success {
    input {
      border-color: $positiveGreen;
    }

    .ynab-new-icon {
      fill: $positiveGreen;
    }

    .mod-message {
      color: $positiveGreen;
    }
  }

  &.mod-error {
    input {
      border-color: $negativeRed;
    }

    .ynab-new-icon {
      fill: $negativeRed;
    }

    .mod-message {
      color: $negativeRed;
    }
  }
}
</style>
