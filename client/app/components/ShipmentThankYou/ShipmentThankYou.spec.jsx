import * as React from 'react'
import { shallow } from 'enzyme'
import { user, shipmentData, identity, theme } from '../../mocks'

jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <button>{children}</button>
}))
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
