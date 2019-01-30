import * as React from 'react'
import { shallow } from 'enzyme'
import {
  address,
  contact,
  identity,
  theme
} from '../../../../../mocks'

import ShipmentContactsBoxMainContactsPlaceholderCard from '.'

const propsBase = {
  theme,
  contactData: {
    contact,
    address
  },
  contactType: 'FOO_CONTACT_TYPE',
  showAddressBook: identity
}

test('shallow render', () => {
  expect(shallow(
    <ShipmentContactsBoxMainContactsPlaceholderCard {...propsBase} />
  )).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(
    <ShipmentContactsBoxMainContactsPlaceholderCard {...props} />
  )).toMatchSnapshot()
})
