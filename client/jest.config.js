module.exports = {
  // if true stops test after first failure
  bail: true,
  testRegex: '.spec.(jsx|js)$',
  collectCoverage: true,
  collectCoverageFrom: ['app/**/*.(jsx|js)'],
  coverageReporters: ['lcov', 'text-summary'],
  verbose: true,
  setupFiles: ['./jest.init.js'],
  setupTestFrameworkScriptFile: './node_modules/jest-enzyme/lib/index.js',
  snapshotSerializers: ['enzyme-to-json/serializer'],
  transformIgnorePatterns: ['/node_modules/'],
  unmockedModulePathPatterns: [],
  moduleNameMapper: {
    '\\.s?css$': 'identity-obj-proxy'
  },
  reporters: ['default', 'jest-junit']
}
