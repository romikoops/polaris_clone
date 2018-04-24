import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, route } from '../../mocks'

import { RouteOption } from './RouteOption'

const editedRoute = {
  ...route,
  name: 'foo-bar',
  modesOfTransport: { a: 'FOO', b: 'BAR' }
}

const propsBase = {
  theme,
  route: editedRoute,
  routeSelected: false
}

const createShallow = propsInput => shallow(<RouteOption {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.routeSelected is true', () => {
  const props = {
    ...propsBase,
    routeSelected: true
  }
  expect(createShallow(props)).toMatchSnapshot()
})
