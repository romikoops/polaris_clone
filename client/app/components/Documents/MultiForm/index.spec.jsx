import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

jest.mock('.././../../helpers', () => ({
  authHeader: x => x,
  gradientTextGenerator: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
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
  documents: [{ signed_url: 'FOO_SIGNED_URL' }, { signed_url: 'BAR_SIGNED_URL' }],
  isRequired: false,
  deleteFn: identity,
}

test('shallow render', () => {
  expect(shallow(<DocumentsMultiForm {...propsBase} />)).toMatchSnapshot()
})
