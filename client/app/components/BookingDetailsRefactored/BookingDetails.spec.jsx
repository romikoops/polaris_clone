import * as React from 'react'
import { shallow } from 'enzyme'
import { BookingDetails } from './BookingDetails'

import {
  theme,
  shipment,
  shipmentData,
  identity,
  tenant,
  user
} from '../../mocks'

const editedShipmentData = {
  ...shipmentData,
  hubs: {}
}

const propsBase = {
  theme,
  tenant,
  shipmentData: editedShipmentData,
  nextStage: identity,
  prevRequest: {
    shipment
  },
  setStage: identity,
  hideRegistration: identity,
  shipmentDispatch: {
    toDashboard: identity
  },
  currencies: [{
    key: 'USD',
    rate: 1.05
  }],
  user
}

test('shallow render', () => {
  expect(shallow(<BookingDetails {...propsBase} />)).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<BookingDetails {...props} />)).toMatchSnapshot()
})

test('shipmentData.shipment is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...editedShipmentData,
      shipment: null
    }
  }
  expect(shallow(<BookingDetails {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<BookingDetails {...props} />)).toMatchSnapshot()
})
