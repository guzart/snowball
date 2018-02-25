<template>
  <div id="app">
    <router-view />
  </div>
</template>

<style lang="stylus">
@import url('http://fonts.googleapis.com/css?family=Lato');
@import '~bootstrap/dist/css/bootstrap-reboot.css';
@import '~@/styles/_grid';
@import '~@/styles/_typography';

body {
  color: $black;
  font-family: 'Lato', sans-serif;
  font-size: px2rem(14);
  line-height: 1.5;
  padding-bottom: spacing(2);
}

h1 {
  display();
  font-weight: bold;
}

h2 {
  headline();
  font-weight: bold;
}

#app {
  text-align: center;
  makeContainer();
  makeContainerMaxWidths();
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
