import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

import { RouteFilterBox } from './RouteFilterBox'

const propsBase = {
  departureDate: 0,
  theme,
  setDurationFilter: identity,
  setMoT: identity,
  setDepartureDate: identity,
  durationFilter: 1,
  pickup: true,
  shipment: {}
}

const createShallow = propsInput => shallow(<RouteFilterBox {...propsInput} />)

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
