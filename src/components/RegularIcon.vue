<script lang="ts">
import Vue from 'vue'
import FontAwesomeIcon from '@fortawesome/vue-fontawesome'
import fontawesome from '@fortawesome/fontawesome'
import { faSpinner } from '@fortawesome/fontawesome-free-solid'

fontawesome.library.add(faSpinner)

// https://github.com/FortAwesome/vue-fontawesome

export default Vue.extend({
  name: 'RegularIcon',
  extends: FontAwesomeIcon,
  props: {
    icon: String
  }
})
</script>
