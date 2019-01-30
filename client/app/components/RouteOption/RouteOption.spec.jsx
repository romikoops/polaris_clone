import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, firstRoute } from '../../mocks'

import { RouteOption } from './RouteOption'

const propsBase = {
  theme,
  route: firstRoute,
  routeSelected: false
}

test('shallow rendering', () => {
  expect(
    shallow(<RouteOption {...propsBase} />)
  ).toMatchSnapshot()
})
