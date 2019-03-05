import {
  cargoItem,
  cargoItemAggregated,
  cargoItemContainer,
  destination,
  origin,
  scope,
  selectedDay,
  tenant,
  trucking,
  user
} from './mocks'

import ShipmentDetails from '.'

const identity = x => x

const shipmentBase = {
  aggregatedCargo: false,
  cargoUnits: [cargoItem],
  direction: 'export',
  destination,
  id: 1,
  loadType: 'cargo_item',
  origin,
  selectedDay,
  trucking
}

const propsBase = {
  scope,
  user,
  tenant,
  t: identity,
  shipmentId: shipmentBase.id,
  shipment: shipmentBase,
  bookingProcessDispatch: {
    resetStore: identity,
    updateShipment: identity
  },
  shipmentDispatch: {
    getOffers: identity
  }
}

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

test('bookingProcessDispatch.resetStore is called', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    shipmentId: 2,
    bookingProcessDispatch: {
      resetStore: spy,
      updateShipment: identity
    }
  }
  new ShipmentDetails(props)
  expect(spy).toHaveBeenCalled()
})

test('get offers when cargo type is cargo item', () => {
  const spy = jest.fn()
  const props = {
    ...propsBase,
    shipmentDispatch: {
      getOffers: spy
    }
  }
  const Component = new ShipmentDetails(props)
  Component.getOffers()
  const [[spyCall]] = spy.mock.calls

  expect(spyCall.shipment.selected_day).toBe(selectedDay)
  expect(spyCall.shipment.cargo_items_attributes).toEqual([cargoItem])
  expect(spyCall.shipment.containers_attributes).toEqual([])
  expect(spyCall.shipment.aggregated_cargo_attributes).toEqual(null)
})

test('get offers when cargo type is aggregated cargo item', () => {
  const spy = jest.fn()
  const shipment = {
    ...shipmentBase,
    aggregatedCargo: true,
    cargoUnits: [cargoItemAggregated]
  }
  const props = {
    ...propsBase,
    shipment,
    shipmentDispatch: {
      getOffers: spy
    }
  }
  const Component = new ShipmentDetails(props)
  Component.getOffers()
  const [[spyCall]] = spy.mock.calls

  expect(spyCall.shipment.cargo_items_attributes).toEqual([])
  expect(spyCall.shipment.containers_attributes).toEqual([])
  expect(spyCall.shipment.aggregated_cargo_attributes).toEqual({
    weight: 346,
    volume: 122
  })
})

test('get offers when cargo type is container', () => {
  const spy = jest.fn()
  const shipment = {
    ...shipmentBase,
    loadType: 'container',
    cargoUnits: [cargoItemContainer]
  }
  const props = {
    ...propsBase,
    shipment,
    shipmentDispatch: {
      getOffers: spy
    }
  }
  const Component = new ShipmentDetails(props)
  Component.getOffers()
  const [[spyCall]] = spy.mock.calls

  expect(spyCall.shipment.cargo_items_attributes).toEqual([])
  expect(spyCall.shipment.containers_attributes).toEqual([cargoItemContainer])
  expect(spyCall.shipment.aggregated_cargo_attributes).toEqual(null)
})

test('get offers when selected day is falsy', () => {
  const spy = jest.fn()
  const shipment = {
    ...shipmentBase,
    selectedDay: null
  }
  const props = {
    ...propsBase,
    shipment,
    shipmentDispatch: {
      getOffers: spy
    }
  }
  const Component = new ShipmentDetails(props)
  Component.getOffers()
  const [[spyCall]] = spy.mock.calls

  expect(spyCall.shipment.selected_day).not.toEqual(selectedDay)
  expect(typeof spyCall.shipment.selected_day).toBe('string')
})

test('getVisibleModal returns an object', () => {
  const props = {
    ...propsBase,
    BookingDetails: {
      modals: {
        nonStackable: true,
        noDangerousGoods: false
      }
    }
  }
  const Component = new ShipmentDetails(props)
  const visibleModal = Component.getVisibleModal()
  expect(typeof visibleModal).toBe('object')
})

test('getVisibleModal when all modal states are false', () => {
  const props = {
    ...propsBase,
    BookingDetails: {
      modals: {
        nonStackable: false,
        noDangerousGoods: false
      }
    }
  }
  const Component = new ShipmentDetails(props)
  expect(Component.getVisibleModal()).toBe('')
})
