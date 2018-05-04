require("dotenv").config();

const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const isProduction = process.env["NODE_ENV"] === "production";

module.exports = {
  mode: isProduction ? "production" : "development",

  module: {
    rules: [
      {
        test: /\.ts$/,
        use: ["ts-loader"]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: "elm-assets-loader",
            options: {
              module: "Views.Assets",
              tagger: "AssetPath",
              localPath: url => url.replace(/^.\//, "./assets/")
            }
          },
          {
            loader: "elm-webpack-loader",
            options: {
              debug: !isProduction,
              warn: !isProduction
            }
          }
        ]
      },
      {
        test: /\.scss$/,
        // TODO: Extract CSS
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" },
          { loader: "sass-loader" }
        ]
      },
      {
        // TODO: optimize in production
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: "file-loader",
        options: {
          // TODO: remove naming in dev
          name: "[name]-[hash].[ext]"
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

  resolve: {
    extensions: [".elm", ".ts", ".js"]
  },

  devServer: {
    https: true,
    inline: true,
    stats: "errors-only"
  }
};
