import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

jest.mock('react-redux', () => ({
  connect: (x, y) => Component => Component
}))
jest.mock('../../../helpers', () => ({
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
jest.mock('../../../actions', () => ({
  documentActions: x => x
}))
jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: ({ props }) => <a {...props}>link</a>
}))

// eslint-disable-next-line
import DocumentsDownloader from './'

const propsBase = {
  theme,
  tooltip: 'FOO_TOOLTIP',
  documentDispatch: identity,
  downloadUrls: {},
  target: 'FOO_TARGET',
  loading: false,
  square: false,
  options: {}
}

test('shallow render', () => {
  expect(shallow(<DocumentsDownloader {...propsBase} />)).toMatchSnapshot()
})

test('square is true', () => {
  const props = {
    ...propsBase,
    square: true
  }

  expect(shallow(<DocumentsDownloader {...props} />)).toMatchSnapshot()
})

test('props.loading is false, state.requested is true', () => {
  const wrapper = shallow(<DocumentsDownloader {...propsBase} />)
  wrapper.setState({ requested: true })

  expect(wrapper).toMatchSnapshot()
})

test('props.loading is true, state.requested is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  const wrapper = shallow(<DocumentsDownloader {...props} />)
  wrapper.setState({ requested: true })

  expect(wrapper).toMatchSnapshot()
})
