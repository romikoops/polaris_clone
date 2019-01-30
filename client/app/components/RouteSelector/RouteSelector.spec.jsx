import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, routes, identity } from '../../mocks'

import { RouteSelector } from './RouteSelector'

const propsBase = {
  routeSelected: identity,
  routes,
  theme
}

test('shallow rendering', () => {
  expect(shallow(<RouteSelector {...propsBase} />)).toMatchSnapshot()
})

test('routes is falsy', () => {
  const props = {
    ...propsBase,
    routes: null
  }
  expect(shallow(<RouteSelector {...props} />)).toMatchSnapshot()
})
