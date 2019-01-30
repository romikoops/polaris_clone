import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, client, user, shipment, tenant
} from '../../mock'

import AdminDashboard from './AdminDashboard'

jest.mock('../../helpers/tenant', () => x => x && x.isQuote)

const propsBase = {
  tenant,
  match: { url: 'URL' },
  user,
  theme,
  scope: {},
  dashData: {
    schedules: []
  },
  confirmShipmentData: {},
  handleClick: identity,
  setCurrentUrl: identity,
  clients: [client],
  shipments: {
    open: [shipment],
    requested: [shipment],
    finished: [shipment]
  },
  hubHash: {},
  adminDispatch: {
    getDashboard: identity,
    getShipment: identity,
    getHub: identity,
    confirmShipment: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminDashboard {...propsBase} />)).toMatchSnapshot()
})

test('dashData is falsy', () => {
  const props = {
    ...propsBase,
    dashData: null
  }

  expect(shallow(<AdminDashboard {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminDashboard {...props} />)).toMatchSnapshot()
})

test('isQuote(tenant) is true', () => {
  const props = {
    ...propsBase,
    tenant: {
      ...tenant,
      isQuote: true
    }
  }

  expect(shallow(<AdminDashboard {...props} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }

  expect(shallow(<AdminDashboard {...props} />)).toMatchSnapshot()
})
