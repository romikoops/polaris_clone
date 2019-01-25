import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mocks'
import {
  gradientTextGenerator,
  numberSpacing,
  singleItemChargeableObject
} from '../../../../helpers'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import CargoItemGroup from './'

const group = {
  quantity: 'FOO_QUANTITY',
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
  theme,
  group,
  scope: {},
  viewHSCodes: false,
  hsCodes: ['FOO_HSCODE', 'BAR_HSCODE']
}

test('shallow render', () => {
  expect(shallow(<CargoItemGroup {...propsBase} />)).toMatchSnapshot()
})

test('props.viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('state.unitView is true', () => {
  const wrapper = shallow(<CargoItemGroup {...propsBase} />)
  wrapper.setState({ unitView: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.viewer is true', () => {
  const wrapper = shallow(<CargoItemGroup {...propsBase} />)
  wrapper.setState({ viewer: true })

  expect(wrapper).toMatchSnapshot()
})

test('shallow rendering dynamic chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'dynamic'
    }
  }
  expect(shallow(<CargoItemGroup {...newPropsBase} />)).toMatchSnapshot()
})
test('shallow rendering weight chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'weight'
    }
  }
  expect(shallow(<CargoItemGroup {...newPropsBase} />)).toMatchSnapshot()
})
test('shallow rendering volume chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'volume'
    }
  }
  expect(shallow(<CargoItemGroup {...newPropsBase} />)).toMatchSnapshot()
})
test('shallow rendering both chargeable value', () => {
  const newPropsBase = {
    ...propsBase,
    scope: {
      ...propsBase.scope,
      chargeable_weight_view: 'both'
    }
  }
  expect(shallow(<CargoItemGroup {...newPropsBase} />)).toMatchSnapshot()
})
