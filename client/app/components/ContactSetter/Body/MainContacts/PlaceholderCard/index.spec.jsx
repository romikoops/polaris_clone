import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../../mocks'

jest.mock('../../../../../helpers', () => ({
  nameToDisplay: x => x,
  capitalize: x => x
}))
// eslint-disable-next-line
import ShipmentContactsBoxMainContactsPlaceholderCard from './'

const contact = {
  email: 'foo@bar.baz',
  phone: '0761452887',
  firstName: 'John',
  lastName: 'Doe',
  companyName: 'FOO_CONTACT_COMPANY'
}

const propsBase = {
  theme,
  contactData: {
    contact,
    location: {}
  },
  contactType: 'FOO_CONTACT_TYPE',
  showAddressBook: identity
}

test('shallow render', () => {
  const Component = <ShipmentContactsBoxMainContactsPlaceholderCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
