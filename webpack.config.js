require("dotenv").config();

const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const isProduction = process.env["NODE_ENV"] === "production";

module.exports = {
  mode: isProduction ? "production" : "development",

  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            debug: !isProduction,
            warn: !isProduction
          }
        }
      }
    ]
  },

  plugins: [
    new webpack.DefinePlugin({
      YNAB_CLIENT_ID: JSON.stringify(process.env["YNAB_CLIENT_ID"])
    }),
    new HtmlWebpackPlugin({
      inject: "body",
      template: "src/index.html",
      favicon: "src/favicon.ico"
    })
  ],

  devServer: {
    https: true,
    inline: true,
    stats: "errors-only"
  }
};
