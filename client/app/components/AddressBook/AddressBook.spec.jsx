import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { contact, theme, identity } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../ContactCard/ContactCard', () => ({
  // eslint-disable-next-line react/prop-types
  ContactCard: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { AddressBook } from './AddressBook'

const propsBase = {
  contacts: [contact],
  theme,
  autofillContact: identity
}

test('basic mount', () => {
  const props = {
    autofillContact: jest.fn()
  }

  const wrapper = mount(<AddressBook {...props} />)

  expect(wrapper.find('div').length).toBeGreaterThan(0)
})

test('renders empty string when no contact is passed', () => {
  const props = {
    autofillContact: jest.fn()
  }

  const wrapper = mount(<AddressBook {...props} />)
  const text = wrapper.text()

  expect(text).toBe('')
})

test('shallow render', () => {
  expect(shallow(<AddressBook {...propsBase} />)).toMatchSnapshot()
})
