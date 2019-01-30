import * as React from 'react'
import { shallow } from 'enzyme'

import { theme, identity } from '../../../../mock'
import CardRoutes from './CardRoutes'

const propsBase = {
  theme,
  itinerary: { name: 'FOO - BAR' },
  handleClick: identity,
  onDisabledClick: identity,
  disabled: false
}

test('shallow render', () => {
  expect(shallow(<CardRoutes {...propsBase} />)).toMatchSnapshot()
})
