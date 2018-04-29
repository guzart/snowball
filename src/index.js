import firebase from "firebase/app";
import "firebase/auth";

import Elm from "./Main.elm";

firebase.initializeApp({
  apiKey: "AIzaSyAQngCWXkRxRk8f6wdM6HVGDQge081Z4Uo",
  authDomain: "snowball-ynab.firebaseapp.com",
  databaseURL: "https://snowball-ynab.firebaseio.com",
  projectId: "snowball-ynab",
  storageBucket: "snowball-ynab.appspot.com",
  messagingSenderId: "803883742504"
});

const googleProvider = new firebase.auth.GoogleAuthProvider();

const app = Elm.Main.fullscreen();

app.ports.checkAccessToken.subscribe(() => {
  const accessToken = localStorage.getItem("accessToken");
  console.log(accessToken);
  app.ports.updateAccessToken.send(accessToken);
});

app.ports.requestAccessToken.subscribe(() => {
  firebase
    .auth()
    .signInWithPopup(googleProvider)
    .then(result => {
      // const user = result.user;
      const accessToken = result.credential.accessToken;
      app.ports.updateAccessToken.send(accessToken);
    })
    .catch(err => {
      const errorCode = error.code;
      const errorMessage = error.message;
      const email = error.email;
      const credential = error.credential;
      alert(errorMessage);
    });
});
