import * as React from 'react'
import { shallow } from 'enzyme'

import {
  change,
  currencies,
  identity,
  shipment,
  shipmentData,
  tenant,
  match,
  theme,
  user
} from '../../mocks'

import BookingDetails from './BookingDetails'

const propsBase = {
  theme,
  tenant,
  shipmentData,
  bookingHasCompleted: identity,
  nextStage: identity,
  prevRequest: {
    shipment
  },
  setStage: identity,
  hideRegistration: identity,
  shipmentDispatch: {
    toDashboard: identity
  },
  match,
  currencies,
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
  const props = change(
    propsBase,
    'shipmentData.shipment',
    null
  )
  expect(shallow(<BookingDetails {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<BookingDetails {...props} />)).toMatchSnapshot()
})
