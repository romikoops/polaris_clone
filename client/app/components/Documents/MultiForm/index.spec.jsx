import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

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
jest.mock('react-tooltip', () =>
  // eslint-disable-next-line react/prop-types
  () => ({ props }) => ({ children }) => <div>{children}</div>)
jest.mock('react-truncate', () =>
  // eslint-disable-next-line react/prop-types
  () => ({ props }) => ({ children }) => <div>{children}</div>)
// eslint-disable-next-line
import DocumentsMultiForm from './'

const propsBase = {
  url: 'FOO_URL',
  type: 'FOO_TYPE',
  theme,
  dispatchFn: identity,
  uploadFn: identity,
  tooltip: 'FOO_TOOLTIP',
  text: 'FOO_TEXT',
  documents: [{ signed_url: 'FOO_SIGNED_URL' }, { signed_url: 'BAR_SIGNED_URL' }, {}],
  isRequired: false,
  deleteFn: identity
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
