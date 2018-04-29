const HtmlWebpackPlugin = require("html-webpack-plugin");
// const path = require("path");

module.exports = {
  mode: "development",

  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            debug: true,
            warn: true
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
