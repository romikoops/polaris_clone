import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemToggleMode from '.'
import { identity, t } from '../../../../mocks'

const propsBase = {
  checked: false,
  disabed: false,
  onToggleAggregated: identity,
  t
}

test('with empty props', () => {
  expect(() => shallow(<CargoItemToggleMode />)).toThrow()
})

test('happy path', () => {
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
