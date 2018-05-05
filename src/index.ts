import * as moment from "moment";
import "bootstrap/js/src/modal";

import { apiUrl, clientId } from "./config";
import { Main } from "./Main.elm";
import "./icons";
import "./index.scss";

type Dictionary = { [key: string]: string };

const ACCESS_TOKEN_EXPIRES_STORAGE_KEY = "accessTokenExpiresAt";
const SESSION_STORAGE_KEY = "session";

// helper functions

function loadSession() {
  const expiresAt = localStorage.getItem(ACCESS_TOKEN_EXPIRES_STORAGE_KEY);
  const session = localStorage.getItem(SESSION_STORAGE_KEY);
  if (session && expiresAt && moment(expiresAt).isAfter()) {
    return JSON.parse(session);
  }

  return null;
}

// Initialize app

const flags = JSON.stringify({ apiUrl, session: loadSession() });
const app = Main.fullscreen(flags);

app.ports.requestAccessToken.subscribe(() => {
  const redirectUrl = window.location.origin;
  const requestUrl = `https://app.youneedabudget.com/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUrl}&response_type=token`;
  window.location.replace(requestUrl);
});

app.ports.saveSession.subscribe((serializedSession: string) => {
  console.log(serializedSession);
  localStorage.setItem(SESSION_STORAGE_KEY, serializedSession);
});

// check for YNAB auth callback, access token is in url hash
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
    const expiresAt = moment()
      .add(expires_in, "seconds")
      .toISOString();
    localStorage.setItem(ACCESS_TOKEN_EXPIRES_STORAGE_KEY, expiresAt);
    app.ports.onAccessTokenChange.send(access_token);
  }

  // window.location.hash = "";
}
