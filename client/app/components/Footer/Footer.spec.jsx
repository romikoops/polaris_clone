import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant } from '../../mocks'
// eslint-disable-next-line import/no-named-as-default
import Footer from './Footer'

const propsBase = {
  theme,
  tenant
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
