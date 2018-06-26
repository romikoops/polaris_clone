import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment } from '../../mocks'

import { UserShipmentCard } from './UserShipmentCard'

jest.mock('moment', () => {
  const format = () => 19

  return () => ({
    format
  })
})

const propsBase = {
  shipment
}

test('shallow rendering', () => {
  expect(shallow(<UserShipmentCard {...propsBase} />)).toMatchSnapshot()
})
