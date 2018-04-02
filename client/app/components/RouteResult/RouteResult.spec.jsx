import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, user, hub, schedule, identity } from '../../mocks'

import { RouteResult } from './RouteResult'

const editedSchedule = {
  ...schedule,
  closing_date: 1522259422177,
  etd: 1522250422177,
  eta: 1522269422177
}

const propsBase = {
  theme,
  schedule: editedSchedule,
  selectResult: identity,
  fees: {
    [schedule.hub_route_key]: {
      total: { value: 12 }
    }
  },
  originHubs: [hub],
  destinationHubs: [hub],
  user,
  pickup: true
}

const createShallow = propsInput => shallow(<RouteResult {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.pickup is false', () => {
  const props = {
    ...propsBase,
    pickup: false
  }
  expect(createShallow(props)).toMatchSnapshot()
})
