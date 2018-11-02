module.exports = function (wallaby) {
  return {
    files: [
      { pattern: 'jest.init.js', load: false, instrument: false },
      { pattern: 'package.json', load: false, instrument: false },
      { pattern: 'app/components/**/*.snap', load: false, instrument: false },
      { pattern: 'app/components/**/*Base.jsx', load: false, instrument: false },
      'app/**/*.js?(x)',
      '!app/components/**/*.spec.jsx'
    ],
    tests: [
      'app/components/**/*.spec.jsx',
      '!app/components/ShipmentCardNew/AdminShipmentCardNew.spec.jsx',
      '!app/components/NavSidebar/NavSidebar.spec.jsx'
    ],
    compilers: {
      '**/*.js?(x)': wallaby.compilers.babel()
    },
    testFramework: 'jest',
    workers: {
      reload: true,
      initial: 4,
      regular: 2
    },
    delays: {
      run: 1000
    },
    ignoreFileLoadingDependencyTracking: true,
    slowTestThreshold: 500,
    maxConsoleMessagesPerTest: 500,
    debug: true
  }
}
/* eslint-enable */
