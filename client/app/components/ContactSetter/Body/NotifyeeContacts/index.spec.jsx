import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, notifyees } from '../../../../mocks/index'
import ContactSetterBodyNotifyeeContacts from '.'

const propsBase = {
  theme,
  notifyees,
  showAddressBook: identity,
  removeFunc: identity
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContacts {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
