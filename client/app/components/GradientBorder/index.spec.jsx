import * as React from 'react'
import { shallow } from 'enzyme'
import GradientBorder from './'

const propsBase = {
  gradient: {},
  content: <div>FOO_CONTENT</div>,
  wrapperClassName: 'FOO_WRAPPER_CLASS_NAME',
  className: 'FOO_CLASS_NAME'
}

test('shallow render', () => {
  expect(shallow(<GradientBorder {...propsBase} />)).toMatchSnapshot()
})
