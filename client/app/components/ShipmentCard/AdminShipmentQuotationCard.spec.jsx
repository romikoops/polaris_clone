import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  shipment, theme, identity, change, turnFalsy
} from '../../mocks'
import AdminShipmentQuotationCard from './AdminShipmentQuotationCard'

const propsBase = {
  confirmShipmentData: identity,
  dispatches: {},
  shipment,
  theme
}

test('shallow rendering', () => {
  expect(shallow(<AdminShipmentQuotationCard {...propsBase} />)).toMatchSnapshot()
})

test('shipment.delivery_address is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'shipment.delivery_address'
  )
  expect(shallow(<AdminShipmentQuotationCard {...props} />)).toMatchSnapshot()
})

test('shipment.pickup_address is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'shipment.pickup_address'
  )
  expect(shallow(<AdminShipmentQuotationCard {...props} />)).toMatchSnapshot()
})

test('shipment.planned_eta is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'shipment.planned_eta'
  )
  expect(shallow(<AdminShipmentQuotationCard {...props} />)).toMatchSnapshot()
})

test('shipment.status !== finished', () => {
  const props = change(
    propsBase,
    'shipment.status',
    'approved'
  )
  expect(shallow(<AdminShipmentQuotationCard {...props} />)).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(
    <AdminShipmentQuotationCard {...propsBase} />
  )
  wrapper.setState({ confirm: true })
  expect(wrapper).toMatchSnapshot()
})
