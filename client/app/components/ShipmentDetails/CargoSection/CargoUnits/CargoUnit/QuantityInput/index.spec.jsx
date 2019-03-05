import * as React from 'react'
import { shallow } from 'enzyme'
import QuantityInput from '.'
import { cargoItem } from '../../../../mocks'

const propsBase = {
  cargoItem,
  i: 0,
  onChange: null
}

test('with empty props', () => {
  expect(shallow(<QuantityInput />)).toMatchSnapshot()
})

test('renders correctly', () => {
  expect(shallow(<QuantityInput {...propsBase} />)).toMatchSnapshot()
})
