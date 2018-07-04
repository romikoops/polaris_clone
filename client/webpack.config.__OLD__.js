const fs = require('fs')
const path = require('path')
const webpack = require('webpack')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const BrowserSyncPlugin = require('browser-sync-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const StatsPlugin = require('stats-webpack-plugin')
const NodeEnvPlugin = require('node-env-webpack-plugin')
const BabiliPlugin = require('babili-webpack-plugin')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

// we need to use fs.readFileSync, as require parses the file as js instead of json
const babelrc = Object.assign({}, JSON.parse(fs.readFileSync('./.babelrc', 'utf-8')), {
  cacheDirectory: true,
  babelrc: false
})

babelrc.plugins.push('react-hot-loader/babel')

module.exports = {
  devtool: NodeEnvPlugin.isProduction ? 'none' : 'cheap-module-eval-source-map',
  entry: NodeEnvPlugin.isProduction
    ? ['@babel/polyfill', path.join(__dirname, 'app/index.jsx')]
    : [
      'react-hot-loader/patch',
      '@babel/polyfill',
      'webpack-dev-server/client?http://localhost:8080',
      'webpack/hot/only-dev-server',
      path.join(__dirname, 'app/index.jsx')
    ],

  output: {
    path: path.join(__dirname, '/dist/'),
    filename: NodeEnvPlugin.isProduction ? '[name]-[hash].min.js' : '[name].js',
    publicPath: '/'
  },
  devServer: {
    historyApiFallback: true
  },
  plugins: [
    // new webpack.optimize.OccurenceOrderPlugin(),
    new HtmlWebpackPlugin({
      template: 'app/index.tpl.html',
      inject: 'body',
      filename: 'index.html'
    }),
    new ExtractTextPlugin({
      filename: '[name]-[hash].min.css',
      allChunks: true,
      disable: !NodeEnvPlugin.isProduction
    }),
    new NodeEnvPlugin(),
    new FriendlyErrorsWebpackPlugin(),
    NodeEnvPlugin.isProduction ? null : new webpack.HotModuleReplacementPlugin(),
    NodeEnvPlugin.isProduction ? null : new webpack.NoEmitOnErrorsPlugin(),
    NodeEnvPlugin.isProduction
      ? new StatsPlugin('webpack.stats.json', {
        source: false,
        modules: false
      })
      : null,
    NodeEnvPlugin.isProduction
      ? new BabiliPlugin({
        mangle: false
      })
      : new BrowserSyncPlugin({
        host: 'localhost',
        port: 3001,
        proxy: 'http://localhost:8080/'
      })
  ].filter(Boolean),
  resolve: {
    extensions: ['.jsx', '.js', '.json']
  },
  module: {
    rules: [
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
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader'],
          publicPath: '/dist',
          disable: !NodeEnvPlugin.isProduction
        })
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            'css-loader',
            'sass-loader?modules&localIdentName=[name]---[local]---[hash:base64:5]'
          ],
          publicPath: '/dist',
          disable: !NodeEnvPlugin.isProduction
        })
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
  }
}
