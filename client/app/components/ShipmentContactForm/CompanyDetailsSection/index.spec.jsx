import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, address } from '../../../mocks'

import CompanyDetailsSection from './'

const propsBase = {
  theme,
  contactData: {
    address,
    contact: {
      companyName: 'FOO_COMPANY_NAME',
      firstName: 'FOO_FIRST_NAME',
      lastName: 'FOO_LAST_NAME',
      email: 'foo@bar.com',
      phone: '0789323143'
    }
  },
  setContactAttempted: false
}

test('shallow rendering', () => {
  expect(shallow(<CompanyDetailsSection {...propsBase} />)).toMatchSnapshot()
})
