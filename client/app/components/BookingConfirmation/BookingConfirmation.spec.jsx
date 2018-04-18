import * as React from 'react'
import { mount, shallow } from 'enzyme'
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
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('../Contact/Contact', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../RouteHubBox/RouteHubBox', () => ({
  // eslint-disable-next-line react/prop-types
  RouteHubBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <h2>{children}</h2>
}))
jest.mock('../Incoterm/Row', () => ({
  // eslint-disable-next-line react/prop-types
  IncotermRow: ({ children }) => <div>{children}</div>
}))

// import { Checkbox } from '../Checkbox/Checkbox'
// import { CargoItemGroup } from '../Cargo/Item/Group'
// import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
// import { CargoContainerGroup } from '../Cargo/Container/Group'
// import DocumentsForm from '../Documents/Form'
// import Contact from '../Contact/Contact'
// import { IncotermRow } from '../Incoterm/Row'

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

test('price element renders currency and price value', () => {
  const wrapper = mount(<BookingConfirmation {...propsBase} />)
  const priceElement = wrapper.find('h3.letter_3').last()

  const { value, currency } = shipmentData.shipment.total_price
  const expectedResult = `${currency} ${value}.00 `

  expect(priceElement.text()).toBe(expectedResult)
})

test('shallow render', () => {
  expect(shallow(<BookingConfirmation {...propsBase} />)).toMatchSnapshot()
})
