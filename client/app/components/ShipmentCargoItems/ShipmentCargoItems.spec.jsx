import * as React from 'react'
import { get } from 'lodash'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('../TextHeading/TextHeading', () => {
  // eslint-disable-next-line react/prop-types
  const TextHeading = ({ children }) => <h2>{children}</h2>

  return {
    TextHeading
  }
})

jest.mock('../QuantityInput/QuantityInput', () => {
  const QuantityInput = props => <input {...props} />

  return {
    default: QuantityInput
  }
})

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line import/first
import ShipmentCargoItems from './ShipmentCargoItems'

const propsBase = {
  theme,
  deleteItem: identity,
  cargoItems: [{
    description: 'FOO',
    key: 5,
    dimension_x: 13,
    dimension_z: 13,
    quantity: 2,
    dimension_y: 24,
    dangerous_goods: false,
    stackable: false
  }],
  availableCargoItemTypes: [{
    description: 'BAR',
    key: 7,
    dimension_x: 5,
    dimension_y: 6
  }],
  addCargoItem: identity,
  handleDelta: identity,
  toggleModal: identity,
  nextStageAttempt: false,
  emails: {
    sales: {
      general: 'sales@demo.com',
      air: 'sales@demo.com',
      ocean: 'sales@demo.com',
      rail: 'sales@demo.com'
    },
    support: {
      general: 'support@demo.com',
      air: 'imc.air@demo.com',
      ocean: 'imc.sea@demo.com',
      rail: 'imc.rail@demo.com'
    }
  },
  scope: {
    modes_of_transport: {},
    dangerous_goods: false
  },
  maxDimensions: {
    air: { x: 44, y: 33, z: 22 },
    general: { x: 4, y: 3, z: 2 }
  }
}

const createShallow = propsInput => shallow(<ShipmentCargoItems {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
test('shallow rendering dynamic chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'dynamic'
    }
  }
  expect(createShallow(newPropsBase)).toMatchSnapshot()
})
test('shallow rendering weight chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'weight'
    }
  }
  expect(createShallow(newPropsBase)).toMatchSnapshot()
})
test('shallow rendering volume chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'volume'
    }
  }
  expect(createShallow(newPropsBase)).toMatchSnapshot()
})
test('shallow rendering both chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'both'
    }
  }
  expect(createShallow(newPropsBase)).toMatchSnapshot()
})
