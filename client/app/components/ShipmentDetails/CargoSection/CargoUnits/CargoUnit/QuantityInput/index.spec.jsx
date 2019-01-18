import * as React from 'react'
import { shallow } from 'enzyme'
import QuantityInput from '.'
import { cargoItem, identity } from '../../../../mocks'

const propsBase = {
  cargoItem,
  i: 0,
  onChange: identity
}

test('with empty props', () => {
  expect(shallow(<QuantityInput />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<QuantityInput {...propsBase} />)).toMatchSnapshot()
})
