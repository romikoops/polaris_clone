import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mocks/index'

jest.mock('../../../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import ShipmentContactsBoxMainContacts from './'

const contact = {
  email: 'foo@bar.baz',
  phone: '0761452887',
  firstName: 'John',
  lastName: 'Doe',
  companyName: 'FOO_CONTACT_COMPANY'
}

const propsBase = {
  theme,
  shipper: {
    contact,
    address: {}
  },
  consignee: {
    contact: {},
    address: {}
  },
  direction: 'FOO_DIRECTION',
  showAddressBook: identity
}

test('shallow render', () => {
  const Component = <ShipmentContactsBoxMainContacts {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
