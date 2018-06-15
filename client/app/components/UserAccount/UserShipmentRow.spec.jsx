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
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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
  load_type: 'FOO_LOAD_TYPE',
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

test('props.shipment.hubs is {}', () => {
  const props = {
    ...propsBase,
    hubs: {}
  }
  expect(shallow(<UserShipmentRow {...props} />)).toMatchSnapshot()
})
