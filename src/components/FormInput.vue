<template>
<div :class="classObject">
  <label :for="id">{{label}}</label>
  <input
    v-if="!isInputGroup"
    ref="input"
    :type="type"
    :id="id"
    :placeholder="placeholder"
    :disabled="disabled"
    :value="value"
    :min="min"
    :max="max"
    :step="step"
    @input="updateValue($event.target.value)"
  />
  <div v-else class="input-group">
    <div v-if="prefix" class="input-group-prepend">
      <span class="input-group-text">{{prefix}}</span>
    </div>
    <input
      v-if="isInputGroup"
      ref="input"
      :type="type"
      :id="id"
      :placeholder="placeholder"
      :disabled="disabled"
      :value="value"
      :min="min"
      :max="max"
      :step="step"
      @input="updateValue($event.target.value)"
    />
    <div v-if="suffix" class="input-group-append">
      <span class="input-group-text">{{suffix}}</span>
    </div>
  </div>
  <div v-if="successMessage" class="mod-message" >
    <SimpleIcon name="success" />{{ successMessage }}
  </div>
  <div v-else-if="errorMessage" class="mod-message">
    <SimpleIcon name="warning" />{{ errorMessage }}
  </div>
</div>
</template>

<script lang="ts">
import isEmpty from 'lodash-es/isEmpty'
import Vue from 'vue'
import SimpleIcon from '@/components/SimpleIcon.vue'

export default Vue.extend({
  name: 'FormInput',
  props: {
    disabled: Boolean,
    errorMessage: String,
    id: {
      type: String,
      default: () => `input-${Math.ceil(Math.random() * 1000)}`
    },
    label: String,
    max: Number,
    min: Number,
    placeholder: String,
    prefix: String,
    step: Number,
    successMessage: String,
    suffix: String,
    type: {
      type: String,
      default: 'text'
    },
    value: [String, Number]
  },
  computed: {
    classObject(): any {
      return {
        'form-input': true,
        'has-error': !isEmpty(this.errorMessage)
      }
    },
    isInputGroup(): boolean {
      return !!this.prefix || !!this.suffix
    }
  },
  methods: {
    updateValue(value: string) {
      const input = this.$refs.input as HTMLInputElement
      input.value = value
      this.$emit('input', value)
    }
  },
  components: {
    SimpleIcon
  }
})
</script>


<style lang="stylus">
@import '~@/styles/_variables';

.form-input {
  display: flex;
  flex-direction: column;
  text-align: left;

  label {
    font-size: px2rem(14);
    font-weight: 900;
    line-height: px2rem(21);
  }

  input {
    color: $midnightBlueDark;
    border: 1px solid $gray;
    border-radius: $borderRadius;
    font-size: px2rem(16);
    padding: px2rem(8);

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

  &.has-error {
    input {
      border-color: $negativeRed;
    }

    .mod-message {
      color: $negativeRed;
    }
  }

  .input-group {
    align-items: stretch;
    display: flex;
    flex-wrap: wrap;
    position: relative;
    width: 100%;

    input {
      flex: 1;
    }

    input:not(:first-child) {
      border-bottom-left-radius: 0;
      border-top-left-radius: 0;
    }

    input:not(:last-child) {
      border-bottom-right-radius: 0;
      border-top-right-radius: 0;
    }
  }

  .input-group-append, .input-group-prepend {
    display: flex;
  }

  .input-group-prepend {
    margin-right: -1px;

    .input-group-text {
      border-bottom-right-radius: 0;
      border-top-right-radius: 0;
    }
  }

  .input-group-append {
    margin-left: -1px;

    .input-group-text {
      border-bottom-left-radius: 0;
      border-top-left-radius: 0;
    }
  }

  .input-group-text {
    align-items: center;
    background-color: $mercury;
    border-radius: $borderRadius;
    border: 1px solid $gray;
    display: flex;
    font-size: 1rem;
    line-height: 1.5;
    margin-bottom: 0;
    padding: 0.375rem 0.75rem;
    text-align: center;
    white-space: nowrap;
  }
}
</style>
