import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks/index'
// eslint-disable-next-line no-named-as-default
import ActiveRoutes from './ActiveRoutes'

const propsBase = {
  theme
}

test('shallow render', () => {
  expect(shallow(<ActiveRoutes {...propsBase} />)).toMatchSnapshot()
})
