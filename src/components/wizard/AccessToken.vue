<template>
  <div>
    <h1>Welcome</h1>
    <p>
      Start by adding your YNAB acess token
    </p>
    <form v-on:submit.prevent="onSubmit">
      <FormInput id="setting-api-access-token"
        label="API Access Token"
        v-model="accessToken"
      />
      <div class="actions">
        <SimpleButton type="button" disabled>Back</SimpleButton>
        <SimpleButton theme="primary" class="next-button">Next</SimpleButton>
      </div>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import FormInput from '@/components/FormInput.vue'
import SimpleButton from '@/components/SimpleButton.vue'

export default Vue.extend({
  name: 'WizardAccessToken',
  data() {
    return {
      accessToken: ''
    }
  },
  components: {
    FormInput,
    SimpleButton
  }
})
</script>


<style lang="stylus" scoped>
@import '~@/styles/_variables';

.actions {
  display: flex;
  justify-content: space-between;
  margin-top: spacing(4);
}
</style>
