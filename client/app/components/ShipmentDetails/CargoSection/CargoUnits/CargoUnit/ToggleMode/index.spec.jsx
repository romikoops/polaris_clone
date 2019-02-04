import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemToggleMode from '.'

const propsBase = {
  checked: false,
  disabed: false,
  onToggleAggregated: null
}

test('with empty props', () => {
  expect(shallow(<CargoItemToggleMode />)).toMatchSnapshot()
})

test('renders correctly', () => {
  expect(shallow(<CargoItemToggleMode {...propsBase} />)).toMatchSnapshot()
})

test('when checked', () => {
  const props = {
    ...propsBase,
    checked: true
  }
  expect(shallow(<CargoItemToggleMode {...props} />)).toMatchSnapshot()
})

test('when disabled', () => {
  const props = {
    ...propsBase,
    disabled: true
  }
  expect(shallow(<CargoItemToggleMode {...props} />)).toMatchSnapshot()
})
