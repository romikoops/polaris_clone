import * as React from 'react'
import { shallow } from 'enzyme'
import {
  shipment, identity, hub, theme
} from '../../mocks/index'
import ShipmentOverviewCard from './ShipmentOverviewCard'

const propsBase = {
  admin: false,
  noTitle: false,
  confirmShipmentData: {
    confirmedShipment: true,
    shipmentId: shipment.id
  },
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

test('noTitle is true', () => {
  const props = {
    ...propsBase,
    noTitle: true
  }
  expect(shallow(<ShipmentOverviewCard {...props} />)).toMatchSnapshot()
})

test('confirmShipmentData is falsy', () => {
  const props = {
    ...propsBase,
    confirmShipmentData: {}
  }
  expect(shallow(<ShipmentOverviewCard {...props} />)).toMatchSnapshot()
})

test('shipment.status is quoted', () => {
  const newShipment = {
    ...shipment,
    status: 'quoted'
  }
  const props = {
    ...propsBase,
    shipments: [newShipment]
  }
  expect(shallow(<ShipmentOverviewCard {...props} />)).toMatchSnapshot()
})
