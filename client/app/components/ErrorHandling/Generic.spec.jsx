import * as React from 'react'
import { shallow } from 'enzyme'
import GenericError from './Generic'
import { theme } from '../../mocks/index'

const propsBase = {
  theme,
  children: {}
}

test('shallow render', () => {
  expect(shallow(<GenericError {...propsBase} />)).toMatchSnapshot()
})

test('state.hasError is true', () => {
  const wrapper = shallow(<GenericError {...propsBase} />)
  wrapper.setState({ hasError: true })
  expect(wrapper).toMatchSnapshot()
})
