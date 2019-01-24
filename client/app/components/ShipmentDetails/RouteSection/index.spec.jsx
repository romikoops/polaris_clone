import * as React from 'react'
import { map } from 'lodash'
import { shallow } from 'enzyme'
import RouteSection from '.'
import {
  cargoItemTypes,
  maxDimensions,
  scope,
  lookupTablesForRoutes,
  availableMots,
  routes,
  theme
} from '../mocks'

const destinationBase = {
  latitude: 57.694253,
  longitude: 11.854048,
  nexusId: 597,
  nexusName: 'Gothenburg',
  country: 'SE'
}

const originBase = {
  latitude: 36.083811,
  longitude: 120.323534,
  nexusId: 601,
  nexusName: 'Qingdao',
  country: 'CN'
}

const shipmentBase = {
  direction: 'export',
  aggregatedCargo: false,
  loadType: 'cargo_item',
  onCarriage: false,
  preCarriage: false,
  origin: originBase,
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
    updatePageData: x => x
  },
  shipmentDispatch: {
    getLastAvailableDate: x => x
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

test('shipment has origin trucking', () => {
  const spy = jest.fn()
  const origin = {
    ...originBase,
    hubIds: [3037,3023]
  }
  const props = {
    ...propsBase,
    bookingProcessDispatch:{
      updatePageData: spy
    },
    shipment:{
      ...shipmentBase,
      preCarriage:true,
      origin
    }
  }
  RouteSection.getDerivedStateFromProps(props, {})
  const [[key, payload]] = spy.mock.calls
  const expected = [ 2852, 2853, 2858, 2861, 2863, 2866, 2869, 2918, 2921, 2925, 2928 ]

  expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
  expect(key).toBe('ShipmentDetails')
})

test('shipment has destination trucking', () => {
  const spy = jest.fn()
  const destination = {
    ...destinationBase,
    hubIds: [3023]
  }
  const props = {
    ...propsBase,
    bookingProcessDispatch:{
      updatePageData: spy
    },
    shipment:{
      ...shipmentBase,
      onCarriage:true,
      origin: {},
      destination
    }
  }
  RouteSection.getDerivedStateFromProps(props, {})
  const [[key, payload]] = spy.mock.calls
  const expected = [2849, 2871, 2873, 2876, 2878]
  
  expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
  expect(key).toBe('ShipmentDetails')
})

test('shipment has origin', () => {
  expect(shallow(<RouteSection {...propsBase} />)).toMatchSnapshot()
})

test('shipment has origin and destination', () => {
  const shipment = {
    ...shipmentBase,
    destination: destinationBase
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
    destination: destinationBase
  }
  const props = {
    ...propsBase,
    shipment
  }
  expect(shallow(<RouteSection {...props} />)).toMatchSnapshot()
})

test('handleDropdownSelect', () => {
  const spy = jest.fn()
  const setMarker = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleDropdownSelect(
    'TARGET',
    {
      value: {
        latitude: 'latitude',
        longitude: 'longitude',
        id: 'id',
        name: 'name',
        country: 'country'
      }
    },
    setMarker
  )
  const [spyCall] = spy.mock.calls
  const [setMarkerCall] = setMarker.mock.calls
  const expectedSpyCall = [
    'TARGET',
    {
      latitude: 'latitude',
      longitude: 'longitude',
      nexusId: 'id',
      nexusName: 'name',
      country: 'country'
    }
  ]
  const expectedMarkerCall = ["TARGET", {"lat": "latitude", "lng": "longitude"}]

  expect(spyCall).toEqual(expectedSpyCall)
  expect(setMarkerCall).toEqual(expectedMarkerCall)
})

test('handleDropdownSelect when selectOption is falsy', () => {
  const spy = jest.fn()
  const setMarker = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleDropdownSelect(
    'TARGET',
    null,
    setMarker
  )
  const [spyCall] = spy.mock.calls
  const [setMarkerCall] = setMarker.mock.calls

  expect(spyCall).toEqual(['TARGET', {}])
  expect(setMarkerCall).toEqual(['TARGET', null])
})

test('handleInputBlur', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleInputBlur({
    target: {
      value: 'TARGET_VALUE',
      name: 'foo-bar'
    }
  })
  const [spyCall] = spy.mock.calls

  expect(spyCall).toEqual(['foo', { bar: 'TARGET_VALUE' }])
})

test('handleTruckingDetailsChange', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleTruckingDetailsChange({
    target: {
      id: 'preCarriage-TRUCK_TYPE'
    }
  })
  const [[key, payload]] = spy.mock.calls
  const expectedPayload = {
    preCarriage: { truckType: 'TRUCK_TYPE' },
    onCarriage: { truckType: '' }
  }

  expect(key).toBe('trucking')
  expect(payload).toEqual(expectedPayload)
})

test('handleCarriageChange when checked is false', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleCarriageChange({
    target: {
      name: 'onCarriage',
      checked: false
    }
  })
  const [[key, payload]] = spy.mock.calls

  expect(key).toBe('onCarriage')
  expect(payload).toBe(false)
})

test('handleCarriageChang when checked is false', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updateShipment: spy
    }
  }
  const Component = new RouteSection(props)
  Component.handleCarriageChange({
    target: {
      name: 'onCarriage',
      checked: true
    }
  })
  const [[key, payload]] = spy.mock.calls

  expect(key).toBe('onCarriage')
  expect(payload).toBe(true)
})
