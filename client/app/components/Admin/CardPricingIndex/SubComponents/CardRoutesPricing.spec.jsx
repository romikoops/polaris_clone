import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mock'
import CardRoutesPricing from './CardRoutesPricing'

const itineraryBase = {
  name: 'FOO-BAR',
  mode_of_transport: 'ocean',
  users_with_pricing: 'USERS_WITH_PRICING',
  pricing_count: 4
}

const propsBase = {
  theme,
  itinerary: itineraryBase,
  handleClick: identity,
  onDisabledClick: identity,
  disabled: false
}

test('shallow render', () => {
  expect(shallow(<CardRoutesPricing {...propsBase} />)).toMatchSnapshot()
})

test('pricing_count is falsy', () => {
  const itinerary = {
    ...itineraryBase,
    pricing_count: null
  }
  const props = {
    ...propsBase,
    itinerary
  }
  expect(shallow(<CardRoutesPricing {...props} />)).toMatchSnapshot()
})

test('users_with_pricing is falsy', () => {
  const itinerary = {
    ...itineraryBase,
    users_with_pricing: null
  }
  const props = {
    ...propsBase,
    itinerary
  }
  expect(shallow(<CardRoutesPricing {...props} />)).toMatchSnapshot()
})

test('disabled is true', () => {
  const props = {
    ...propsBase,
    disabled: true
  }
  expect(shallow(<CardRoutesPricing {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<CardRoutesPricing {...props} />)).toMatchSnapshot()
})
