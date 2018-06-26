import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

/**
 * ISSUE
 * `const fileName = doc ? ` makes little sense as
 * other assumptions for `doc` prevent its falsy value
 */

jest.mock('.././../../helpers', () => ({
  authHeader: x => x,
  gradientTextGenerator: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: () => ({ props }) => <a {...props}>link</a>
}))
// eslint-disable-next-line
import DocumentsForm from './'

const propsBase = {
  url: 'FOO_URL',
  type: 'FOO_TYPE',
  theme,
  dispatchFn: identity,
  uploadFn: identity,
  tooltip: 'FOO_TOOLTIP',
  text: 'FOO_TEXT',
  doc: { signed_url: 'FOO_SIGNED_URL' },
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
