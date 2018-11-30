module.exports = {
  presets: [
    ['@babel/preset-env', { useBuiltIns: 'entry' }],
    '@babel/preset-react'
  ],
  plugins: [
    ['@babel/plugin-proposal-decorators', { legacy: true }],
    '@babel/plugin-proposal-class-properties',
    ['import', { libraryName: 'antd', style: 'css' }],
    '@babel/plugin-proposal-object-rest-spread'
  ]
}
