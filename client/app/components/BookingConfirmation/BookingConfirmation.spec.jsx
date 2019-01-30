import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme,
  shipmentData,
  identity,
  change,
  match,
  tenant
} from '../../mocks'

import { BookingConfirmation } from './BookingConfirmation'

const propsBase = {
  theme,
  setStage: identity,
  shipmentData,
  tenant,
  shipmentDispatch: {
    toDashboard: identity
  },
  remarkDispatch: {
    getRemarks: jest.fn()
  },
  remark: {
    quotation: {
      shipment: [
        'Some remarks',
        'yea'
      ]
    }
  },
  match,
  bookingHasCompleted: () => false
}

test('shallow render', () => {
  expect(shallow(<BookingConfirmation {...propsBase} />)).toMatchSnapshot()
})

test('state.acceptTerms is true', () => {
  const wrapper = shallow(<BookingConfirmation {...propsBase} />)
  wrapper.setState({ acceptTerms: true })
  expect(wrapper).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipmentData.shipment is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...shipmentData,
      shipment: null
    }
  }
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('tenant.scope.terms.length is 0', () => {
  const props = change(
    propsBase,
    'tenant.scope.terms',
    []
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('feeHash.customs.hasUnknown is true', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.selected_offer.customs.hasUnknown',
    true
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipment.cargo_notes is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.cargo_notes',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipment.eori is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.eori',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipment.total_goods_value is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.total_goods_value',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipment.notes is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.notes',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipment.incoterm_text is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.incoterm_text',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('shipmentData.notifyees is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.notifyees',
    null
  )
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})
