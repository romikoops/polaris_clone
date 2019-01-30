import * as React from 'react'
import { mount } from 'enzyme'
import { change, identity, theme } from '../../../mock'
// eslint-disable-next-line no-named-as-default
import TruckingDisplayPanel from './TruckingDisplayPanel'

const truckingInstance = {
  truckingPricing: {
    rates: {},
    fees: {}
  }
}

const propsBase = {
  theme,
  truckingInstance,
  adminDispatch: identity
}

test('shallow render', () => {
  expect(mount(<TruckingDisplayPanel {...propsBase} />)).toMatchSnapshot()
})

test('truckingPricing.fees is truthy', () => {
  const props = change(
    propsBase,
    'truckingInstance.truckingPricing',
    {
      fees: {
        foo: {
          currency: 'CURRENCY',
          rate_basis: 'RATE'
        }
      }
    }
  )
  expect(mount(<TruckingDisplayPanel {...props} />)).toMatchSnapshot()
})

test('truckingPricing.zipcode is truthy', () => {
  const props = change(
    propsBase,
    'truckingInstance',
    { zipcode: [['ZIPCODE']] }
  )
  expect(mount(<TruckingDisplayPanel {...props} />)).toMatchSnapshot()
})

test('truckingPricing.distance is truthy', () => {
  const props = change(
    propsBase,
    'truckingInstance',
    { distance: [['DISTANCE']] }
  )
  expect(mount(<TruckingDisplayPanel {...props} />)).toMatchSnapshot()
})

test('truckingPricing.city is truthy', () => {
  const props = change(
    propsBase,
    'truckingInstance',
    { city: [['CITY']] }
  )
  expect(mount(<TruckingDisplayPanel {...props} />)).toMatchSnapshot()
})
