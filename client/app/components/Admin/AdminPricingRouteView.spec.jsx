import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, client, change, internalUser
} from '../../mocks'
import AdminPricingRouteView from './AdminPricingRouteView'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  adminActions: {
    getRoutePricings: identity
  },
  routePricings: {
    route: {},
    routePricingData: {}
  },
  pricingData: {
    pricings: [],
    hubRoutes: [],
    transportCategories: []
  },
  pricings: {
    ['1']: []
  },
  clients: [client],
  loading: false,
  match: {},
  itineraryPricings: {
    itinerary: {},
    itineraryPricingData: {},
    stops: [{ hub: {} }, { hub: {} }],
    userPricings: [],
    serviceLevels: {}
  },
  match: {
    params: {
      id: '1'
    }
  },
  user: internalUser
}

test('shallow render', () => {
  expect(shallow(<AdminPricingRouteView {...propsBase} />)).toMatchSnapshot()
})

test('itineraryPricings.userPricings is truthy', () => {
  const props = change(
    propsBase,
    'itineraryPricings.userPricings',
    [{}]
  )
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('itineraryPricings.userPricings is truthy + !client', () => {
  const props = change(
    propsBase,
    'itineraryPricings.userPricings',
    [{ user_id: 1 }]
  )
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('itineraryPricings.itinerary is falsy', () => {
  const props = change(
    propsBase,
    'itineraryPricings.itinerary',
    null
  )
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('pricingData is falsy', () => {
  const props = {
    ...propsBase,
    pricingData: null
  }
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('fauxShipment.origin_hub && fauxShipment.origin_hub.photo', () => {
  const props = change(
    propsBase,
    'itineraryPricings.stops',
    [{ hub: { photo: 'PHOTO' } }, { hub: {} }]
  )
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('fauxShipment.destination_hub && fauxShipment.destination_hub.photo', () => {
  const props = change(
    propsBase,
    'itineraryPricings.stops',
    [{ hub: {} }, { hub: { photo: 'PHOTO' } }]
  )
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('user.internal is true', () => {
  const props = {
    ...propsBase,
    user: internalUser
  }
  expect(shallow(<AdminPricingRouteView {...props} />)).toMatchSnapshot()
})

test('state.editorBool is true', () => {
  const wrapper = shallow(<AdminPricingRouteView {...propsBase} />)
  wrapper.setState({ editorBool: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.showPricingAdder is true', () => {
  const props = {
    ...propsBase,
    user: internalUser
  }
  const wrapper = shallow(<AdminPricingRouteView {...props} />)
  wrapper.setState({ showPricingAdder: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminPricingRouteView {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})
