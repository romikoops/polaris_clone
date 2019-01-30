import '../../mocks/libraries/momentStatic'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  shipment, identity, theme, cargoItems
} from '../../mocks'

import RouteFilterBox from './RouteFilterBox'

const availableMotKeys = {
  foo: 'FOO',
  bar: 'BAR'
}

const propsBase = {
  availableMotKeys,
  cargos: cargoItems,
  departureDate: 0,
  durationFilter: 1,
  pickup: true,
  setDepartureDate: identity,
  setDurationFilter: identity,
  setMoT: identity,
  shipment,
  theme
}

test('shallow rendering', () => {
  expect(shallow(<RouteFilterBox {...propsBase} />)).toMatchSnapshot()
})

test('pickup is false', () => {
  const props = {
    ...propsBase,
    pickup: false
  }
  expect(shallow(<RouteFilterBox {...props} />)).toMatchSnapshot()
})

test('availableMotKeys is empty object', () => {
  const props = {
    ...propsBase,
    availableMotKeys: {}
  }
  expect(shallow(<RouteFilterBox {...props} />)).toMatchSnapshot()
})
