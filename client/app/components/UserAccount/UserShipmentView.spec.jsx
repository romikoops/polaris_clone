import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  identity,
  match,
  shipmentData,
  tenant,
  theme,
  change,
  user
} from '../../mocks'

import UserShipmentView from './UserShipmentView'

const propsBase = {
  hubs: [],
  loading: false,
  match,
  setCurrentUrl: identity,
  setNav: identity,
  shipmentData,
  tenant,
  theme,
  user,
  userDispatch: {
    deleteDocument: identity,
    getShipment: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserShipmentView {...propsBase} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('shipmentData.cargoItems is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.cargoItems',
    []
  )
  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})
