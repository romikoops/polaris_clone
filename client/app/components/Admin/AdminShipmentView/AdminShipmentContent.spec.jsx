import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, shipmentData, shipment, change, tenant
} from '../../../mocks'
import { AdminShipmentContent } from './AdminShipmentContent'

jest.mock('../../../helpers', () => ({
  numberSpacing: x => x,
  totalPrice: x => x,
  cargoPlurals: x => x,
  capitalize: x => x
}))

const feeHashBase = {
  trucking_on: {
    total: {
      currency: 'ON_CURRENCY'
    }
  },
  trucking_pre: {
    total: {
      currency: 'PRE_CURRENCY'
    }
  },
  cargo: {
    total: {
      currency: 'FEE_HASH_CURRENCY'
    }
  }
}
const propsBase = {
  theme,
  adminDispatch: {},
  gradientBorderStyle: {},
  gradientStyle: {},
  shipmentData,
  estimatedTimes: {},
  pickupDate: 'PICKUP_DATE',
  deliveryDate: 'DELIVERY_DATE',
  originDropOffDate: 'originDropOffDate',
  destinationCollectionDate: 'destinationCollectionDate',
  toggleEditServicePrice: identity,
  uploadClientDocument: identity,
  saveNewEditedPrice: identity,
  remarkDispatch: {
    getRemarks: jest.fn()
  },
  scope: tenant.scope,
  shipment,
  background: {},
  selectedStyle: {},
  deselectedStyle: {},
  feeHash: feeHashBase,
  cargoCount: 0,
  cargoView: 'cargoView',
  switchIcon: identity,
  dnrEditKeys: [],
  showEditTime: identity,
  saveNewTime: identity,
  toggleEditTime: identity,
  showEditServicePrice: identity,
  newPrices: {
    trucking_pre: { currency: 'NEW_PRICES_TRUCKING_PRE_CURRENCY' },
    cargo: { currency: 'NEW_PRICES_CURRENCY' }
  }
}

test('shallow render', () => {
  expect(shallow(<AdminShipmentContent {...propsBase} />)).toMatchSnapshot()
})

test('shipment.selected_offer.trucking_pre is true', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment',
    { selected_offer: { trucking_pre: true } }
  )
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('feeHash.trucking_pre is falsy', () => {
  const feeHash = change(
    feeHashBase,
    'trucking_pre',
    null
  )
  const props = {
    ...propsBase,
    feeHash
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('shipment.has_on_carriage is true', () => {
  const withOnCarriage = change(
    shipmentData,
    'shipment.has_on_carriage',
    true
  )
  const props = {
    ...propsBase,
    shipmentData: withOnCarriage
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('shipment.has_pre_carriage is true', () => {
  const withPreCarriage = change(
    shipmentData,
    'shipment.has_pre_carriage',
    true
  )
  const props = {
    ...propsBase,
    shipmentData: withPreCarriage
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('loadType === cargo_item && cargoCount > 1', () => {
  const withCargoItem = change(
    shipmentData,
    'shipment.load_type',
    'cargo_item'
  )
  const feeHash = change(
    feeHashBase,
    'cargo',
    { bar: 'BAR' }
  )
  const props = {
    ...propsBase,
    feeHash,
    shipmentData: withCargoItem
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('loadType === cargo_item && cargoCount === 1', () => {
  const withCargoItem = change(
    shipmentData,
    'shipment.load_type',
    'cargo_item'
  )
  const props = {
    ...propsBase,
    shipmentData: withCargoItem
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('loadType === container && cargoCount === 1', () => {
  const withContainer = change(
    shipmentData,
    'shipment.load_type',
    'container'
  )
  const props = {
    ...propsBase,
    shipmentData: withContainer
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})

test('loadType === container && cargoCount > 1', () => {
  const withContainer = change(
    shipmentData,
    'shipment.load_type',
    'container'
  )
  const feeHash = change(
    feeHashBase,
    'cargo',
    { bar: 'BAR' }
  )
  const props = {
    ...propsBase,
    feeHash,
    shipmentData: withContainer
  }
  expect(shallow(<AdminShipmentContent {...props} />)).toMatchSnapshot()
})
