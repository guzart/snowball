<template>
  <div class="settings">
    <h1>Settings</h1>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'settings',
  data() {
    return {
      form: {
        apiAccessToken: ''
      }
    }
  },
  methods: {
    onSubmit() {}
  }
})
</script>