import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change, theme, shipmentData, user, identity
} from '../../mocks/index'

import MessageShipmentData from './MessageShipmentData'

const propsBase = {
  theme,
  name: 'MAME',
  onChange: identity,
  shipmentData,
  pickupDate: '2018-12-02T11:14:33z',
  closeInfo: identity,
  user
}

test('shallow render', () => {
  expect(shallow(<MessageShipmentData {...propsBase} />)).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<MessageShipmentData {...props} />)).toMatchSnapshot()
})

test('load_type !== cargo_item', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.load_type',
    'FOO_LOAD_TYPE'
  )

  expect(shallow(<MessageShipmentData {...props} />)).toMatchSnapshot()
})

test('has_pre_carriage is true', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.has_pre_carriage',
    true
  )

  expect(shallow(<MessageShipmentData {...props} />)).toMatchSnapshot()
})

test('has_on_carriage is true', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.has_on_carriage',
    true
  )

  expect(shallow(<MessageShipmentData {...props} />)).toMatchSnapshot()
})
