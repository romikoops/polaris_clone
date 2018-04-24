import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipmentData, identity, tenant } from '../../mocks'

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

const cargoItemTypes = {}

const editedTenant = {
  ...tenant,
  scope: {
    terms: ['FOO_TERM', 'BAR_TERM']
  }
}

const propsBase = {
  theme,
  shipmentData: { ...shipmentData, cargoItemTypes },
  setStage: identity,
  tenant: editedTenant,
  shipmentDispatch: {
    toDashboard: identity
  }
}

test('shallow render', () => {
  expect(shallow(<BookingConfirmation {...propsBase} />)).toMatchSnapshot()
})
