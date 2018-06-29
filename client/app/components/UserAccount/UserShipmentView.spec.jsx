import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity, shipmentData, tenant, user, match, location } from '../../mocks'

/**
 * ISSUE
 * static sumCargoFees is not used while it is declared
 */

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('../../constants', () => {
  const moment = () => ({
    format: () => 19,
    diff: () => 17
  })
  const documentTypes = x => x

  return { moment, documentTypes }
})
jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x,
  switchIcon: x => x,
  gradientGenerator: x => x,
  gradientBorderGenerator: x => x
}))

// eslint-disable-next-line import/first
import UserShipmentView from './UserShipmentView'

const createWrapper = propsInput => mount(<UserShipmentView {...propsInput} />)

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
  tenant
}

test('shallow render', () => {
  expect(shallow(<UserShipmentView {...propsBase} />)).toMatchSnapshot()
})

test('props.loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test.skip('props.setNav is called', () => {
  const props = {
    ...propsBase,
    setNav: jest.fn()
  }

  createWrapper(props)
  expect(props.setNav).toHaveBeenCalled()
})

test.skip('props.hubs is false', () => {
  const props = {
    ...propsBase,
    hubs: false
  }

  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('props.shipmentData.documents is present', () => {
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

test('props.shipmentData.cargoItems is present', () => {
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

test('props.shipmentData.contacts is present', () => {
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
      location,
      contact: {
        first_name: 'BAR_FIRST_NAME',
        last_name: 'BAR_LAST_NAME'
      }
    },
    {
      type: 'consignee',
      location,
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
