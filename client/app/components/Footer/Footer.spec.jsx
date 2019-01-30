import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, identity } from '../../mocks'

import Footer from './Footer'

const propsBase = {
  store: {
    getState: identity,
    subscribe: identity
  },
  tenant,
  theme
}

test('shallow render', () => {
  expect(shallow(<Footer {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<Footer {...props} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: null
  }
  expect(shallow(<Footer {...props} />)).toMatchSnapshot()
})
