import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: ({ props }) => <a {...props}>link</a>
}))
jest.mock('../../helpers', () => ({
  authHeader: x => x
}))
jest.mock('../../constants', () => {
  const getTenantApiUrl = () => 'getTenantApiUrl'

  return { getTenantApiUrl }
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

test('state.error is true', () => {
  const wrapper = shallow(<FileUploader {...propsBase} />)
  wrapper.setState({ error: true })

  expect(wrapper).toMatchSnapshot()
})
