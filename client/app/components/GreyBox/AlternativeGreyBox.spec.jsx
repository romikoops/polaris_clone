import * as React from 'react'
import { shallow } from 'enzyme'
import AlternativeGreyBox from './AlternativeGreyBox'

const propsBase = {
  title: 'FOO_TITLE',
  content: <div>FOO_CONTENT</div>,
  wrapperClassName: 'FOO_WRAPPER_CLASS_NAME',
  contentClassName: 'FOO_CONTENT_CLASS_NAME'
}

test('shallow render', () => {
  expect(shallow(<AlternativeGreyBox {...propsBase} />)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: ''
  }
  expect(shallow(<AlternativeGreyBox {...props} />)).toMatchSnapshot()
})
