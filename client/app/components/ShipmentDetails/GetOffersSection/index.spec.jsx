import * as React from 'react'
import { shallow } from 'enzyme'
import GetOffersSection from '.'
import {
  selectedDay,
  tenant,
  user,
  theme,
  cargoItem
} from '../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const shipmentBase = {
  selectedDay,
  incoterm: {},
  cargoUnits: [cargoItem],
  preCarriage: false,
  onCarriage: false,
  direction: 'export'
}

const propsBase = {
  user,
  tenant,
  shipment: shipmentBase,
  theme
}

test('with empty props', () => {
  expect(() => shallow(<GetOffersSection />)).toThrow()
})

test('renders correctly', () => {
  expect(shallow(<GetOffersSection {...propsBase} />)).toMatchSnapshot()
})
