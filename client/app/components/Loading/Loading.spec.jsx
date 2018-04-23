import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
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
