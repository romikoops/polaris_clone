import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

jest.mock('.././../../helpers', () => ({
  authHeader: x => x
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
jest.mock('../../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: () => ({ props }) => <button {...props}>click</button>
}))
jest.mock('react-tooltip', () =>
  // eslint-disable-next-line react/prop-types
  () => ({ props }) => ({ children }) => <div>{children}</div>)
// eslint-disable-next-line
import DocumentsSelector from './'

const propsBase = {
  url: 'FOO_URL',
  type: 'FOO_TYPE',
  theme,
  dispatchFn: identity,
  uploadFn: identity,
  tooltip: 'FOO_TOOLTIP',
  options: []
}

test('shallow render', () => {
  expect(shallow(<DocumentsSelector {...propsBase} />)).toMatchSnapshot()
})

test('state.selected is true', () => {
  const wrapper = shallow(<DocumentsSelector {...propsBase} />)

  wrapper.setState({ selected: true })
  expect(wrapper).toMatchSnapshot()
})
