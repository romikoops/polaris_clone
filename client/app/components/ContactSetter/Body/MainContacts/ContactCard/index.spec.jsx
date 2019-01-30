import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, contact } from '../../../../../mocks'

import ShipmentContactsBoxMainContactsContactCard from '.'

const propsBase = {
  contactData: {
    address: {},
    contact
  },
  contactType: 'FOO_CONTACT_TYPE',
  showAddressBook: identity,
  theme
}

test('shallow render', () => {
  const Component = <ShipmentContactsBoxMainContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
