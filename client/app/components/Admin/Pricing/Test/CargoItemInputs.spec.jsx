import * as React from 'react'
import { shallow } from 'enzyme'

import CargoItemInputs from './CargoItemInputs'

const propsBase = {
  width: 0,
  length: 0,
  height: 0,
  payload_in_kg: 0,
  quantity: 0,
  index: 0,
  handleChange: null
}

test('shallow render', () => {
  expect(shallow(<CargoItemInputs {...propsBase} />)).toMatchSnapshot()
})
