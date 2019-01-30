import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mock'

import AdminShipmentsGroup from '.'

const propsBase = {
  theme,
  hubs: [{}],
  shipments: { TARGET: [] },
  clients: [{}],
  hubHash: {},
  adminDispatch: {},
  title: '',
  target: 'TARGET'
}

test('shallow render', () => {
  expect(shallow(<AdminShipmentsGroup {...propsBase} />)).toMatchSnapshot()
})

test('shipments is falsy', () => {
  const props = {
    ...propsBase,
    shipments: {}
  }
  expect(shallow(<AdminShipmentsGroup {...props} />)).toMatchSnapshot()
})

test('mergedShipments is truthy', () => {
  const props = {
    ...propsBase,
    shipments: {
      TARGET: [{
        schedule_set: [{ hub_route_key: 'FOO-BAR-BAZ' }]
      }]
    }
  }
  expect(shallow(<AdminShipmentsGroup {...props} />)).toMatchSnapshot()
})
