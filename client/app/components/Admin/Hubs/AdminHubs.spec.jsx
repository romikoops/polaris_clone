import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, hub, tenant
} from '../../../mock'
import AdminHubs from './AdminHubs'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  hub,
  hubHash: {},
  hubs: [hub],
  dispatch: identity,
  setCurrentUrl: identity,
  history: {},
  tenant,
  match: { url: 'URL' },
  loading: false,
  countries: [],
  numHubPages: 1,
  appDispatch: {
    fetchCountries: identity
  },
  adminDispatch: {
    getHubs: identity
  },
  documentDispatch: {
    uploadPricings: identity
  },
  document: {}
}

test('shallow render', () => {
  expect(shallow(<AdminHubs {...propsBase} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }
  expect(shallow(<AdminHubs {...props} />)).toMatchSnapshot()
})
