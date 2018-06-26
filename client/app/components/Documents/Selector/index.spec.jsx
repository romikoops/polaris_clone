import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

jest.mock('.././../../helpers', () => ({
  authHeader: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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
