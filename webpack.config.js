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
    new HtmlWebpackPlugin({
      inject: "body",
      template: "src/index.html",
      favicon: "src/favicon.ico"
    })
  ],

  devServer: {
    inline: true,
    stats: "errors-only"
  }
};
