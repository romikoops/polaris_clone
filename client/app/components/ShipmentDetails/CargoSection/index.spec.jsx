import * as React from 'react'
import { shallow } from 'enzyme'
import CargoSection from '.'
import {
  ShipmentDetails,
  cargoItemTypes,
  identity,
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
  toggleModal: identity
}

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

test('with empty props', () => {
  expect(() => shallow(<CargoSection />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<CargoSection {...propsBase} />)).toMatchSnapshot()
})

test('cargoUnits is empty', () => {
  const props = {
    ...propsBase,
    bookingProcessDispatch: {
      addCargoUnit: identity
    },
    shipment: {
      aggregatedCargo: false,
      cargoUnits: []
    }
  }
  expect(shallow(<CargoSection {...props} />)).toMatchSnapshot()
})
