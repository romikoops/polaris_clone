import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks/index'

import Modal from './Modal'

const propsBase = {
  component: ({ children }) => <div>{children}</div>,
  parentToggle: identity,
  minHeight: '55px',
  showExit: false,
  horizontalPadding: '33px',
  verticalPadding: '22px'
}

test('shallow render', () => {
  expect(shallow(<Modal {...propsBase} />)).toMatchSnapshot()
})

test('showExit is true', () => {
  const props = {
    ...propsBase,
    showExit: true
  }
  expect(shallow(<Modal {...props} />)).toMatchSnapshot()
})

test('minHeight is falsy', () => {
  const props = {
    ...propsBase,
    minHeight: null
  }
  expect(shallow(<Modal {...props} />)).toMatchSnapshot()
})

test('state.hidden is true', () => {
  const wrapper = shallow(<Modal {...propsBase} />)
  wrapper.setState({ hidden: true })
  expect(wrapper).toMatchSnapshot()
})
