import * as talkback from "talkback";
import * as dotenv from "dotenv";

dotenv.config();

const port = parseInt(String(process.env["TAPES_SERVER_PORT"]), 10);
const server = talkback({
  host: process.env["YNAB_API_ENDPOINT"],
  port,
  ignoreHeaders: ["authorization"]
});

server.start(() => console.log(`Talkback started on http://localhost:${port}`));
