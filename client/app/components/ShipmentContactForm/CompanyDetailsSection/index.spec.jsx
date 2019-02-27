import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, firstAddress, contact } from '../../../mocks/index'

import CompanyDetailsSection from '.'

const propsBase = {
  theme,
  contactData: {
    address: firstAddress,
    contact
  },
  setContactAttempted: false
}

test('shallow rendering', () => {
  expect(shallow(<CompanyDetailsSection {...propsBase} />)).toMatchSnapshot()
})
