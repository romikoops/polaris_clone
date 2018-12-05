import * as React from 'react'
import { shallow } from 'enzyme'
import {
  user, theme, location, identity, tenant, shipment
} from '../../mocks'

import AdminShipments from './AdminShipments'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('../../components/FileUploader/FileUploader', () => ({
  FileUploader: () => <div />
}))
jest.mock('./AdminChargePanel', () => ({
  AdminChargePanel: () => <div />
}))
jest.mock('./Hubs/AdminHubTile', () => ({
  AdminHubTile: () => <div />
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

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
  theme,
  hubs: [hub, secondHub],
  shipments: [shipment],
  shipment,
  clients: [{}],
  hubHash: {},
  loading: false,
  adminDispatch: {
    getShipments: identity
  },
  dispatch: identity,
  setCurrentUrl: identity,
  tenant,
  history: {},
  match: { url: 'URL' },
  user
}

test('shallow render', () => {
  expect(shallow(<AdminShipments {...propsBase} />)).toMatchSnapshot()
})

test('shipments is falsy', () => {
  const props = {
    ...propsBase,
    shipments: null
  }
  expect(shallow(<AdminShipments {...props} />)).toMatchSnapshot()
})
