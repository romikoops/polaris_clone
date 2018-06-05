import * as React from 'react'
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
// eslint-disable-next-line import/first
import { ShipmentCargoItems } from './ShipmentCargoItems'

const propsBase = {
  theme,
  deleteItem: identity,
  cargoItems: [{
    description: 'FOO',
    key: 5,
    dimension_x: 13,
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
  scope: {
    modes_of_transport: {},
    dangerous_goods: false
  },
  maxDimensions: { x: 44, y: 33, z: 22 }
}

const createShallow = propsInput => shallow(<ShipmentCargoItems {...propsInput} />)

test.skip('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
