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

const originBase = {
  latitude: 30.626539,
  longitude: 122.064958,
  nexusId: 599,
  nexusName: 'Shanghai',
  country: 'CN'
}
const destinationBase = {
  latitude: 57.694253,
  longitude: 11.854048,
  nexusId: 597,
  nexusName: 'Gothenburg',
  country: 'SE'
}

const shipmentBase = {
  direction: 'export',
  aggregatedCargo: false,
  loadType: 'cargo_item',
  onCarriage: false,
  preCarriage: false,
  origin: {},
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

const shipmentHasOrigin = {
  ...shipmentBase,
  origin: originBase
}
const shipmentHasTruckingOrigin = {
  ...shipmentBase,
  preCarriage: true,
  origin: {
    ...originBase,
    hubIds: [3025]
  }
}
const shipmentHasTruckingOriginHasDestination = {
  ...shipmentBase,
  preCarriage: true,
  origin: {
    ...originBase,
    hubIds: [3025]
  },
  destination: destinationBase
}
const shipmentHasTruckingOriginHasTruckingDestination = {
  ...shipmentBase,
  onCarriage: true,
  preCarriage: true,
  origin: {
    ...originBase,
    hubIds: [3025]
  },
  destination: {
    ...destinationBase,
    hubIds: [3030, 3023]
  }
}
const shipmentHasDestination = {
  ...shipmentBase,
  destination: destinationBase
}
const shipmentHasTruckingDestination = {
  ...shipmentBase,
  onCarriage: true,
  destination: {
    ...destinationBase,
    hubIds: [3030, 3023]
  }
}
const shipmentHasTruckingDestinationHasOrigin = {
  ...shipmentBase,
  onCarriage: true,
  destination: {
    ...destinationBase,
    hubIds: [3030, 3023]
  },
  origin: originBase
}

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

// getDerivedStateFromProps tests
// ============================================
describe('shipment has neither origin nor destination', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentBase
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    /**
     * Assert the length of the list, instead of the list itself, if length is too long
     */
    expect(map(payload.availableRoutes, 'itineraryId').length).toBe(126)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    /**
     * In this case lodash's `map` works as `pluck`
     */
    expect(map(result.origins, 'nexusId').length).toBe(126)
  })

  test('nexusIds of destinations', () => {
    expect(map(result.destinations, 'nexusId').length).toBe(126)
  })

  test('nexusIds of destinations are not the same as nexusIds of origins', () => {
    expect(map(result.origins, 'nexusId')).not.toEqual(map(result.destinations, 'nexusId'))
  })
})

describe('shipment has origin', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasOrigin
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  it('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2849, 2880, 2884, 2887, 2964, 17322, 17493, 17504]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    expect(map(result.origins, 'nexusId').length).toBe(126)
  })

  test('nexusIds of destinations', () => {
    const expected = [597, 597, 604, 605, 608, 608, 3282, 2932]
    expect(map(result.destinations, 'nexusId')).toEqual(expected)
  })
})

describe('shipment has origin with trucking', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasTruckingOrigin
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2849, 2964, 17493, 17504]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    expect(map(result.origins, 'nexusId').length).toBe(126)
  })

  test('nexusIds of destinations', () => {
    const expected = [597, 608, 3282, 2932]
    expect(map(result.destinations, 'nexusId')).toEqual(expected)
  })
})

describe('shipment has origin with trucking and destination', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasTruckingOriginHasDestination
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2849]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    const expected = [599, 600, 601, 598, 602, 599, 598, 601, 602]
    expect(map(result.origins, 'nexusId')).toEqual(expected)
  })

  test('nexusIds of destinations', () => {
    const expected = [597, 608, 3282, 2932]
    expect(map(result.destinations, 'nexusId')).toEqual(expected)
  })
})

describe('shipment has origin with trucking and destination with trucking', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasTruckingOriginHasTruckingDestination
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2849]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    const expected = [599, 598, 601, 602, 599, 600, 601, 598, 602]
    expect(map(result.origins, 'nexusId')).toEqual(expected)
  })

  test('nexusIds of destinations', () => {
    const expected = [597, 608, 3282, 2932]
    expect(map(result.destinations, 'nexusId')).toEqual(expected)
  })
})

describe('shipment has destination', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasDestination
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2849, 2871, 2873, 2876, 2878, 2880, 2889, 2898, 2908]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    const expected = [599, 600, 601, 598, 602, 599, 598, 601, 602]
    expect(map(result.origins, 'nexusId')).toEqual(expected)
  })

  test('nexusIds of destinations', () => {
    expect(map(result.destinations, 'nexusId').length).toBe(126)
  })
})

describe('shipment has destination with trucking', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasTruckingDestination
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2880, 2889, 2898, 2908, 2849, 2871, 2873, 2876, 2878]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    const expected = [599, 598, 601, 602, 599, 600, 601, 598, 602]
    expect(map(result.origins, 'nexusId')).toEqual(expected)
  })

  test('nexusIds of destinations', () => {
    expect(map(result.destinations, 'nexusId').length).toBe(126)
  })
})

describe('shipment has destination with trucking and origin', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      updatePageData: spy
    },
    shipment: shipmentHasTruckingDestinationHasOrigin
  }
  const result = RouteSection.getDerivedStateFromProps(props, {})

  test('side effect', () => {
    const [[key, payload]] = spy.mock.calls
    const expected = [2880, 2849]
    expect(map(payload.availableRoutes, 'itineraryId')).toEqual(expected)
    expect(key).toBe('ShipmentDetails')
  })

  test('truckTypes', () => {
    const expected = { destination: ['default'], origin: ['default'] }
    expect(result.truckTypes).toEqual(expected)
  })

  test('nexusIds of origins', () => {
    const expected = [599, 598, 601, 602, 599, 600, 601, 598, 602]
    expect(map(result.origins, 'nexusId')).toEqual(expected)
  })

  test('nexusIds of destinations', () => {
    const expected = [597, 597, 604, 605, 608, 608, 3282, 2932]
    expect(map(result.destinations, 'nexusId')).toEqual(expected)
  })
})

// Component's methods tests
// ============================================
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
  const expectedMarkerCall = ['TARGET', { lat: 'latitude', lng: 'longitude' }]

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

// Snapshot tests
// ============================================
test('with empty props', () => {
  expect(() => shallow(<RouteSection />)).toThrow()
})

test('shipment has neither origin nor destination', () => {
  expect(shallow(<RouteSection {...propsBase} />)).toMatchSnapshot()
})

test('shipment has both origin and destination', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipmentBase,
      origin: originBase,
      destination: destinationBase
    }
  }
  expect(shallow(<RouteSection {...props} />)).toMatchSnapshot()
})

test('shipment has destination', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipmentBase,
      destination: destinationBase
    }
  }
  expect(shallow(<RouteSection {...props} />)).toMatchSnapshot()
})
