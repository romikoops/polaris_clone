import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, history, contact, shipments, location } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
// eslint-disable-next-line
import UserContacts from './UserContacts'

const propsBase = {
  theme,
  hubs: [],
  contacts: [],
  dispatch: identity,
  userDispatch: {
    getContact: identity,
    confirmShipment: identity
  },
  history,
  loading: false,
  contactData: {
    contact,
    shipments,
    location
  }
}

test.skip('shallow render', () => {
  expect(shallow(<UserContacts {...propsBase} />)).toMatchSnapshot()
})
