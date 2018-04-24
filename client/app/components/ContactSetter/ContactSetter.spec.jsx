import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'
// eslint-disable-next-line
import ContactSetter from './ContactSetter'

const propsBase = {
  theme,
  contacts: [],
  userLocations: [],
  shipper: {},
  consignee: {},
  notifyees: [],
  direction: 'FOO_DIRECTION',
  finishBookingAttempted: false,
  setContact: identity,
  removeNotifyee: identity
}

test('shallow render', () => {
  expect(shallow(<ContactSetter {...propsBase} />)).toMatchSnapshot()
})
