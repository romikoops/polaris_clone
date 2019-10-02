import '../../mocks/libraries/react-redux'
import '../../mocks/libraries/react-router-dom'
import * as React from 'react'
import { render, shallow } from 'enzyme'
import { identity, tenant } from '../../mocks/index'

import Loading from './Loading'

const propsBase = {
  tenant,
  appDispatch: {
    clearLoading: identity
  }
}

test('happy path', () => {
  const props = {
    ...propsBase
  }
  expect(render(<Loading {...propsBase} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }
  const wrapper = shallow(
    <Loading {...props} />
  )

  expect(wrapper).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    tenant: {
      theme: null
    }
  }

  const wrapper = shallow(
    <Loading {...props} />
  )
  expect(wrapper).toMatchSnapshot()
})
