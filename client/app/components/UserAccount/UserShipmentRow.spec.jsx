import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipment } from '../../mocks'

import { UserShipmentRow } from './UserShipmentRow'

const editedShipment = {
  ...shipment,
  origin_hub_id: 'FOO',
  destination_hub_id: 'BAR',
  schedules_charges: {
    'FOO-BAR': {
      cargo: []
    }
  },
  schedule_set: [
    { hub_route_key: 'FOO-BAR' }
  ]
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
