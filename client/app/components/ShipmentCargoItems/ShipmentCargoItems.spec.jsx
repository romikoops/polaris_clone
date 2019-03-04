import * as React from 'react'
import { shallow } from 'enzyme'
import {
  emails, cargoItems, theme, identity
} from '../../mocks'

import ShipmentCargoItems from './ShipmentCargoItems'

const propsBase = {
  theme,
  addCargoItem: identity,
  availableCargoItemTypes: [{
    description: 'BAR',
    dimension_x: 5,
    dimension_y: 6,
    key: 7
  }],
  cargoItems,
  deleteItem: identity,
  handleDelta: identity,
  nextStageAttempt: false,
  emails,
  scope: {
    modes_of_transport: {},
    dangerous_goods: false
  },
  maxDimensions: {
    air: { x: 44, y: 33, z: 22 },
    general: { x: 4, y: 3, z: 2 }
  }
}

test('shallow rendering', () => {
  expect(
    shallow(<ShipmentCargoItems {...propsBase} />)
  ).toMatchSnapshot()
})

test('shallow rendering dynamic chargeable value', () => {
  const props = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'dynamic'
    }
  }
  expect(
    shallow(<ShipmentCargoItems {...props} />)
  ).toMatchSnapshot()
})

test('shallow rendering weight chargeable value', () => {
  const props = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'weight'
    }
  }
  expect(
    shallow(<ShipmentCargoItems {...props} />)
  ).toMatchSnapshot()
})

test('shallow rendering volume chargeable value', () => {
  const props = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'volume'
    }
  }
  expect(
    shallow(<ShipmentCargoItems {...props} />)
  ).toMatchSnapshot()
})

test('shallow rendering both chargeable value', () => {
  const props = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'both'
    }
  }
  expect(
    shallow(<ShipmentCargoItems {...props} />)
  ).toMatchSnapshot()
})
