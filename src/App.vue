<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Dashboard</router-link> |
      <router-link to="/settings">Settings</router-link>
    </div>
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

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>
