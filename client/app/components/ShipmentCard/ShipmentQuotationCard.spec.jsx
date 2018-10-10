import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, theme, shipmentInShipmentData } from '../../mocks'
import ShipmentQuotationCard from './ShipmentQuotationCard'

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
    trucking: {
      has_pre_carriage: false,
      has_on_carriage: false
    },
    booking_placed_at: '10-10-2018'
  },
  theme
}
test('shallow rendering', () => {
  expect(shallow(<ShipmentQuotationCard {...propsBase} />)).toMatchSnapshot()
})

const preCarriageProps = {
  shipmentInShipmentData,
  shipment: {
    ...shipment,
    trucking: {
      has_pre_carriage: true,
      has_on_carriage: false
    },
    booking_placed_at: '10-10-2018'
  },
  theme
}

test('has precarriage', () => {
  expect(shallow(<ShipmentQuotationCard {...preCarriageProps} />)).toMatchSnapshot()
})

const onCarriageProps = {
  shipmentInShipmentData,
  shipment: {
    ...shipment,
    trucking: {
      has_pre_carriage: false,
      has_on_carriage: true
    },
    booking_placed_at: '10-10-2018'
  },
  theme
}

test('has oncarriage', () => {
  expect(shallow(<ShipmentQuotationCard {...onCarriageProps} />)).toMatchSnapshot()
})