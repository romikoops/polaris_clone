import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  identity,
  shipmentData,
  tenant,
  theme,
  turnFalsy,
  user
} from '../../mocks'

import ShipmentThankYou from './ShipmentThankYou'

const propsBase = {
  theme,
  tenant,
  shipmentData,
  shipmentDispatch: {},
  setStage: identity,
  user
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentThankYou {...propsBase} />)).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<ShipmentThankYou {...props} />)).toMatchSnapshot()
})

test('shipmentData.shipment is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'shipmentData.shipment'
  )
  expect(shallow(<ShipmentThankYou {...props} />)).toMatchSnapshot()
})

test('shipment.status === requested_by_unconfirmed_account', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.status',
    'requested_by_unconfirmed_account'
  )
  expect(shallow(<ShipmentThankYou {...props} />)).toMatchSnapshot()
})
