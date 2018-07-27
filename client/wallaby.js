module.exports = function (wallaby) {
  return {
    files: [
      'app/**/*.jsx',
      'app/**/*.snap',
      'app/**/*.js',
      'jest.init.js',
      'package.json',
      'app/components/**/*.js?(x)',
      '!app/components/**/*.spec.jsx'
    ],
    tests: [
      'app/components/**/*.spec.jsx',
      '!app/components/ShipmentCardNew/AdminShipmentCardNew.spec.jsx',
      '!app/components/NavSidebar/NavSidebar.spec.jsx'
    ],
    env: {
      type: 'node',
      runner: 'node'
    },
    compilers: {
      '**/*.js?(x)': wallaby.compilers.babel()
    },
    testFramework: 'jest',
    debug: true
  }
}
