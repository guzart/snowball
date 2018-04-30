import firebase from "firebase/app";
import "firebase/auth";
import "firebase/firestore";

import settings from "./settings";
import { Main } from "./Main.elm";

// window.location.hash
// #access_token=xxx&token_type=bearer&expires_in=7200

const app = Main.fullscreen();

// TODO: Move values to settings file
firebase.initializeApp({
  apiKey: "AIzaSyAQngCWXkRxRk8f6wdM6HVGDQge081Z4Uo",
  authDomain: "snowball-ynab.firebaseapp.com",
  databaseURL: "https://snowball-ynab.firebaseio.com",
  projectId: "snowball-ynab",
  storageBucket: "snowball-ynab.appspot.com",
  messagingSenderId: "803883742504"
});

const ACCESS_TOKEN_KEY = "accessToken";
const googleProvider = new firebase.auth.GoogleAuthProvider();
const auth = firebase.auth();
const db = firebase.firestore();
db.settings({ timestampsInSnapshots: true });

auth.onAuthStateChanged(fetchUserToken);
function fetchUserToken(user) {
  db
    .collection("users")
    .doc(user.uid)
    .get()
    .then(doc => {
      const data = doc.data();
      if (data && data.accessToken) {
        localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
        updateAccessToken(accessToken);
      }
    })
    .catch(error => alert(error));
}

function updateAccessToken(accessToken) {
  app.ports.updateAccessToken.send(accessToken);
}

app.ports.checkAccessToken.subscribe(() => {
  const accessToken = localStorage.getItem(ACCESS_TOKEN_KEY);
  if (!accessToken && auth.currentUser) {
    fetchUserToken(auth.currentUser);
  } else {
    updateAccessToken(accessToken);
  }
});

app.ports.requestAccessToken.subscribe(() => {
  auth
    .signInWithPopup(googleProvider)
    .then(result => {
      const redirectUrl = window.location.toString();
      const clientId = settings.ynabClientId;
      const requestUrl = `https://app.youneedabudget.com/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUrl}&response_type=token`;
      window.location.href = requestUrl;
    })
    .catch(err => {
      const errorMessage = error.message;
      alert(errorMessage);
    });
});
