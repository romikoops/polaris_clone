import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, user, hub, schedule, identity } from '../../mocks'

import RouteResult from './RouteResult'

const editedSchedule = {
  ...schedule,
  total_price: { currency: 'EUR', value: 112 },
  origin_hub: {},
  destination_hub: {},
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
