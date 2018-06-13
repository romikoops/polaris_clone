const fs = require('fs')
const path = require('path')
const webpack = require('webpack')
const HtmlWebPackPlugin = require("html-webpack-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const NodeEnvPlugin = require('node-env-webpack-plugin')
const babelrc = Object.assign({}, JSON.parse(fs.readFileSync('./.babelrc', 'utf-8')), {
  cacheDirectory: true,
  babelrc: false
})


babelrc.plugins.push('react-hot-loader/babel')
module.exports = {
  entry: './app/index.jsx',
  devServer: {
    historyApiFallback: true,
  },
  output : {
    publicPath: '/',
    filename: NodeEnvPlugin.isProduction ? '[name]-[hash].min.js' : '[name].js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'eslint-loader',
        enforce: 'pre'
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: babelrc
          }
        ]
      },
      {
        test: /\.html$/,
        use: [
          {
            loader: "html-loader",
            options: { minimize: true }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"]
      },
      {
        test: /\.scss$/,
        use: [
          {
            loader: "style-loader" // creates style nodes from JS strings
          },
          {
            loader: "css-loader" // translates CSS into CommonJS
          },
          {
            loader: "sass-loader" // compiles Sass to CSS
          }
        ]
      },
      {
        test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
        use: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      { test: /\.(ttf|eot|svg)(\?[a-z0-9#=&.]+)?$/, use: 'file-loader' },
      {
        test: /\.(png|jpg|gif)$/,
        use: 'url-loader?limit=25000'
      }
    ]
  },
  resolve: {
    extensions: ['.jsx', '.js', '.json']
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: 'app/index.tpl.html',
      inject: 'body',
      filename: 'index.html'
    }),
    new MiniCssExtractPlugin({
      filename: NodeEnvPlugin.isProduction ? '[name]-[hash].min.css' : '[name].css',
      chunkFilename: "[id].css"
    })
  ]
};