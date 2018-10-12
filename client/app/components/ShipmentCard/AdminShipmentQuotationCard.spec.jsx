import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, theme, shipmentInShipmentData } from '../../mocks'
import AdminShipmentQuotationCard from './AdminShipmentQuotationCard'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  shipmentInShipmentData,
  shipment: {
    ...shipment,
    booking_placed_at: '10-10-2018'
  },
  theme
}
test('shallow rendering', () => {
  expect(shallow(<AdminShipmentQuotationCard {...propsBase} />)).toMatchSnapshot()
})
