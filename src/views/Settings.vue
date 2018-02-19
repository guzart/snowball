<template>
  <div class="settings">
    <h2>Access Settings</h2>
    <form v-on:submit.prevent="onSubmit">
      <ul>
        <li is="FormInput" id="setting-api-access-token"
          label="API Access Token"
          v-model="settingsScratchPad.apiAccessToken"
        />
      </ul>
      <SimpleButton type="button">Discard</SimpleButton>
      <SimpleButton theme="primary">Save Changes</SimpleButton>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { mapState } from 'vuex'
import FormInput from '@/components/FormInput.vue'
import LoaderButton from '@/components/LoaderButton.vue'
import SimpleButton from '@/components/SimpleButton.vue'
import { State } from '@/store'

export default Vue.extend({
  name: 'settings',
  data() {
    const { settings } = <State>this.$store.state
    return {
      loadingBudgets: false,
      settingsScratchPad: JSON.parse(JSON.stringify(settings))
    }
  },
  computed: mapState(['settings']),
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
