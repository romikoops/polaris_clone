import * as React from 'react'
import { shallow } from 'enzyme'
import { user, address } from '../../../mocks'
import ContactDetailsRow from './ContactDetailsRow'

const contactBase = {
  type: 'notifyee',
  contact: {
    email: 'EMAIL',
    user_id: 'USER_ID',
    first_name: 'FIRST_NAME',
    last_name: 'LAST_NAME',
    company_name: 'COMPANY_NAME'
  },
  address

}

const propsBase = {
  contacts: [],
  style: {},
  accountId: 0,
  user
}

test('shallow render', () => {
  expect(shallow(<ContactDetailsRow {...propsBase} />)).toMatchSnapshot()
})

test('contact.type === notifee', () => {
  const props = {
    ...propsBase,
    contacts: [contactBase]
  }
  expect(shallow(<ContactDetailsRow {...props} />)).toMatchSnapshot()
})

test('contact.type === shipper', () => {
  const contact = {
    ...contactBase,
    type: 'shipper'
  }
  const props = {
    ...propsBase,
    contacts: [contact]
  }
  expect(shallow(<ContactDetailsRow {...props} />)).toMatchSnapshot()
})

test('contact.type === consignee', () => {
  const contact = {
    ...contactBase,
    type: 'consignee'
  }
  const props = {
    ...propsBase,
    contacts: [contact]
  }
  expect(shallow(<ContactDetailsRow {...props} />)).toMatchSnapshot()
})
