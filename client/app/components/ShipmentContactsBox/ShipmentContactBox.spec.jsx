import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, location } from '../../mocks'

import { v4 } from 'node-uuid'
import { ContactCard } from '../ContactCard/ContactCard'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))

jest.mock('../ContactCard/ContactCard', () => {
  // eslint-disable-next-line react/prop-types
  const ContactCard = ({ children }) => <div>{children}</div>

  return {
    ContactCard
  }
})

// eslint-disable-next-line import/first
import { ShipmentContactsBox } from './ShipmentContactsBox'

const shipper = {
  companyName: 'BAR_COMPANY',
  firstName: 'BAR_FIRST_NAME',
  lastName: 'BAR_LAST_NAME',
  email: 'bar@yahoo.de',
  phone: '0766845382',
  street: 'BAR_STREET',
  number: '13',
  zipCode: '27890',
  city: 'BAR_CITY',
  country: 'BAR_COUNTRY'
}

const propsBase = {
  theme,
  removeNotifyee: identity,
  consignee: {
    companyName: 'FOO_COMPANY',
    firstName: 'FOO_FIRST_NAME',
    lastName: 'FOO_LAST_NAME',
    email: 'foo@yahoo.de',
    phone: '0712845332',
    street: 'FOO_STREET',
    number: '123',
    zipCode: '22133',
    city: 'FOO_CITY',
    country: 'FOO_COUNTRY'
  },
  shipper,
  notifyees: [shipper],
  setContactForEdit: identity,
  direction: 'FOO_DIRECTION',
  finishBookingAttempted: false
}

const createShallow = propsInput => shallow(<ShipmentContactsBox {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.finishBookingAttempted is true', () => {
  const props = {
    ...propsBase,
    finishBookingAttempted: true
  }
  expect(createShallow(props)).toMatchSnapshot()
})
