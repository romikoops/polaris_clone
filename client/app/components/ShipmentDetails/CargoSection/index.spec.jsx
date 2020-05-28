import * as React from 'react'
import { shallow } from 'enzyme'
import CargoSection from '.'
import {
  ShipmentDetails,
  cargoItemTypes,
  maxDimensions,
  scope,
  cargoItem,
  theme
} from '../mocks'

const propsBase = {
  theme,
  scope,
  cargoItemTypes,
  maxDimensions,
  shipment: {
    cargoUnits: [cargoItem],
    aggregatedCargo: false
  },
  ShipmentDetails,
  toggleModal: null,
  bookingProcessDispatch: {
    updateShipment: () => true
  }
}
jest.useFakeTimers()
jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => (Component) => Component
}))
test('with empty props', () => {
  expect(() => shallow(<CargoSection />)).toThrow()
})
test('renders correctly', () => {
  expect(shallow(<CargoSection {...propsBase} />)).toMatchSnapshot()
})
test('cargoUnits is empty', () => {
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      addCargoUnit: (x) => x
    },
    shipment: {
      aggregatedCargo: false,
      cargoUnits: []
    }
  }
  expect(shallow(<CargoSection {...props} />)).toMatchSnapshot()
})
test('tenant has default_total_dimensions enabled', () => {
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      addCargoUnit: jest.fn(),
      updateShipment: jest.fn()
    },
    scope: {
      default_total_dimensions: true
    },
    shipment: {
      aggregatedCargo: false,
      cargoUnits: []
    }
  }
  expect(shallow(<CargoSection {...props} />)).toMatchSnapshot()
})
test('it toggles the total_dimensions', () => {
  const wrapper = shallow(<CargoSection {...propsBase} />)
  const instance = wrapper.instance()
  expect(wrapper.state('aggregateSection')).toBe(false)
  instance.handleToggleAggregated()
  jest.runAllTimers()
  expect(wrapper.state('aggregateSection')).toBe(true)
})
