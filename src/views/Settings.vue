<template>
  <div class="settings">
    <h1>Settings</h1>
    <form v-on:submit.prevent="onSubmit">
      <ul>
        <li is="FormInput" id="setting-api-access-token"
          label="API Access Token"
          v-model="settings.apiAccessToken"
        />
      </ul>
      <SimpleButton type="button">Discard</SimpleButton>
      <LoaderButton v-bind:loading="saving" theme="primary">Save Changes</LoaderButton>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import FormInput from '@/components/FormInput.vue'
import LoaderButton from '@/components/LoaderButton.vue'
import SimpleButton from '@/components/SimpleButton.vue'
import { State } from '@/store'

export default Vue.extend({
  name: 'settings',
  data() {
    const state: State = this.$store.state
    return {
      saving: false,
      settings: {
        apiAccessToken: state.settings.apiAccessToken
      }
    }
  },
  methods: {
    onSubmit() {
      this.$store.commit('saveSettings', this.settings)
    }
  },
  components: {
    FormInput,
    LoaderButton,
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
