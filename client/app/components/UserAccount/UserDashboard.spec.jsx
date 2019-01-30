import * as React from 'react'
import { shallow } from 'enzyme'
import {
  address,
  identity,
  match,
  tenant,
  theme,
  user
} from '../../mocks'
import UserDashboard from './UserDashboard'

const propsBase = {
  dashboard: {
    addresses: [address],
    contacts: [],
    pricings: {},
    shipments: {}
  },
  hubs: {},
  match,
  scope: tenant.scope,
  seeAll: identity,
  setCurrentUrl: identity,
  setNav: identity,
  tenant,
  theme,
  user,
  userDispatch: {
    getShipment: identity,
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserDashboard {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<UserDashboard {...props} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<UserDashboard {...props} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }
  expect(shallow(<UserDashboard {...props} />)).toMatchSnapshot()
})
