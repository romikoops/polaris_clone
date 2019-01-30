import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, user } from '../../mocks'
import TermsAndConditions from './TermsAndConditions'

const propsBase = {
  theme,
  user,
  tenant
}

test('shallow rendering when props.size is small', () => {
  expect(shallow(<TermsAndConditions {...propsBase} />)).toMatchSnapshot()
})
