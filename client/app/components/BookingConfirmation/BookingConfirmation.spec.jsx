import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, shipmentData, identity, tenant } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
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
jest.mock('../Incoterm/Row', () => ({
  // eslint-disable-next-line react/prop-types
  IncotermRow: ({ children }) => <div>{children}</div>
}))

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
