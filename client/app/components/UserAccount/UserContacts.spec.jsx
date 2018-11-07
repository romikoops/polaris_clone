import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, history, contact, shipments, address } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
// eslint-disable-next-line
import UserContacts from './UserContacts'

const propsBase = {
  theme,
  hubs: [],
  contacts: [],
  setCurrentUrl: jest.fn(),
  match: { url: 'google.com' },
  dispatch: identity,
  userDispatch: {
    getContacts: identity,
    confirmShipment: identity
  },
  history,
  loading: false,
  contactData: {
    contact,
    shipments,
    address
  }
}

test('shallow render', () => {
  expect(shallow(<UserContacts {...propsBase} />)).toMatchSnapshot()
})
