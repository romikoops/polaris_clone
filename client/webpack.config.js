const path = require('path')
const webpack = require('webpack')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const BrowserSyncPlugin = require('browser-sync-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const StatsPlugin = require('stats-webpack-plugin')
const NodeEnvPlugin = require('node-env-webpack-plugin')
const BabiliPlugin = require('babili-webpack-plugin')

module.exports = {
  devtool: NodeEnvPlugin.isProduction ? 'none' : 'cheap-module-eval-source-map',
  entry: NodeEnvPlugin.isProduction
    ? ['@babel/polyfill', path.join(__dirname, 'app/index.js')]
    : [
      // 'react-hot-loader/patch',
      '@babel/polyfill',
      'webpack-dev-server/client?http://localhost:8080',
      'webpack/hot/only-dev-server',
      path.join(__dirname, 'app/index.js')
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
    NodeEnvPlugin.isProduction ? null : new webpack.HotModuleReplacementPlugin(),
    NodeEnvPlugin.isProduction
      ? new StatsPlugin('webpack.stats.json', {
        source: false,
        modules: false
      })
      : new webpack.NoEmitOnErrorsPlugin(),
    new NodeEnvPlugin(),
    NodeEnvPlugin.isProduction
      ? new BabiliPlugin()
      : new BrowserSyncPlugin({
        host: 'localhost',
        port: 3001,
        proxy: 'http://localhost:8080/'
      })
  ].filter(Boolean),
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
            options: {
              cacheDirectory: true,
              babelrc: false,
              presets: [
                [
                  '@babel/env',
                  {
                    targets: {
                      browsers: ['Chrome >=59', 'IE >= 9']
                    },
                    modules: false,
                    loose: true
                  }
                ],
                '@babel/react'
              ],

              plugins: [
                'react-hot-loader/babel',
                ['import', { libraryName: 'antd', style: 'css' }],
                '@babel/proposal-object-rest-spread'
              ]
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader'],
          publicPath: '/dist'
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
          publicPath: '/dist'
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
