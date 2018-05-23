import * as React from 'react'
import { shallow } from 'enzyme'
// eslint-disable-next-line
import DetailMenu from './DetailMenu'

test('shallow render', () => {
  expect(shallow(<DetailMenu />)).toMatchSnapshot()
})

test('state.expand is false', () => {
  const wrapper = shallow(<DetailMenu />)
  wrapper.setState({ expand: false })

  expect(wrapper).toMatchSnapshot()
})
