import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change, shipment, identity, theme
} from '../../mocks'
import AdminShipmentCard from './AdminShipmentCard'

const propsBase = {
  shipment,
  dispatches: { foo: identity },
  theme,
  hubs: {}
}

test('shallow rendering', () => {
  expect(shallow(<AdminShipmentCard {...propsBase} />)).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminShipmentCard {...propsBase} />)
  wrapper.setState({ confirm: true })
  expect(wrapper).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminShipmentCard {...props} />)).toMatchSnapshot()
})

test('shipment.has_pre_carriage is true', () => {
  const props = change(
    propsBase,
    'shipment.has_pre_carriage',
    true
  )
  expect(shallow(<AdminShipmentCard {...props} />)).toMatchSnapshot()
})

test('shipment.has_on_carriage is true', () => {
  const props = change(
    propsBase,
    'shipment.has_on_carriage',
    true
  )
  expect(shallow(<AdminShipmentCard {...props} />)).toMatchSnapshot()
})

test('shipment.status !== finished', () => {
  const props = change(
    propsBase,
    'shipment.status',
    'requested'
  )
  expect(shallow(<AdminShipmentCard {...props} />)).toMatchSnapshot()
})

test('shipment.planned_eta is falsy', () => {
  const props = change(
    propsBase,
    'shipment.planned_eta',
    null
  )
  expect(shallow(<AdminShipmentCard {...props} />)).toMatchSnapshot()
})
