import * as React from 'react'
import { shallow } from 'enzyme'

import ContainerInputs from './ContainerInputs'

const propsBase = {
  width: 10,
  length: 20,
  height: 30,
  payload_in_kg: 40,
  quantity: 50
}

test('shallow render', () => {
  expect(shallow(<ContainerInputs {...propsBase} />)).toMatchSnapshot()
})
