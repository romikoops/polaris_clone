'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var StatsPlugin = require('stats-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
    // The entry file. All your app roots from here.
    entry: [
        // Polyfills go here too, like babel-polyfill or whatwg-fetch
        '@babel/polyfill',
        path.join(__dirname, 'app/index.js')
    ],
    // Where you want the output to go
    output: {
        path: path.join(__dirname, '/dist/'),
        filename: '[name]-[hash].min.js',
        publicPath: '/'
    },
    plugins: [
        // webpack gives your modules and chunks ids to identify them. Webpack can vary the
        // distribution of the ids to get the smallest id length for often used ids with
        // this plugin
        // new webpack.optimize.OccurenceOrderPlugin(),

        // handles creating an index.html file and injecting assets. necessary because assets
        // change name because the hash part changes. We want hash name changes to bust cache
        // on client browsers.
        new HtmlWebpackPlugin({
            template: 'app/index.tpl.html',
            inject: 'body',
            filename: 'index.html'
        }),
        // extracts the css from the js files and puts them on a separate .css file. this is for
        // performance and is used in prod environments. Styles load faster on their own .css
        // file as they dont have to wait for the JS to load.
        // new ExtractTextPlugin('[name]-[hash].min.css'),
        new ExtractTextPlugin({
          filename: '[name]-[hash].min.css',
          disable: false,
          allChunks: true
        }),
        // handles uglifying js
        // new webpack.optimize.UglifyJsPlugin({
        //     compressor: {
        //         warnings: false,
        //         screw_ie8: true
        //     }
        // }),
        // creates a stats.json
        new StatsPlugin('webpack.stats.json', {
            source: false,
            modules: false
        }),
        // plugin for passing in data to the js, like what NODE_ENV we are in.
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify('production')
        })
        // ,
        // new UglifyJsPlugin({
        //     sourceMap: true
        // })
    ],

    // ESLint options
    // eslint: {
    //     configFile: '.eslintrc',
    //     failOnWarning: false,
    //     failOnError: true
    // },

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
            // {
            //     test: /\.scss$/,
            //     use:[
            //         'style-loader',
            //         'css-loader',
            //         'sass-loader?modules&localIdentName=[name]---[local]---[hash:base64:5]'
            //     ]
            // },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader', 'postcss-loader']
            },
            {
                test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
                use: 'url-loader?limit=10000&mimetype=application/font-woff'
            },
            { test: /\.(ttf|eot|svg)(\?[a-z0-9#=&.]+)?$/, use: 'file-loader' },
            {
                test: /\.(png|jpg)$/,
                use: 'url-loader?limit=25000'
            },
            {
            test: /\.scss$/,
            // we extract the styles into their own .css file instead of having
            // them inside the js.
            loader: ExtractTextPlugin.extract({
                fallback:'style-loader', 
                use: 'css-loader?modules&localIdentName=[name]---[local]---[hash:base64:5]!sass-loader',
                publicPath: '/dist'
            })
        }
        ]
    }
};
