import * as React from 'react'
import { shallow } from 'enzyme'
import { location, identity } from '../../mock'

import AdminTrucking from './AdminTrucking'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const hub = {
  location,
  data: {
    name: 'FOO_NAME',
    hub_code: 'FOO_HUB_CODE'
  },
  name: 'FOO_HUB_NAME'
}
const secondHub = {
  location,
  data: {
    name: 'BAR_NAME',
    hub_code: 'BAR_HUB_CODE'
  },
  name: 'BAR_HUB_NAME'
}

const propsBase = {
  hubs: [hub, secondHub],
  hubHash: {},
  adminDispatch: {
    viewTrucking: identity,
    getTrucking: identity
  },
  trucking: {
    truckingHubs: [],
    truckingPrices: []
  },
  dispatch: identity,
  loading: false,
  truckingDetail: { truckingHub: {}, pricing: {} },
  appDispatch: {}
}

test('shallow render', () => {
  expect(shallow(<AdminTrucking {...propsBase} />)).toMatchSnapshot()
})

test('trucking is falsy', () => {
  const props = {
    ...propsBase,
    trucking: null
  }
  expect(shallow(<AdminTrucking {...props} />)).toMatchSnapshot()
})
