import * as React from 'react'
import { shallow } from 'enzyme'
import { user, address, identity, match, theme } from '../../mocks'
import AdminShipmentAction from './AdminShipmentAction'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: x => x
}))

const propsBase = {
  theme,
  loading: false,
  user,
  loggedIn: false,
  adminDispatch: {
    goTo: identity,
    confirmShipment: identity,
    getShipment: identity
  },
  authenticationDispatch: {
    showLogin: identity,
    closeLogin: identity
  },
  match,
  address
}

test('shallow rendering', () => {
  expect(shallow(<AdminShipmentAction {...propsBase} />)).toMatchSnapshot()
})

test('loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(shallow(<AdminShipmentAction {...props} />)).toMatchSnapshot()
})
