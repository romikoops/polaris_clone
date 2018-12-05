import * as React from 'react'
import { mount } from 'enzyme'
import { identity, theme } from '../../../mocks'
import TruckingDistanceSetter from './TruckingDistanceSetter'

const propsBase = {
  theme,
  newCell: {},
  addNewCell: identity
}

test('shallow render', () => {
  expect(mount(<TruckingDistanceSetter {...propsBase} />)).toMatchSnapshot()
})
