import '../../mocks/libraries/react-redux'
import '../../mocks/libraries/react-router-dom'
import * as React from 'react'
import { render } from 'enzyme'
import { identity, theme } from '../../mocks/index'

import Loading from './Loading'

const propsBase = {
  theme,
  appDispatch: {
    clearLoading: identity
  }
}

test('happy path', () => {
  expect(render(<Loading {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(render(<Loading {...props} />)).toMatchSnapshot()
})
