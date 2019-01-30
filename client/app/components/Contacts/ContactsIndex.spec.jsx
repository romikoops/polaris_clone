import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import ContactsIndex from './ContactsIndex'
import {
  change, contacts, theme, identity
} from '../../mocks'

const contactsData = {
  contacts,
  numContactPages: 1,
  page: 1
}

const propsBase = {
  handleClick: identity,
  seeAll: identity,
  theme,
  showTooltip: false,
  store: {
    getState: identity,
    subscribe: identity
  },
  userDispatch: {
    getContacts: identity
  },
  appDispatch: identity,
  storeDispatch: identity,
  loggedIn: true,
  authentication: identity,
  contactsData
}

test('shallow render', () => {
  expect(shallow(<ContactsIndex {...propsBase} />)).toMatchSnapshot()
})

test('page > 1', () => {
  const props = change(
    propsBase,
    'contactsData.page',
    2
  )
  expect(shallow(<ContactsIndex {...props} />)).toMatchSnapshot()
})
