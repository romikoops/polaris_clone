import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

import UserContacts from './UserContacts'

const propsBase = {
  contactData: {
    address: {},
    contact: {},
    shipments: {}
  },
  contacts: [],
  dispatch: identity,
  history,
  hubs: [],
  loading: false,
  match: { url: 'MATCH_URL' },
  setCurrentUrl: identity,
  theme,
  userDispatch: {
    confirmShipment: identity,
    getContacts: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserContacts {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<UserContacts {...props} />)).toMatchSnapshot()
})
