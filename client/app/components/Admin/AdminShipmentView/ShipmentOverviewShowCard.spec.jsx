import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipment, identity } from '../../../mock'
import ShipmentOverviewShowCard from './ShipmentOverviewShowCard'

function empty (x) {
  return <div>{x}</div>
}

const propsBase = {
  theme,
  estimatedTime: empty('estimatedTime'),
  carriage: empty('carriage'),
  noCarriage: empty('noCarriage'),
  hub: { name: 'HUB' },
  background: {},
  shipment,
  editTime: false,
  text: 'ETD',
  handleSaveTime: identity,
  toggleEditTime: identity,
  isAdmin: false
}

test('shallow render', () => {
  expect(shallow(<ShipmentOverviewShowCard {...propsBase} />)).toMatchSnapshot()
})

test('isAdmin is true', () => {
  const props = {
    ...propsBase,
    isAdmin: true
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('editTime is true', () => {
  const props = {
    ...propsBase,
    editTime: true,
    isAdmin: true
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('estimatedTime is falsy', () => {
  const props = {
    ...propsBase,
    estimatedTime: null
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('shipment has pickup_address', () => {
  const pickUpAddress = {
    street: 'PICKUP_STREET',
    street_number: 'PICKUP_STREET_NUMBER',
    city: 'PICKUP_CITY',
    country: { name: 'PICKUP_COUNTRY' }
  }
  const props = {
    ...propsBase,
    shipment: {
      ...shipment,
      pickup_address: pickUpAddress
    }
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('shipment has has_pre_carriage', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipment,
      has_pre_carriage: true
    }
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('shipment has has_on_carriage', () => {
  const props = {
    ...propsBase,
    text: '',
    shipment: {
      ...shipment,
      has_on_carriage: true
    }
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('text is not ETD', () => {
  const props = {
    ...propsBase,
    text: ''
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})

test('shipment has delivery_address', () => {
  const deliveryAddress = {
    street: 'DELIVERY_STREET',
    street_number: 'DELIVERY_STREET_NUMBER',
    city: 'DELIVERY_CITY',
    country: { name: 'DELIVERY_COUNTRY' }
  }
  const props = {
    ...propsBase,
    text: '',
    shipment: {
      ...shipment,
      delivery_address: deliveryAddress
    }
  }
  expect(shallow(<ShipmentOverviewShowCard {...props} />)).toMatchSnapshot()
})
