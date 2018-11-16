import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant } from '../../mocks'
// eslint-disable-next-line import/no-named-as-default
import Footer from './Footer'

jest.mock('react-redux', () => ({
  connect: (x, y) => Component => Component
}))

const propsBase = {
  theme,
  tenant,
  store: {
    getState: jest.fn(),
    subscribe: jest.fn()
  }
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
