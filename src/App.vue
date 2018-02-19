<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<style lang="stylus">
@import url('http://fonts.googleapis.com/css?family=Lato');
@import './styles/_variables';
@import './styles/_typography';

#app {
  @extend .container;
  text-align: center;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
