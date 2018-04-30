import firebase from "firebase/app";
import "firebase/auth";

import { Main } from "./Main.elm";

firebase.initializeApp({
  apiKey: "AIzaSyAQngCWXkRxRk8f6wdM6HVGDQge081Z4Uo",
  authDomain: "snowball-ynab.firebaseapp.com",
  databaseURL: "https://snowball-ynab.firebaseio.com",
  projectId: "snowball-ynab",
  storageBucket: "snowball-ynab.appspot.com",
  messagingSenderId: "803883742504"
});

const googleProvider = new firebase.auth.GoogleAuthProvider();

const app = Main.fullscreen();

const ACCESS_TOKEN_KEY = "accessToken";

app.ports.checkAccessToken.subscribe(() => {
  const accessToken = localStorage.getItem(ACCESS_TOKEN_KEY);
  app.ports.updateAccessToken.send(accessToken);
});

app.ports.requestAccessToken.subscribe(() => {
  firebase
    .auth()
    .signInWithPopup(googleProvider)
    .then(result => {
      const accessToken = result.credential.accessToken;
      console.log(firebase);
      // localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
      // app.ports.updateAccessToken.send(accessToken);
    })
    .catch(err => {
      const errorMessage = error.message;
      alert(errorMessage);
    });
});
