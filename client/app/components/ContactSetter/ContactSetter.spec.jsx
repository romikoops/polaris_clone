import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('../StageTimeline/StageTimeline', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../ShipmentContactForm/ShipmentContactForm', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentContactForm: ({ children }) => <div>{children}</div>
}))
jest.mock('../AddressBook/AddressBook', () => ({
  // eslint-disable-next-line react/prop-types
  AddressBook: ({ children }) => <div>{children}</div>
}))
jest.mock('../ShipmentContactsBox/ShipmentContactsBox', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentContactsBox: ({ children }) => <div>{children}</div>
}))
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
