import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, theme, change } from '../../mocks'
import ShipmentQuotationCard from './ShipmentQuotationCard'

const propsBase = {
  shipment,
  theme
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentQuotationCard {...propsBase} />)).toMatchSnapshot()
})

test('shipment.trucking.has_pre_carriage is true', () => {
  const props = change(
    propsBase,
    'shipment.trucking.has_pre_carriage',
    true
  )
  expect(shallow(<ShipmentQuotationCard {...props} />)).toMatchSnapshot()
})

test('shipment.trucking.has_on_carriage is true', () => {
  const props = change(
    propsBase,
    'shipment.trucking.has_on_carriage',
    true
  )
  expect(shallow(<ShipmentQuotationCard {...props} />)).toMatchSnapshot()
})
