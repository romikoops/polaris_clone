import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  scope,
  cargoItemGroup,
  shipment,
  theme,
  turnFalsy
} from '../../../../mocks/index'

import CargoItemGroup from '.'

const propsBase = {
  theme,
  group: cargoItemGroup,
  scope,
  shipment,
  viewHSCodes: false,
  hsCodes: ['FOO_HSCODE', 'BAR_HSCODE']
}

test('shallow render', () => {
  expect(shallow(<CargoItemGroup {...propsBase} />)).toMatchSnapshot()
})

test('viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('shipment.load_type is cargo_item', () => {
  const props = change(
    propsBase,
    'shipment.load_type',
    'cargo_item'
  )
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('group.size_class is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'group.size_class'
  )
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('group.cargoType is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'group.cargoType'
  )
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})

test('state.unitView is true', () => {
  const wrapper = shallow(<CargoItemGroup {...propsBase} />)
  wrapper.setState({ unitView: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.collapsed is true', () => {
  const wrapper = shallow(<CargoItemGroup {...propsBase} />)
  wrapper.setState({ collapsed: true })

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
