import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, documents } from '../../../mocks'

import DocumentsMultiForm from '.'

const propsBase = {
  deleteFn: identity,
  dispatchFn: identity,
  documents,
  isRequired: false,
  text: 'TEXT',
  theme,
  tooltip: 'TOOLTIP',
  type: 'TYPE',
  uploadFn: identity,
  url: 'URL'
}

test('shallow render', () => {
  expect(shallow(<DocumentsMultiForm {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<DocumentsMultiForm {...props} />)).toMatchSnapshot()
})

test('documents is falsy', () => {
  const props = {
    ...propsBase,
    documents: null
  }
  expect(shallow(<DocumentsMultiForm {...props} />)).toMatchSnapshot()
})

test('documents contains empty object', () => {
  const props = {
    ...propsBase,
    documents: [{}]
  }
  expect(shallow(<DocumentsMultiForm {...props} />)).toMatchSnapshot()
})

test('state.error is true', () => {
  const wrapper = shallow(<DocumentsMultiForm {...propsBase} />)
  wrapper.setState({ error: true })
  expect(wrapper).toMatchSnapshot()
})
