import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, identity, theme, hub } from '../../mocks'

import { AdminShipmentCard } from './AdminShipmentCard'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

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

<<<<<<< HEAD:client/app/components/ShipmentCardNew/AdminShipmentCardNew.spec.jsx
test.skip('shallow rendering', () => {
  expect(shallow(<AdminShipmentCardNew {...propsBase} />)).toMatchSnapshot()
=======
test('shallow rendering', () => {
  expect(shallow(<AdminShipmentCard {...propsBase} />)).toMatchSnapshot()
>>>>>>> 451fc811dc2fd8b819b9b155b26590b18e2e58cd:client/app/components/ShipmentCard/AdminShipmentCard.spec.jsx
})
