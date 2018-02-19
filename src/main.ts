import Vue from 'vue'

import App from './App.vue'
import router from './router'
import store from './store'
import './registerServiceWorker'

import LoaderButton from '@/components/LoaderButton.vue'
import SimpleButton from '@/components/SimpleButton.vue'

Vue.config.productionTip = false

Vue.component('y-simple-button', SimpleButton)
Vue.component('y-loader-button', LoaderButton)

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
