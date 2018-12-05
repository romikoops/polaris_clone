import * as React from 'react'
import { mount } from 'enzyme'
import { identity, theme } from '../../../mocks'
import TruckingFeeSetter from './TruckingFeeSetter'

const propsBase = {
  theme,
  newCell: {},
  addNewCell: identity
}

test('shallow render', () => {
  expect(mount(<TruckingFeeSetter {...propsBase} />)).toMatchSnapshot()
})

test('state.globalFees is truthy', () => {
  const wrapper = mount(<TruckingFeeSetter {...propsBase} />)
  wrapper.setState({
    globalFees: {
      base_rate: {
        rate_basis: 'RATE_BASIS',
        currency: 'CURRENCY'
      }
    }
  })
  expect(wrapper).toMatchSnapshot()
})

test('state.selectOptions is falsy', () => {
  const wrapper = mount(<TruckingFeeSetter {...propsBase} />)
  wrapper.setState({
    selectOptions: null
  })
  expect(wrapper).toMatchSnapshot()
})
