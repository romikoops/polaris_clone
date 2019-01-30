import * as React from 'react'
import { shallow } from 'enzyme'
import { contact, theme, identity } from '../../mocks'

import AddressBook from './AddressBook'

const propsBase = {
  contacts: [contact],
  theme,
  autofillContact: identity
}

test('shallow render', () => {
  expect(shallow(<AddressBook {...propsBase} />)).toMatchSnapshot()
})
