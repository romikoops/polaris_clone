import * as React from 'react'
import { shallow } from 'enzyme'
import RouteSection from '.'
import {
  cargoItemTypes,
  maxDimensions,
  scope,
  lookupTablesForRoutes,
  availableMots,
  routes,
  theme,
  identity
} from '../mocks'

const shipmentBase = {
  direction: 'export',
  aggregatedCargo: false,
  loadType: 'cargo_item',
  onCarriage: false,
  preCarriage: false,
  origin: {
    latitude: 36.083811,
    longitude: 120.323534,
    nexusId: 601,
    nexusName: 'Qingdao',
    country: 'CN'
  },
  destination: {},
  cargoUnits: [
    {
      payloadInKg: 12,
      totalVolume: 0,
      totalWeight: 0,
      dimensionX: 43,
      dimensionY: 12,
      dimensionZ: 33,
      quantity: 7,
      cargoItemTypeId: '',
      dangerousGoods: false,
      stackable: true
    }
  ],
  trucking: {
    preCarriage: {
      truckType: ''
    },
    onCarriage: {
      truckType: ''
    }
  },
  id: 4612
}

const propsBase = {
  bookingProcessDispatch: {
    updatePageData: identity
  },
  shipmentDispatch: {
    getLastAvailableDate: identity
  },
  availableMots,
  theme,
  scope,
  cargoItemTypes,
  maxDimensions,
  shipment: shipmentBase,
  routes,
  lookupTablesForRoutes
}

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

test('with empty props', () => {
  expect(() => shallow(<RouteSection />)).toThrow()
})

test('shipment has origin', () => {
  expect(shallow(<RouteSection {...propsBase} />)).toMatchSnapshot()
})

test('shipment has origin and destination', () => {
  const shipment = {
    ...shipmentBase,
    destination: {
      latitude: 57.694253, longitude: 11.854048, nexusId: 597, nexusName: 'Gothenburg', country: 'SE'
    }
  }
  const props = {
    ...propsBase,
    shipment
  }
  expect(shallow(<RouteSection {...props} />)).toMatchSnapshot()
})

test('shipment has destination', () => {
  const shipment = {
    ...shipmentBase,
    origin: {},
    destination: {
      latitude: 57.694253, longitude: 11.854048, nexusId: 597, nexusName: 'Gothenburg', country: 'SE'
    }
  }
  const props = {
    ...propsBase,
    shipment
  }
  expect(shallow(<RouteSection {...props} />)).toMatchSnapshot()
})
