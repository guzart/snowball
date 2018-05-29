require("dotenv").config();

const devcert = require("devcert");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const merge = require("webpack-merge");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const webpack = require("webpack");

const DEV_HOST = "snowball.guzart.com";

const isProduction = process.env["NODE_ENV"] === "production";
const isDevelopment = !isProduction;

module.exports = (async () => {
  const certs = await devcert.certificateFor(DEV_HOST);
  const mode = isProduction ? "production" : "development";
  const apiUrl = isProduction
    ? "https://api.youneedabudget.com/v1"
    : "http://localhost:8888";

  const common = {
    mode,

    module: {
      rules: [
        {
          test: /\.ts$/,
          use: ["ts-loader"]
        },
        {
          test: /\.scss$/,
          use: [
            isDevelopment ? "style-loader" : MiniCssExtractPlugin.loader,
            "css-loader",
            "sass-loader"
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
        YNAB_API_URL: JSON.stringify(apiUrl),
        YNAB_CLIENT_ID: JSON.stringify(process.env["YNAB_CLIENT_ID"]),
        "process.env.NODE_ENV": JSON.stringify(mode)
      }),
      new HtmlWebpackPlugin({
        inject: "body",
        template: "src/index.html",
        favicon: "src/favicon.ico",
        minify: isProduction
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
            { loader: "elm-webpack-loader" }
          ]
        }
      ]
    },

    plugins: [
      new MiniCssExtractPlugin({
        filename: "[name].[contenthash].css",
        chunkFilename: "[id].[contenthash].css"
      })
    ],

    devtool: "source-map",

    optimization: {
      minimizer: [
        new UglifyJsPlugin({ sourceMap: true }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },

    output: {
      filename: "[name].[chunkhash].js"
    }
  });
})();
