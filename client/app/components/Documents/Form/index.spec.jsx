import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, firstDocument } from '../../../mocks/index'

import DocumentsForm from '.'

const propsBase = {
  url: 'URL',
  type: 'TYPE',
  theme,
  dispatchFn: identity,
  uploadFn: identity,
  tooltip: 'TOOLTIP',
  text: 'TEXT',
  doc: firstDocument,
  isRequired: false,
  deleteFn: identity,
  displayOnly: false,
  multiple: false,
  viewer: false
}

test('shallow render', () => {
  expect(shallow(<DocumentsForm {...propsBase} />)).toMatchSnapshot()
})

test('displayOnly is true', () => {
  const props = {
    ...propsBase,
    displayOnly: true
  }
  expect(shallow(<DocumentsForm {...props} />)).toMatchSnapshot()
})

test('multiple is true', () => {
  const props = {
    ...propsBase,
    multiple: true
  }
  expect(shallow(<DocumentsForm {...props} />)).toMatchSnapshot()
})

test('viewer is true', () => {
  const props = {
    ...propsBase,
    viewer: true
  }
  expect(shallow(<DocumentsForm {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<DocumentsForm {...props} />)).toMatchSnapshot()
})
