import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, oceanSchedule } from '../../mocks'

import RouteResult from './RouteResult'

const propsBase = {
  pickup: true,
  schedule: oceanSchedule,
  theme,
  truckingTime: 10000
}

test('shallow rendering', () => {
  expect(shallow(<RouteResult {...propsBase} />)).toMatchSnapshot()
})

test('props.pickup is false', () => {
  const props = {
    ...propsBase,
    pickup: false
  }
  expect(shallow(<RouteResult {...props} />)).toMatchSnapshot()
})
