import '../../../mocks/libraries/react-redux'
import '../../../mocks/libraries/react-router-dom'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks/index'

import DocumentsDownloader from '.'

const propsBase = {
  theme,
  tooltip: 'FOO_TOOLTIP',
  documentDispatch: identity,
  downloadUrls: {},
  target: 'FOO_TARGET',
  loading: false,
  square: false,
  options: {},
  targetOptions: []
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
