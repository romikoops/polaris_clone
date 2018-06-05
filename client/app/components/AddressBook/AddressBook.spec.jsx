import * as React from 'react'
import { shallow } from 'enzyme'
import { contact, theme, identity } from '../../mocks'

jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
// eslint-disable-next-line import/first
import AddressBook from './AddressBook'

const propsBase = {
  contacts: [contact],
  theme,
  autofillContact: identity
}

test('shallow render', () => {
  expect(shallow(<AddressBook {...propsBase} />)).toMatchSnapshot()
})
