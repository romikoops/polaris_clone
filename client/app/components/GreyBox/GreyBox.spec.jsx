import * as React from 'react'
import { shallow } from 'enzyme'
import GreyBox from './GreyBox'

const propsBase = {
  title: 'FOO_TITLE',
  content: <div>FOO_CONTENT</div>,
  wrapperClassName: 'FOO_WRAPPER_CLASS_NAME',
  contentClassName: 'FOO_CONTENT_CLASS_NAME'
}

test('shallow render', () => {
  expect(shallow(<GreyBox {...propsBase} />)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: ''
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})
