import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../../mock'

import ShipmentsCompAdmin from './Admin'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('../../../../helpers', () => ({
  filters: { sortByDate: x => x, sortByAlphabet: x => x },
  capitalize: x => x,
  loadOriginNexus: x => x,
  loadDestinationNexus: x => x,
  loadClients: x => x,
  loadMot: x => x
}))

const propsBase = {
  theme,
  hubs: [hub],
  shipments: { pages: {}, nexuses: {} },
  confirmShipmentData: {},
  clients: [{}],
  numShipmentsPages: 1,
  viewShipment: identity,
  hubHash: {},
  adminDispatch: {
    getShipments: identity
  }
}

test('shallow render', () => {
  expect(shallow(<ShipmentsCompAdmin {...propsBase} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }

  expect(shallow(<ShipmentsCompAdmin {...props} />)).toMatchSnapshot()
})
