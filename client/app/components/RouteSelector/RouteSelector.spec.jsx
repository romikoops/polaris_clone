import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, route, identity } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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
