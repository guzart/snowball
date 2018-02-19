<script lang="ts">
import { create } from 'ladda'
import SimpleButton from '@/components/SimpleButton.vue'

interface ILaddaButton {
  start(): ILaddaButton
  startAfter(delay: number): ILaddaButton
  stop(): ILaddaButton
  toggle(): ILaddaButton
  setProgress(progress: number): ILaddaButton
  enable(): ILaddaButton
  disable(): ILaddaButton
  isLoading(): boolean
  remove(): void
}

interface Data {
  ladda: ILaddaButton | null
}

export default SimpleButton.extend({
  name: 'LoaderButton',
  data() {
    return {
      ladda: null
    } as Data
  },
  props: {
    loading: {
      type: Boolean,
      default: false
    }
  },
  mounted() {
    this.$el.dataset['style'] = 'zoom-in'
    this.ladda = create(this.$el)
  },
  updated() {
    const { loading, ladda } = this
    this.internalDisabled = loading
    ladda && (loading ? ladda.start() : ladda.stop())
  },
  beforeDestroy() {
    const { ladda } = this
    ladda && ladda.remove()
  }
})
</script>

<style lang="stylus">
@import '~ladda/dist/ladda-themeless.min.css';
</style>

