import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mocks'
import ContactSetterBodyNotifyeeContacts from './'

const contact = {
  email: 'foo@bar.baz',
  phone: '0761452887',
  firstName: 'John',
  lastName: 'Doe',
  companyName: 'FOO_CONTACT_COMPANY'
}

const contactSecond = {
  email: 'foo2@bar.baz',
  phone: '0721452887',
  firstName: 'Richard',
  lastName: 'D',
  companyName: 'BAR_CONTACT_COMPANY'
}

const propsBase = {
  theme,
  notifyees: [
    {
      contact,
      address: {}
    },
    {
      contactSecond,
      address: {}
    }
  ],
  showAddressBook: identity,
  removeFunc: identity
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContacts {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
