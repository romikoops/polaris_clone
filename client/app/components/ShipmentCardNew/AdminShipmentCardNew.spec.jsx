import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, identity, theme, hub } from '../../mocks'

import { AdminShipmentCardNew } from './AdminShipmentCardNew'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('../../helpers', () => ({
  gradientGenerator: x => x,
  gradientTextGenerator: x => x,
  gradientBorderGenerator: x => x,
  switchIcon: x => x,
  formattedPriceValue: () => 1034,
  totalPrice: () => ({ currency: 'CNY' })
}))
jest.mock('moment', () => {
  const format = () => 19
  const diff = () => 18

  return () => ({
    format,
    diff
  })
})

shipment.origin_hub = { name: 'FOO_ORIGIN_HUB' }
shipment.destination_hub = { name: 'FOO_DESTINATION_HUB' }

const propsBase = {
  shipment,
  dispatches: { foo: identity },
  theme,
  hubs: { foo: hub }
}

test.skip('shallow rendering', () => {
  expect(shallow(<AdminShipmentCardNew {...propsBase} />)).toMatchSnapshot()
})
