<template>
  <div class="settings">
    <h1>Settings</h1>
    <form v-on:submit.prevent="onSubmit">
      <ul>
        <li is="FormInput" id="setting-api-access-token-2"
          label="API Access Token"
          v-bind:value="settings.apiAccessToken"
        />
      </ul>
      <SimpleButton type="button">Discard</SimpleButton>
      <SimpleButton>Save Changes</SimpleButton>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import FormInput from '@/components/FormInput.vue'
import SimpleButton from '@/components/SimpleButton.vue'

export default Vue.extend({
  name: 'settings',
  data() {
    return {
      settings: {
        apiAccessToken: ''
      }
    }
  },
  methods: {
    onSubmit() {
      console.log(this.settings.apiAccessToken)
    }
  },
  components: {
    FormInput,
    SimpleButton
  }
})
</script>

<style lang="stylus" scoped>
ul {
  list-style-type: none;
  padding-left: 0;
}
</style>
