import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'
// eslint-disable-next-line
import ShipmentContactsBox from './'

const propsBase = {
  theme,
  removeNotifyee: identity,
  consignee: {
    companyName: 'FOO_COMPANY_NAME',
    firstName: 'FOO_FIRST_NAME',
    lastName: 'FOO_LAST_NAME',
    email: 'FOO_EMAIL',
    phone: 'FOO_PHONE',
    street: 'FOO_STREET',
    number: '9',
    zipCode: '21785',
    city: 'Hamburg',
    country: 'Germany'
  },
  shipper: {
    companyName: 'FOO_SHIPPER_COMPANY_NAME',
    firstName: 'FOO_SHIPPER_FIRST_NAME',
    lastName: 'FOO_SHIPPER_LAST_NAME',
    email: 'FOO_SHIPPER_EMAIL',
    phone: 'FOO_SHIPPER_PHONE',
    street: 'FOO_SHIPPER_STREET',
    number: '17',
    zipCode: '27785',
    city: 'Berlin',
    country: 'Germany'
  },
  notifyees: [{
    companyName: 'FOO_NOTIFYEE_COMPANY_NAME',
    firstName: 'FOO_NOTIFYEE_FIRST_NAME',
    lastName: 'FOO_NOTIFYEE_LAST_NAME',
    email: 'FOO_NOTIFYEE_EMAIL',
    phone: 'FOO_NOTIFYEE_PHONE',
    street: 'FOO_NOTIFYEE_STREET',
    number: '5',
    zipCode: '23785',
    city: 'Bremen',
    country: 'Germany'
  }],
  setContactForEdit: identity,
  direction: 'FOO_DIRECTION',
  showAddressBook: identity
}

test('shallow render', () => {
  expect(shallow(<ShipmentContactsBox {...propsBase} />)).toMatchSnapshot()
})
