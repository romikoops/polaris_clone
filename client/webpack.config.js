'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var BrowserSyncPlugin = require('browser-sync-webpack-plugin')
module.exports = {
    devtool: 'cheap-eval-source-map',
    entry: [
        // 'react-hot-loader/patch',
        '@babel/polyfill',
        'webpack-dev-server/client?http://localhost:8080',
        'webpack/hot/only-dev-server',
        path.join(__dirname, 'app/index.js')
    ],
    output: {
        path: path.join(__dirname, '/dist/'),
        filename: '[name].js',
        publicPath: '/'
    },
    devServer: {
        historyApiFallback: true
    },
    plugins: [
        new HtmlWebpackPlugin({
            template: 'app/index.tpl.html',
            inject: 'body',
            filename: 'index.html'
        }),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoEmitOnErrorsPlugin(),
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify('development')
        }),
        new webpack.ProvidePlugin({
            Promise: 'es6-promise-promise', // works as expected
        }),
        new BrowserSyncPlugin({
            host: 'localhost',
            port: 3001,
            proxy: 'http://localhost:8080/'
        })
    ],
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
                use: [{
                    loader: 'babel-loader',
                    options: {
                        cacheDirectory: true,
                        babelrc: false,
                        presets: [
                            ["@babel/env", {
                                "targets": {
                                    'browsers': ['Chrome >=59', 'IE >= 9']
                                },
                                "modules":false,
                                "loose":true
                            }],"@babel/react"],

                        plugins: [
                            "react-hot-loader/babel",
                            ["import", {libraryName: "antd", style: "css"}],
                            "@babel/proposal-object-rest-spread"

                        ]
                    }
                }
                ]

            },
            {
                test: /\.scss$/,
                use:[
                    'style-loader',
                    'css-loader',
                    'sass-loader?modules&localIdentName=[name]---[local]---[hash:base64:5]'
                ]
            },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
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
};
