import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mocks'

import CargoContainerGroup from '.'

const group = {
  quantity: 'FOO_QUANTITY',
  size_class: 'dry_goods',
  items: [{
    payload_in_kg: 56,
    tare_weight: 20,
    gross_weight: 76
  }]
}

const propsBase = {
  theme,
  group,
  viewHSCodes: false,
  hsCodes: ['FOO_HSCODE', 'BAR_HSCODE']
}

test('shallow render', () => {
  expect(shallow(<CargoContainerGroup {...propsBase} />)).toMatchSnapshot()
})

test('props.viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoContainerGroup {...props} />)).toMatchSnapshot()
})

test('state.unitView is true', () => {
  const wrapper = shallow(<CargoContainerGroup {...propsBase} />)
  wrapper.setState({ unitView: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.viewer is true', () => {
  const wrapper = shallow(<CargoContainerGroup {...propsBase} />)
  wrapper.setState({ viewer: true })

  expect(wrapper).toMatchSnapshot()
})
