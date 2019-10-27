import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, client, user } from '../../mock'
import AdminPricingsIndex from './AdminPricingsIndex'

const propsBase = {
  theme,
  clients: [client],
  adminDispatch: {
    getClientPricings: identity,
    getRoutePricings: identity
  },
  user: user,
  documentDispatch: {
    closeViewer: identity,
    uploadPricings: identity
  },
  pricingData: {
    routes: [],
    detailedItineraries: [{}],
    lastUpdate: 'LAST_UPDATE'
  },
  scope: { modes_of_transport: {} },
  hubHash: {}
}

test('shallow render', () => {
  expect(shallow(<AdminPricingsIndex {...propsBase} />)).toMatchSnapshot()
})

test('state.state.redirectRoutes is true', () => {
  const wrapper = shallow(<AdminPricingsIndex {...propsBase} />)
  wrapper.setState({ redirectRoutes: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.state.redirectClients is true', () => {
  const wrapper = shallow(<AdminPricingsIndex {...propsBase} />)
  wrapper.setState({ redirectClients: true })
  expect(wrapper).toMatchSnapshot()
})

test('scope.modes_of_transport is true', () => {
  const props = {
    ...propsBase,
    scope: {
      modes_of_transport: [{ foo: 'FOO' }]
    }
  }
  expect(shallow(<AdminPricingsIndex {...props} />)).toMatchSnapshot()
})

test('pricingData is falsy', () => {
  const props = {
    ...propsBase,
    pricingData: null
  }
  expect(shallow(<AdminPricingsIndex {...props} />)).toMatchSnapshot()
})
