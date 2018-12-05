import * as React from 'react'
import { shallow } from 'enzyme'

import ContainerInputs from './ContainerInputs'

const propsBase = {
  dimension_x: 10,
  dimension_y: 20,
  dimension_z: 30,
  payload_in_kg: 40,
  quantity: 50
}

test('shallow render', () => {
  expect(shallow(<ContainerInputs {...propsBase} />)).toMatchSnapshot()
})
