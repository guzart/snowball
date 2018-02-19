<template>
  <div>
    <h1>Welcome</h1>
    <p>
      Start by adding your YNAB acess token
    </p>
    <form v-on:submit.prevent="onSubmit">
      <FormInput
        id="setting-api-access-token"
        label="API Access Token"
        v-model="accessToken"
        v-bind:errorMessage="errorMessage"
      />
      <div class="actions">
        <SimpleButton type="button" disabled>Back</SimpleButton>
        <LoaderButton
          theme="primary"
          class="next-button"
          v-bind:disabled="!hasAccessToken"
          v-bind:loading="isBusy"
        >Next</LoaderButton>
      </div>
    </form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import FormInput from '@/components/FormInput.vue'
import LoaderButton from '@/components/LoaderButton.vue'
import SimpleButton from '@/components/SimpleButton.vue'
import { State } from '@/store/mutations'
import { HttpError } from '@/helpers/ynab'

export default Vue.extend({
  name: 'WizardAccessToken',
  data() {
    const state: State = this.$store.state
    return {
      accessToken: state.settings.accessToken,
      errorMessage: '',
      isBusy: false
    }
  },
  computed: {
    hasAccessToken: function(): boolean {
      return this.accessToken.length > 0
    }
  },
  methods: {
    onSubmit() {
      const { accessToken } = this
      this.isBusy = true
      this.$store
        .dispatch('setupAccessToken', accessToken)
        .then(() => {
          this.isBusy = false
          this.errorMessage = ''
        })
        .catch((error: HttpError) => {
          this.isBusy = false
          this.errorMessage =
            error.status === 401
              ? 'This access token is not valid :-('
              : error.message
        })
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
@import '~@/styles/_variables';

.actions {
  display: flex;
  justify-content: space-between;
  margin-top: spacing(4);
}
</style>
