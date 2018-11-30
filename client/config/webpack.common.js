const path = require('path')
const webpack = require('webpack')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const Dotenv = require('dotenv-webpack')
const HtmlWebPackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const SentryCliPlugin = require('@sentry/webpack-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

module.exports = {
  entry: './app/index.jsx',

  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, '../dist'),
    publicPath: '/'
  },

  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        cache: true,
        parallel: true,
        sourceMap: true
      }),
      new OptimizeCSSAssetsPlugin({})
    ],
    // splitChunks: {
    //   chunks: 'all'
    // }
  },

  module: {
    rules: [
      {
        test: /\.s?css$/,
        use: [
          process.env.NODE_ENV !== 'production' ? 'style-loader' : MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              importLoaders: 2
            }
          },
          'postcss-loader',
          'sass-loader'
        ]
      },

      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            cacheDirectory: true
          }
        }
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
        test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: '10000',
              mimetype: 'application/font-woff'
            }
          }
        ]
      },

      {
        test: /\.(ttf|eot|svg)(\?[a-z0-9#=&.]+)?$/,
        use: ['file-loader']
      },

      {
        test: /\.(gif|png|jpe?g|svg)$/i,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 1 * 1024 // 1kB
            }
          },
          {
            loader: 'image-webpack-loader'
          }
        ]
      },

      {
        test: /locales/,
        loader: '@alienfast/i18next-loader'
      }
    ]
  },

  resolve: {
    extensions: ['.js', '.jsx']
  },

  plugins: [
    new Dotenv(),
    new webpack.EnvironmentPlugin({
      BASE_URL: '//localhost:3000',
      RELEASE: '',
      GTM_ID: 'GTM-P29HCHV'
    }),

    new CleanWebpackPlugin(
      [path.resolve(__dirname, '../dist')],
      {
        root: path.resolve(__dirname, '../')
      }
    ),

    new CopyWebpackPlugin([
      { from: 'app/config.201811291749.js' }
    ]),

    new MiniCssExtractPlugin({
      filename: '[name]-[contenthash].css',
      chunkFilename: '[id].css'
    }),

    new HtmlWebPackPlugin({
      template: 'app/index.tpl.html',
      filename: 'index.html'
    }),

    new CompressionPlugin({
      include: /\.(css|html|js|map)$/,
      threshold: 2 * 1024
    }),

    new SentryCliPlugin({
      dryRun: process.env.NODE_ENV !== 'production',
      release: process.env.RELEASE,
      include: 'dist/',
      ignoreFile: '.sentrycliignore',
      ignore: ['config.201811291749.js']
    })
  ]
}
