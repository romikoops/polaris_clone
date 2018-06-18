import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemGroupAggregated from './'

const group = {
  quantity: 'FOO_QUANTITY',
  chargeable_weight: 4,
  size_class: 'dry_goods',
  cargoType: {
    category: 'FOO_CATEGORY'
  },
  volume: 5,
  items: [{
    chargeable_weight: 80,
    dimension_x: 90,
    dimension_y: 100,
    dimension_z: 120,
    payload_in_kg: 56,
    tare_weight: 20,
    gross_weight: 76
  }]
}

const propsBase = {
  group
}

test('shallow render', () => {
  expect(shallow(<CargoItemGroupAggregated {...propsBase} />)).toMatchSnapshot()
})
