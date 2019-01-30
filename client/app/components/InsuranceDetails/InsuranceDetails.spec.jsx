import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, user, tenant } from '../../mocks'

import InsuranceDetails from './InsuranceDetails'

const propsBase = {
  tenant,
  user,
  theme
}

test('shallow render', () => {
  expect(shallow(<InsuranceDetails {...propsBase} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }
  expect(shallow(<InsuranceDetails {...props} />)).toMatchSnapshot()
})
