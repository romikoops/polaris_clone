import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment } from '../../mocks'

import { UserShipmentCard } from './UserShipmentCard'

jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x,
  gradientGenerator: x => x,
  gradientBorderGenerator: x => x,
  switchIcon: x => x,
  totalPrice: () => ({ currency: 'DZD' }),
  formattedPriceValue: () => 975
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('moment', () => {
  const format = () => 19
  const diff = () => 17

  return () => ({
    format,
    diff
  })
})

const propsBase = {
  shipment
}

test('shallow rendering', () => {
  expect(shallow(<UserShipmentCard {...propsBase} />)).toMatchSnapshot()
})
