module.exports = {
  presets: [
    '@babel/preset-env',
    '@babel/preset-react'
  ],
  plugins: [
    ['@babel/plugin-proposal-decorators', { decoratorsBeforeExport: true }],
    '@babel/plugin-proposal-class-properties',
    ['import', { libraryName: 'antd', style: 'css' }],
    '@babel/plugin-proposal-object-rest-spread'
  ]
}
