const fs = require('fs')
const path = require('path')
const webpack = require('webpack')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const DotenvWebpack = require('dotenv-webpack')
const HtmlWebPackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const NodeEnvPlugin = require('node-env-webpack-plugin')
const SentryCliPlugin = require('@sentry/webpack-plugin')

const babelrc = Object.assign({}, JSON.parse(fs.readFileSync('./.babelrc', 'utf-8')), {
  cacheDirectory: true,
  babelrc: false
})

babelrc.plugins.push('react-hot-loader/babel')
module.exports = {
  entry: './app/index.jsx',
  devtool: NodeEnvPlugin.isProduction ? 'source-map' : 'eval-cheap-module-source-map',
  devServer: {
    historyApiFallback: true,
    host: '0.0.0.0'
  },
  optimization: {
    sideEffects: true
  },
  output: {
    publicPath: '/',
    filename: NodeEnvPlugin.isProduction ? '[name]-[chunkhash].min.js' : '[name].js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
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
            loader: 'html-loader',
            options: { minimize: true }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      },
      {
        test: /\.scss$/,
        use: [
          {
            loader: 'style-loader' // creates style nodes from JS strings
          },
          {
            loader: 'css-loader' // translates CSS into CommonJS
          },
          {
            loader: 'sass-loader' // compiles Sass to CSS
          }
        ]
      },
      {
        test: /locales/,
        loader: '@alienfast/i18next-loader'
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
      chunkFilename: '[id].css'
    }),
    new CopyWebpackPlugin([
      { from: 'app/config.js' }
    ]),
    new DotenvWebpack({
      path: './.node-env'
    }),
    new webpack.EnvironmentPlugin(['RELEASE']),
    NodeEnvPlugin.isProduction && process.env.SENTRY_AUTH_TOKEN
      ? new SentryCliPlugin({
        release: process.env.RELEASE,
        include: 'dist/',
        ignoreFile: '.sentrycliignore',
        ignore: ['config.js']
      })
      : false
  ].filter(Boolean)
}
