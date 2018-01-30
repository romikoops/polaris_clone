<<<<<<< HEAD
const webpack = require('webpack');
const WebpackDevServer = require('webpack-dev-server');
const config = require('./webpack.config');

new WebpackDevServer(webpack(config), {
    publicPath: config.output.publicPath,
    hot: true,
    historyApiFallback: true,
    // It suppress error shown in console, so it has to be set to false.
    quiet: false,
    // It suppress everything except error, so it has to be set to false as well
    // to see success build.
    noInfo: false,
    stats: {
        // Config for minimal console.log mess.
        assets: false,
        colors: true,
        version: false,
        hash: false,
        timings: false,
        chunks: false,
        chunkModules: false
    }
/*
}).listen(8080, 'localhost', (err) => {
    if (err) {
        console.log(err);
    }
    console.log('Listening at localhost:8080');

});
**/
}).listen(3001, 'localhost', (err) => {
    if (err) {
        console.log(err);
    }
    console.log('Listening at localhost:3001');
});
=======
/* eslint-disable import/no-extraneous-dependencies */
const webpack = require('webpack')
const WebpackDevServer = require('webpack-dev-server')
/* eslint-enable import/no-extraneous-dependencies */
const config = require('./webpack.config')

// force NODE_ENV to development
process.env.NODE_ENV = 'development'

const server = new WebpackDevServer(webpack(config), {
  publicPath: config.output.publicPath,
  hot: true,
  historyApiFallback: true,
  // It suppress error shown in console, so it has to be set to false.
  quiet: false,
  // It suppress everything except error, so it has to be set to false as well
  // to see success build.
  noInfo: false,
  stats: {
    // Config for minimal console.log mess.
    assets: false,
    colors: true,
    version: false,
    hash: false,
    timings: false,
    chunks: false,
    chunkModules: false
  }
})

server.listen(8080, 'localhost', (err) => {
  /* eslint-disable no-console */
  if (err) {
    console.error(err)
  }

  console.log('Listening at localhost:8080')
  /* eslint-enable no-console */
})
>>>>>>> adjusted server script
