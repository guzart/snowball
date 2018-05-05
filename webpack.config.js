require("dotenv").config();

const devcert = require("devcert");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const merge = require("webpack-merge");
const webpack = require("webpack");

const DEV_HOST = "snowball.guzart.com";

const isProduction = process.env["NODE_ENV"] === "production";
const isDevelopment = !isProduction;

module.exports = (async () => {
  const certs = await devcert.certificateFor(DEV_HOST);

  const common = {
    mode: isProduction ? "production" : "development",

    module: {
      rules: [
        {
          test: /\.ts$/,
          use: ["ts-loader"]
        },
        {
          test: /\.scss$/,
          // TODO: extract css
          use: [
            { loader: "style-loader" },
            { loader: "css-loader" },
            { loader: "sass-loader" }
          ]
        },
        {
          // TODO: optimize for production
          test: /\.(jpe?g|png|gif|svg)$/i,
          loader: "file-loader",
          options: {
            name: isProduction ? "[name]-[hash].[ext]" : "[name].[ext]"
          }
        }
      ]
    },

    plugins: [
      new webpack.DefinePlugin({
        YNAB_API_URL: JSON.stringify(
          isProduction ? process.env["YNAB_API_URL"] : "http://localhost:8888"
        ),
        YNAB_CLIENT_ID: JSON.stringify(process.env["YNAB_CLIENT_ID"]),
        "process.env.NODE_ENV": JSON.stringify(
          isProduction ? "production" : "development"
        )
      }),
      new HtmlWebpackPlugin({
        inject: "body",
        template: "src/index.html",
        favicon: "src/favicon.ico"
      })
    ],

    resolve: {
      extensions: [".elm", ".ts", ".js"]
    }
  };

  if (isDevelopment) {
    return merge(common, {
      module: {
        rules: [
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
              { loader: "elm-hot-loader" },
              {
                loader: "elm-webpack-loader",
                options: { debug: true, verbose: true, warn: true }
              }
            ]
          }
        ]
      },

      devServer: {
        contentBase: "./src",
        historyApiFallback: true,
        host: DEV_HOST,
        https: {
          key: certs.key,
          cert: certs.cert
        },
        inline: true,
        stats: "errors-only"
      }
    });
  }

  return {
    module: {
      rules: [
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
            { loader: "elm-webpack-loader" }
          ]
        }
      ]
    },

    output: { filename: "[name].[chunkhash].js" }
  };
})();
