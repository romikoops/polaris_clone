import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: ({ props }) => <a {...props}>link</a>
}))
jest.mock('react-truncate', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <span>{children}</span>)
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ props }) => <button {...props}>click</button>
}))
jest.mock('react-tooltip', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../../helpers', () => ({
  authHeader: x => x
}))
jest.mock('../../constants', () => {
  const BASE_URL = 'BASE_URL'

  return { BASE_URL }
})
// eslint-disable-next-line
import FileUploader from './FileUploader'

const propsBase = {
  url: 'FOO_URL',
  type: 'FOO_TYPE',
  dispatchFn: identity,
  uploadFn: identity,
  square: false,
  tooltip: 'FOO_TOOLTIP',
  theme
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
