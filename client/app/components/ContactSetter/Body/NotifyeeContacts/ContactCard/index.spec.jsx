import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line import/first
import ContactSetterBodyNotifyeeContactsContactCard from './'

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
    address: {}
  },
  removeFunc: identity
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
