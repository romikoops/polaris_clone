import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment } from '../../mocks'
import UserShipmentCard from './UserShipmentCard'
import '../../mocks/libraries/moment'

const propsBase = {
  shipment
}

test('shallow rendering', () => {
  expect(shallow(<UserShipmentCard {...propsBase} />)).toMatchSnapshot()
})
