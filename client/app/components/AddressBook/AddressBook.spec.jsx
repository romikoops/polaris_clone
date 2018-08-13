import * as React from 'react'
import { shallow } from 'enzyme'
import { contact, theme, identity } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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
