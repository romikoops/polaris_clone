import * as React from 'react'
import { shallow } from 'enzyme'
import { shipment, identity, hub, theme } from '../../mocks'
import { ShipmentOverviewCard } from './ShipmentOverviewCard'

const propsBase = {
  admin: false,
  shipments: [shipment],
  dispatches: { foo: identity },
  theme,
  hubs: { foo: hub }
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentOverviewCard {...propsBase} />)).toMatchSnapshot()
})

test('admin is true', () => {
  const props = {
    ...propsBase,
    admin: true
  }
  expect(shallow(<ShipmentOverviewCard {...props} />)).toMatchSnapshot()
})
