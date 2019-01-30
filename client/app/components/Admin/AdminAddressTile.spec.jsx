import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, address } from '../../mock'

import AdminAddressTile from './AdminAddressTile'

const propsBase = {
  theme,
  saveEdit: identity,
  deleteAddress: identity,
  address,
  showDelete: true
}

test('shallow render', () => {
  expect(shallow(<AdminAddressTile {...propsBase} />)).toMatchSnapshot()
})

test('showDelete is false', () => {
  const props = {
    ...propsBase,
    showDelete: false
  }
  expect(shallow(<AdminAddressTile {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminAddressTile {...props} />)).toMatchSnapshot()
})

test('address is falsy', () => {
  const props = {
    ...propsBase,
    address: null
  }
  expect(shallow(<AdminAddressTile {...props} />)).toMatchSnapshot()
})

test('state.showEdit is true', () => {
  const wrapper = shallow(<AdminAddressTile {...propsBase} />)
  wrapper.setState({ showEdit: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.editor is truthy', () => {
  const wrapper = shallow(<AdminAddressTile {...propsBase} />)
  wrapper.setState({ editor: address, showEdit: true })

  expect(wrapper).toMatchSnapshot()
})
