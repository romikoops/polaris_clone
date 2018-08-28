module.exports = {
  // if true stops test after first failure
  bail: true,
  testRegex: '.spec.jsx$',
  collectCoverageFrom: ['app/components/**/*.(jsx|js)'],
  verbose: true,
  setupFiles: ['./jest.init.js'],
  setupTestFrameworkScriptFile: './node_modules/jest-enzyme/lib/index.js',
  snapshotSerializers: ['enzyme-to-json/serializer'],
  transformIgnorePatterns: ['/node_modules/'],
  testPathIgnorePatterns: ['app/components/BookingConfirmation/', 'app/components/ChooseShipment', 'app/components/Tabs/', 'app/components/Footer/', 'app/components/Notes', 'app/components/ShipmentAggregatedCargo/', 'app/components/Help/', 'app/components/AddressBook/', 'app/components/AlertModalBody/', 'app/components/Redirects/', 'app/components/RouteResult/', 'app/components/ContactCard/', 'app/components/ShipmentCard', 'app/components/ResetPasswordForm/', 'app/components/BookingDetails/', 'app/components/NavDropdown', 'app/components/Header/', 'app/components/RouteFilterBox', 'app/components/ShipmentContainers/', 'app/components/ShopStageView', 'app/components/ShipmentContactForm/', 'app/components/ShipmentDetails/', 'app/components/Cargo/', 'app/components/Messaging/', 'app/components/UserAccount', 'app/components/UserShipmentView', 'app/components/CargoDetails', 'app/components/Incoterm', 'app/components/BookingSummary', 'app/components/ChooseOffer/', 'app/components/BestRoutesBox', 'app/components/LandingTop'],
  unmockedModulePathPatterns: [],
  moduleNameMapper: {
    '\\.s?css$': 'identity-obj-proxy'
  }
}
