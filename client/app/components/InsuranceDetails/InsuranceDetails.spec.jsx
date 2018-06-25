import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, user, tenant } from '../../mocks'
// eslint-disable-next-line import/no-named-as-default
import InsuranceDetails from './InsuranceDetails'

const propsBase = {
  tenant,
  user,
  theme
}

test('shallow render', () => {
  expect(shallow(<InsuranceDetails {...propsBase} />)).toMatchSnapshot()
})
