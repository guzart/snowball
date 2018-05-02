import settings from "./settings";
import { Main } from "./Main.elm";
import "./index.scss";

const ACCESS_TOKEN_STORAGE_KEY = "accessToken";

// Handle YNAB authentication callback
const urlHash = window.location.hash;
if (urlHash) {
  const hashData = urlHash
    .substr(1)
    .split("&")
    .map(v => v.split("="))
    .reduce((acc, tuple) => {
      const [key, value] = tuple;
      acc[key] = value;
      return acc;
    }, {});

  const { access_token, expires_in } = hashData;
  if (access_token && expires_in) {
    localStorage.setItem(ACCESS_TOKEN_STORAGE_KEY, access_token);
  }
}

// Initialize app

const app = Main.fullscreen();

app.ports.readAccessToken.subscribe(() => {
  const accessToken = localStorage.getItem(ACCESS_TOKEN_STORAGE_KEY);
  if (accessToken) {
    // TODO: Validate token is active
  }

  app.ports.updateAccessToken.send(accessToken);
});

app.ports.requestAccessToken.subscribe(() => {
  const redirectUrl = window.location.toString();
  const clientId = settings.ynabClientId;
  const requestUrl = `https://app.youneedabudget.com/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUrl}&response_type=token`;
  window.location.href = requestUrl;
});
