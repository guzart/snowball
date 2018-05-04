import * as moment from "moment";
import "bootstrap/js/src/modal";

import config from "./config";
import { Main } from "./Main.elm";
import "./icons";
import "./index.scss";

type Dictionary = { [key: string]: string };

const ACCESS_TOKEN_STORAGE_KEY = "accessToken";
const ACCESS_TOKEN_EXPIRES_STORAGE_KEY = "accessTokenExpiresAt";

// on page load, check for YNAB auth callback
const urlHash = window.location.hash;
if (urlHash) {
  const hashData: Dictionary = urlHash
    .substr(1)
    .split("&")
    .map(v => v.split("="))
    .reduce(
      (acc, tuple) => {
        const [key, value] = tuple;
        acc[key] = value;
        return acc;
      },
      {} as Dictionary
    );

  const { access_token, expires_in } = hashData;
  if (access_token && expires_in) {
    // store data
    const expiresAt = moment()
      .add(expires_in, "seconds")
      .toISOString();
    localStorage.setItem(ACCESS_TOKEN_EXPIRES_STORAGE_KEY, expiresAt);
    localStorage.setItem(ACCESS_TOKEN_STORAGE_KEY, access_token);

    // clear access token response
    window.location.hash = "";
  }
}

function logOut() {
  [ACCESS_TOKEN_EXPIRES_STORAGE_KEY, ACCESS_TOKEN_STORAGE_KEY].forEach(k =>
    localStorage.removeItem(k)
  );
  app.ports.onAccessTokenChange.send(null);
  window.location.hash = "";
}

// Initialize app

const app = Main.fullscreen();

app.ports.disconnect.subscribe(logOut);

app.ports.readAccessToken.subscribe(() => {
  const expiresAt = localStorage.getItem(ACCESS_TOKEN_EXPIRES_STORAGE_KEY);
  const accessToken = localStorage.getItem(ACCESS_TOKEN_STORAGE_KEY);
  if (accessToken && expiresAt && moment(expiresAt).isAfter()) {
    app.ports.onAccessTokenChange.send(accessToken);
  } else {
    logOut();
  }
});

app.ports.requestAccessToken.subscribe(() => {
  const redirectUrl = window.location.origin;
  const clientId = config.ynabClientId;
  const requestUrl = `https://app.youneedabudget.com/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUrl}&response_type=token`;
  window.location.replace(requestUrl);
});
