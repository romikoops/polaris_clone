import * as React from 'react'
import { shallow } from 'enzyme'
import { user, shipmentData, identity, theme } from '../../mocks'

// eslint-disable-next-line import/first
import { ShipmentThankYou } from './ShipmentThankYou'

const propsBase = {
  theme,
  shipmentData,
  shipmentDispatch: {},
  setStage: identity,
  user
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentThankYou {...propsBase} />)).toMatchSnapshot()
})
