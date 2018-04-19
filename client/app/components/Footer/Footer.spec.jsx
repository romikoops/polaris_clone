import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant } from '../../mocks'

import { Footer } from './Footer'

const propsBase = {
  theme,
  tenant
}

test('shallow render', () => {
  expect(shallow(<Footer {...propsBase} />)).toMatchSnapshot()
})
