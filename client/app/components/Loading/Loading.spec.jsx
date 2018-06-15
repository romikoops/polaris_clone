import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: x => x
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
import Loading from './Loading'

const propsBase = {
  theme,
  appDispatch: {
    clearLoading: identity
  }
}

test('shallow render', () => {
  expect(shallow(<Loading {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<Loading {...props} />)).toMatchSnapshot()
})

test('theme.logoLarge is truthy', () => {
  const props = {
    ...propsBase,
    theme: {
      ...theme,
      logoLarge: 'FOO_LOGO_LARGE'
    }
  }
  expect(shallow(<Loading {...props} />)).toMatchSnapshot()
})
