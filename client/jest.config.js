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
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': '<rootDir>/app/mocks.js',
    '\\.s?css$': 'identity-obj-proxy'
  },
  reporters: ['default', 'jest-junit']
}
