import * as React from 'react'
import { mount } from 'enzyme'

jest.mock('../ContactCard/ContactCard', () => {
  const ContactCard = () => <div />

  return {
    ContactCard
  }
})
// eslint-disable-next-line import/first
import { AddressBook } from './AddressBook'

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
