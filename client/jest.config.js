module.exports = {
  testRegex: '.spec.(jsx|js)$',
  collectCoverage: true,
  collectCoverageFrom: ['app/**/*.(jsx|js)'],
  coverageReporters: ['text-summary'],
  verbose: true,
  setupFiles: ['./jest.init.js'],
  setupTestFrameworkScriptFile: './node_modules/jest-enzyme/lib/index.js',
  snapshotSerializers: ['enzyme-to-json/serializer'],
  transformIgnorePatterns: ['/node_modules/'],
  unmockedModulePathPatterns: [],
  moduleNameMapper: {
    '\\.(jpe?g|png|gif|eot|svg|ttf|woff)$': '<rootDir>/app/mocks/index.js',
    '\\.s?css$': 'identity-obj-proxy'
  },
  reporters: ['default']
}
