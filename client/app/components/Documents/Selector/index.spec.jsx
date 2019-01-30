import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

import DocumentsSelector from '.'

const propsBase = {
  dispatchFn: identity,
  options: [],
  theme,
  tooltip: 'TOOLTIP',
  type: 'TYPE',
  uploadFn: identity,
  url: 'URL'
}

test('shallow render', () => {
  expect(shallow(<DocumentsSelector {...propsBase} />)).toMatchSnapshot()
})

test('state.selected is true', () => {
  const wrapper = shallow(<DocumentsSelector {...propsBase} />)

  wrapper.setState({ selected: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.error is true', () => {
  const wrapper = shallow(<DocumentsSelector {...propsBase} />)

  wrapper.setState({ error: true })
  expect(wrapper).toMatchSnapshot()
})

test('selected || !options is false', () => {
  const props = {
    ...propsBase,
    options: []
  }
  const wrapper = shallow(<DocumentsSelector {...props} />)

  wrapper.setState({ selected: false })
  expect(wrapper).toMatchSnapshot()
})
