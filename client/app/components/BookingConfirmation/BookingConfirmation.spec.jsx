import * as React from 'react'
import { mount } from 'enzyme'

import {
  theme,
  shipmentData,
  identity,
  tenant
} from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('../Contact/Contact', () => {
  // eslint-disable-next-line react/prop-types
  const Contact = ({ children }) => <div>{children}</div>

  return Contact
})
jest.mock('../RouteHubBox/RouteHubBox', () => {
  // eslint-disable-next-line react/prop-types
  const RouteHubBox = ({ children }) => <div>{children}</div>

  return { RouteHubBox }
})
jest.mock('../Incoterm/Row', () => {
  // eslint-disable-next-line react/prop-types
  const IncotermRow = ({ children }) => <div>{children}</div>

  return { IncotermRow }
})

// eslint-disable-next-line
import { BookingConfirmation } from './BookingConfirmation'

const cargoItemTypes = {}

const edittedTenant = {
  ...tenant,
  scope: {
    terms: ['FOO_TERM', 'BAR_TERM']
  }
}

const propsBase = {
  theme,
  shipmentData: { ...shipmentData, cargoItemTypes },
  setStage: identity,
  tenant: edittedTenant,
  shipmentDispatch: {
    toDashboard: identity
  }
}

test('price element renders currency and price value', () => {
  const wrapper = mount(<BookingConfirmation {...propsBase} />)
  const priceElement = wrapper.find('h3.letter_3').last()

  const expectedValue = shipmentData.shipment.total_price.value
  const expectedCurrency = shipmentData.shipment.total_price.currency
  const expectedResult = `${expectedCurrency} ${expectedValue}.00 `

  expect(priceElement.text()).toBe(expectedResult)
})
