import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'
import { ActiveRoutes } from './ActiveRoutes'

const propsBase = {
  theme
}

test('shallow render', () => {
  expect(shallow(<ActiveRoutes {...propsBase} />)).toMatchSnapshot()
})
