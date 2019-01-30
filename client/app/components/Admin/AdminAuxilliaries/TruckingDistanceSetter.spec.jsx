import * as React from 'react'
import { mount } from 'enzyme'
import { identity, theme } from '../../../mock'
import TruckingDistanceSetter from './TruckingDistanceSetter'

const propsBase = {
  theme,
  newCell: {},
  addNewCell: identity
}

test.skip('shallow render', () => {
  expect(mount(<TruckingDistanceSetter {...propsBase} />)).toMatchSnapshot()
})
