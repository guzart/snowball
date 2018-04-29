import Elm from "./Main.elm";

const app = Elm.Main.fullscreen();

app.ports.checkAccessToken.subscribe(function() {
  const accessToken = localStorage.getItem("accessToken");
  app.ports.receiveAccessToken.send(accessToken);
});
