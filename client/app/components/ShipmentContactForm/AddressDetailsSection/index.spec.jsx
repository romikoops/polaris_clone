import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme, address } from '../../../mocks'

import AddressDetailsSection from './'

const propsBase = {
  theme,
  contactData: { address },
  handlePlaceChange: identity,
  setContactAttempted: false,
  setContactBtn: React.createElement('div')
}

test('shallow rendering', () => {
  expect(shallow(<AddressDetailsSection {...propsBase} />)).toMatchSnapshot()
})
