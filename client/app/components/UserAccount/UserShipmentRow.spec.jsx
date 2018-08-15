import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipment } from '../../mocks'

/**
 * ISSUE
 * `UserShipmentRow.switchIcon(schedule, gradientFontStyle)`
 * but `static switchIcon (sched) {`
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
  formattedPriceValue: () => 109,
  totalPrice: x => ({ currency: 'CNY' })
}))

jest.mock('../../constants', () => {
  const moment = input => ({
    format: () => input,
    diff: () => input
  })

  return { moment }
})
// eslint-disable-next-line import/first
import { UserShipmentRow } from './UserShipmentRow'

const editedShipment = {
  ...shipment,
  origin_hub_id: 'FOO',
  destination_hub_id: 'BAR',
  load_type: 'cargo_item',
  selected_offer: { cargo: {} },
  schedules_charges: {
    'FOO-BAR': {
      cargo: []
    }
  },
  schedule_set: [
    { hub_route_key: 'FOO-BAR' }
  ],
  total_price: {
    currency: 'EUR',
    value: 100
  }
}

const hubs = {
  FOO: { data: { name: 'FOO_NAME' } },
  BAR: { data: { name: 'BAR_NAME' } }
}

const propsBase = {
  theme,
  user: {},
  handleSelect: identity,
  handleAction: identity,
  hubs,
  shipment: editedShipment
}

test('shallow render', () => {
  expect(shallow(<UserShipmentRow {...propsBase} />)).toMatchSnapshot()
})

test('props.shipment.schedule_set.length < 1', () => {
  const shipmentValue = {
    ...editedShipment,
    schedule_set: []
  }
  const props = {
    ...propsBase,
    shipment: shipmentValue
  }
  expect(shallow(<UserShipmentRow {...props} />)).toMatchSnapshot()
})
