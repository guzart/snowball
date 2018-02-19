<template>
  <div class="settings">
    <h2>Access Settings</h2>
    <form v-on:submit.prevent="onSubmit">
      <ul>
        <li is="FormInput" id="setting-api-access-token"
          label="API Access Token"
          v-model="settingsScratchPad.accessToken"
        />
      </ul>
      <y-simple-button type="button">Discard</y-simple-button>
      <y-simple-button theme="primary">Save Changes</y-simple-button>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { mapState } from 'vuex'
import FormInput from '@/components/FormInput.vue'
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
    FormInput
  }
})
</script>

<style lang="stylus" scoped>
ul {
  list-style-type: none;
  padding-left: 0;
}
</style>
