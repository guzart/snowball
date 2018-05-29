import * as talkback from "talkback";
import * as dotenv from "dotenv";

dotenv.config();

const port = parseInt(String(process.env["TAPES_SERVER_PORT"]), 10);
const server = talkback({
  host: "https://api.youneedabudget.com/v1",
  port,
  ignoreHeaders: [
    "authorization",
    "cache-control",
    "date",
    "etag",
    "if-none-match",
    "pragma",
    "x-rate-limit",
    "x-request-id",
    "x-runtime"
  ]
});

server.start(() => console.log(`Talkback started on http://localhost:${port}`));
