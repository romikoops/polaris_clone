import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme, location } from '../../../mocks'

import AddressDetailsSection from './'

const propsBase = {
  theme,
  contactData: { location },
  handlePlaceChange: identity,
  setContactAttempted: false,
  setContactBtn: React.createElement('div')
}

test('shallow rendering', () => {
  expect(shallow(<AddressDetailsSection {...propsBase} />)).toMatchSnapshot()
})
