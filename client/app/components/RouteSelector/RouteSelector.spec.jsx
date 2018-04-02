import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, route, identity } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'FOO_KEY'
}))
// eslint-disable-next-line import/first
import { RouteSelector } from './RouteSelector'

const propsBase = {
  theme,
  routeSelected: identity,
  routes: [route]
}

const createShallow = propsInput => shallow(<RouteSelector {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
