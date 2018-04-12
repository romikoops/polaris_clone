import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('../RouteHubBox/RouteHubBox', () => ({
  // eslint-disable-next-line react/prop-types
  Carousel: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line
import { ActiveRoutes } from './ActiveRoutes'

const propsBase = {
  theme
}

test('shallow render', () => {
  expect(shallow(<ActiveRoutes {...propsBase} />)).toMatchSnapshot()
})
