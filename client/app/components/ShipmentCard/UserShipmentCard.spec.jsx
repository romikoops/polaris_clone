import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment } from '../../mocks/index'
import UserShipmentCard from './UserShipmentCard'
import '../../mocks/libraries/moment'

const propsBase = {
  shipment
}

test('shallow rendering', () => {
  expect(shallow(<UserShipmentCard {...propsBase} />)).toMatchSnapshot()
})
