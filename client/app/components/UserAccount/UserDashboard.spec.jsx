import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipments, address, tenant } from '../../mocks'

jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('./index.jsx', () => ({
  // eslint-disable-next-line react/prop-types
  UserLocations: ({ children }) => <div>{children}</div>
}))
jest.mock('../Admin/AdminSearchables', () => ({
  // eslint-disable-next-line react/prop-types
  AdminSearchableClients: ({ children }) => <div>{children}</div>
}))

// eslint-disable-next-line import/first
import UserDashboard from './UserDashboard'

const propsBase = {
  theme,
  setNav: identity,
  userDispatch: {
    getShipment: identity,
    goTo: identity
  },
  setCurrentUrl: jest.fn(),
  match: { url: 'google.com' },
  seeAll: identity,
  user,
  scope: tenant.data.scope,
  hubs: {},
  dashboard: {
    shipments,
    pricings: {},
    contacts: [],
    addresses: [address]
  }
}

test('shallow render', () => {
  expect(shallow(<UserDashboard {...propsBase} />)).toMatchSnapshot()
})
