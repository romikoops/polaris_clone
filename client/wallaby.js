module.exports = function (wallaby) {
  return {
    files: [
      'jest.init.js',
      'package.json',
      'app/**/*.js?(x)',
      'app/components/**/*.snap',
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
    workers: {
      initial: 3,
      regular: 7
    },
    debug: true
  }
}
