'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    devtool: 'eval-source-map',
    entry: [
        'babel-polyfill',
        'webpack-dev-server/client?http://localhost:8080',
        'webpack/hot/only-dev-server',
        'react-hot-loader/patch',
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
        })
    ],
    // eslint: {
    //     configFile: '.eslintrc',
    //     failOnWarning: false,
    //     failOnError: false
    // },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: 'eslint-loader',
                enforce: 'pre'
            },
            // {
            //     test: /\.js?$/,
            //     exclude: /node_modules/,
            //     use: 'babel-loader'
            // },
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
                                    'browsers': ['Chrome >=59']
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
            // {
            //     test: /\.(gif|png|jpe?g|svg)$/i,
            //     loaders: [
            //         'file-loader',
            //         {
            //             loader: 'image-webpack-loader',
            //             options: {
            //                 gifsicle: {
            //                     interlaced: false
            //                 },
            //                 optipng: {
            //                     optimizationLevel: 7
            //                 },
            //                 pngquant: {
            //                     quality: '65-90',
            //                     speed: 4
            //                 },
            //                 mozjpeg: {
            //                     progressive: true,
            //                     quality: 65
            //                 },
            //                 // Specifying webp here will create a WEBP version of your JPG/PNG images
            //                 webp: {
            //                     quality: 75
            //                 }
            //             }
            //         }
            //     ]
            // },
            {
                test: /\.(png|jpg)$/,
                use: 'url-loader?limit=25000'
            }
        ]
    }
};
