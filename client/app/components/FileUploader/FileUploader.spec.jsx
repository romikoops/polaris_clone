import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

import FileUploader from './FileUploader'

const propsBase = {
  dispatchFn: identity,
  square: false,
  theme,
  tooltip: 'TOOLTIP',
  type: 'TYPE',
  uploadFn: identity,
  url: 'URL'
}

test('shallow render', () => {
  expect(shallow(<FileUploader {...propsBase} />)).toMatchSnapshot()
})

test('square is true', () => {
  const props = {
    ...propsBase,
    square: true
  }
  expect(shallow(<FileUploader {...props} />)).toMatchSnapshot()
})

test('state.error is true', () => {
  const wrapper = shallow(<FileUploader {...propsBase} />)
  wrapper.setState({ error: true })
  expect(wrapper).toMatchSnapshot()
})
