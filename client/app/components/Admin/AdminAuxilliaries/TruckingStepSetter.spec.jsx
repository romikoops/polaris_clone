import * as React from 'react'
import { mount } from 'enzyme'
import { identity, theme } from '../../../mocks'
import TruckingStepSetter from './TruckingStepSetter'

const propsBase = {
  theme,
  saveSteps: identity
}

test('shallow render', () => {
  expect(mount(<TruckingStepSetter {...propsBase} />)).toMatchSnapshot()
})

test('state.step2 is true', () => {
  const wrapper = mount(<TruckingStepSetter {...propsBase} />)
  wrapper.setState({ step2: true })
  expect(wrapper).toMatchSnapshot()
})
