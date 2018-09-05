import * as React from 'react'
import { shallow } from 'enzyme'
import { AvailableRoutes } from './AvailableRoutes'
import { identity, theme, user } from '../../mocks'

const propsBase = {
  routes: ['foo', 'bar'],
  theme,
  user,
  userDispatch: {
    getShipment: identity,
    goTo: identity
  },
  routeSelected: identity
}

test('shallow render', () => {
  expect(shallow(<AvailableRoutes {...propsBase} />)).toMatchSnapshot()
})
