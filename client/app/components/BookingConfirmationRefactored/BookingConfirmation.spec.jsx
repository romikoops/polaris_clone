import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, editedShipmentData, identity, tenant } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('../../constants', () => {
  const format = () => 19

  const moment = () => ({
    format
  })
  const shipmentStatii = {
    booking_process_started: 'Booking Process Started',
    finished: 'Finished',
    open: 'Open',
    requested: 'Requested'
  }
  const documentTypes = {
    packing_sheet: 'Packing Sheet',
    commercial_invoice: 'Commercial Invoice',
    customs_declaration: 'Customs Declaration',
    customs_value_declaration: 'Customs Value Declaration',
    eori: 'EORI',
    certificate_of_origin: 'Certificate Of Origin',
    dangerous_goods: 'Dangerous Goods',
    bill_of_lading: 'Bill of Lading',
    invoice: 'Invoice',
    miscellaneous: 'Miscellaneous'
  }

  return { moment, shipmentStatii, documentTypes }
})
// eslint-disable-next-line
import { BookingConfirmation } from './BookingConfirmation'

const cargoItemTypes = { foo: 'FOO_TYPE', bar: 'BAR_TYPE' }

const editedTenant = {
  ...tenant,
  scope: {
    terms: ['FOO_TERM', 'BAR_TERM']
  }
}

const fooContainer = {
  customs_text: 'FOO_TEXT',
  hs_codes: [],
  id: 1,
  size_class: 'FOO_SIZE_CLASS',
  quantity: 5,
  gross_weight: 130,
  tare_weight: 50,
  payload_in_kg: 200
}

const barContainer = {
  customs_text: 'BAR_TEXT',
  hs_codes: [],
  id: 2,
  size_class: 'BAR_SIZE_CLASS',
  quantity: 7,
  gross_weight: 10,
  tare_weight: 7,
  payload_in_kg: 4
}

const containers = [fooContainer, barContainer, fooContainer]

const fooCargoItem = {
  dimension_x: 10,
  dimension_y: 60,
  dimension_z: 40,
  hs_codes: [],
  hs_text: 'FOO_HS_TEXT',
  id: 1,
  payload_in_kg: 200,
  chargeable_weight: 250,
  quantity: 5,
  cargo_item_type_id: 'foo',
  size_class: 'FOO_SIZE_CLASS'
}

const barCargoItem = {
  dimension_x: 100,
  dimension_y: 50,
  dimension_z: 70,
  hs_codes: [],
  hs_text: 'BAR_HS_TEXT',
  id: 2,
  payload_in_kg: 100,
  chargeable_weight: 150,
  quantity: 7,
  cargo_item_type_id: 'bar',
  size_class: 'BAR_SIZE_CLASS'
}

const cargoItems = [fooCargoItem, barCargoItem, fooCargoItem]

const propsBase = {
  theme,
  shipmentData: { ...editedShipmentData, cargoItemTypes },
  setStage: identity,
  tenant: editedTenant,
  shipmentDispatch: {
    toDashboard: identity
  }
}

test('shallow render', () => {
  expect(shallow(<BookingConfirmation {...propsBase} />)).toMatchSnapshot()
})

test('with containers', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...editedShipmentData,
      cargoItemTypes,
      containers
    }
  }
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})

test('with cargo items', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...editedShipmentData,
      cargoItemTypes,
      cargoItems
    }
  }
  expect(shallow(<BookingConfirmation {...props} />)).toMatchSnapshot()
})
