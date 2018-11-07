import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipmentData, tenant, user, match, address } from '../../mocks'

/**
 * ISSUE
 * static sumCargoFees is not used while it is declared
 */

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x,
  checkPreCarriage: x => x,
  switchIcon: x => x,
  totalPrice: () => ({ currency: 'BGN' }),
  formattedPriceValue: () => ({ currency: 'PHP' }),
  gradientGenerator: x => x,
  gradientBorderGenerator: x => x
}))
jest.mock('../GradientBorder', x => x)

// eslint-disable-next-line
import UserShipmentView from './UserShipmentView'

const propsBase = {
  theme,
  hubs: [],
  loading: false,
  shipmentData,
  user,
  userDispatch: {
    deleteDocument: identity
  },
  match,
  setNav: identity,
  setCurrentUrl: identity,
  tenant
}

jest.mock('../../constants', () => {
  const moment = () => ({
    format: () => 19,
    subtract: () => ({ format: () => 20 }),
    diff: () => 17
  })
  const documentTypes = x => x

  return { moment, documentTypes }
})

test('shallow render', () => {
  expect(shallow(<UserShipmentView {...propsBase} />)).toMatchSnapshot()
})

test('loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('hubs is false', () => {
  const props = {
    ...propsBase,
    hubs: false
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('shipmentData.documents is present', () => {
  const documents = [
    { id: 0, doc_type: 'foo' },
    { id: 1, doc_type: 'bar' }
  ]

  const editedShipmentData = {
    ...shipmentData,
    documents
  }
  const props = {
    ...propsBase,
    shipmentData: editedShipmentData
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('shipmentData.cargoItems is present', () => {
  const cargoItems = [
    { id: 0, cargo_item_type_id: 'foo' },
    { id: 1, cargo_item_type_id: 'bar' }
  ]
  const cargoItemTypes = { foo: 'FOO_CARGO_TYPE', bar: 'BAR_CARGO_TYPE' }

  const editedShipmentData = {
    ...shipmentData,
    cargoItems,
    cargoItemTypes
  }
  const props = {
    ...propsBase,
    shipmentData: editedShipmentData
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('shipmentData.contacts is present', () => {
  const contacts = [
    {
      type: 'notifyee',
      contact: {
        first_name: 'FOO_FIRST_NAME',
        last_name: 'FOO_LAST_NAME'
      }
    },
    {
      type: 'shipper',
      address,
      contact: {
        first_name: 'BAR_FIRST_NAME',
        last_name: 'BAR_LAST_NAME'
      }
    },
    {
      type: 'consignee',
      address,
      contact: {
        first_name: 'BAZ_FIRST_NAME',
        last_name: 'BAZ_LAST_NAME'
      }
    }
  ]
  const editedShipmentData = {
    ...shipmentData,
    contacts
  }
  const props = {
    ...propsBase,
    shipmentData: editedShipmentData
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})
