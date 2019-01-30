import * as React from 'react'
import { shallow } from 'enzyme'
import {
  shipmentData,
  gMaps,
  identity,
  shipment,
  theme,
  user
} from '../../mocks'

import ShipmentLocationBox from './ShipmentLocationBox'

const propsBase = {
  nextStageAttempt: false,
  handleSelectLocation: identity,
  gMaps,
  theme,
  user,
  shipment,
  updateFilteredRouteIndexes: identity,
  setTargetAddress: identity,
  handleAddressChange: identity,
  handleChangeCarriage: identity,
  allNexuses: {
    origins: [],
    destinations: []
  },
  filteredRouteIndexes: {
    origin: [],
    destination: [],
    all: []
  },
  has_on_carriage: false,
  has_pre_carriage: false,
  shipmentDispatch: {
    goTo: identity,
    setError: identity,
    getDashboard: identity
  },
  selectedRoute: {},
  origin: {
    number: 5
  },
  destination: {
    number: 2
  },
  shipmentData,
  routeIds: [],
  prevRequest: {
    shipment
  },
  scope: {
    require_full_address: false,
    modes_of_transport: []
  }
}

test('shallow rendering', () => {
  expect(
    shallow(<ShipmentLocationBox {...propsBase} />)
  ).toMatchSnapshot()
})
