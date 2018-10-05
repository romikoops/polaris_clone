import * as React from 'react'
import { shallow } from 'enzyme'
import ContactsIndex from './ContactsIndex'
import { theme, user, users, tenant } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (x, y) => Component => Component
}))

const propsBase = {
  handleClick: jest.fn(),
  seeAll: jest.fn(),
  theme,
  showTooltip: false,
  store: {
    getState: jest.fn(),
    subscribe: jest.fn()
  },
  userDispatch: {
    getContacts: jest.fn()
  },
  appDispatch: jest.fn(),
  storeDispatch: jest.fn(),
  loggedIn: true,
  authentication: jest.fn(),
  contactsData: users,
  user,
  tenant
}

test('shallow render', () => {
  expect(shallow(<ContactsIndex {...propsBase} />)).toMatchSnapshot()
})
