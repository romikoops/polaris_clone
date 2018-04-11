import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipment } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
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
