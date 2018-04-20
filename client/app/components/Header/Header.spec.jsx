import * as React from 'react'
import { shallow } from 'enzyme'
import { req, identity, tenant, theme, user } from '../../mocks'

// import { bindActionCreators } from 'redux'
jest.mock('../NavDropdown/NavDropdown', () => ({
  // eslint-disable-next-line react/prop-types
  NavDropdown: ({ children }) => <div>{children}</div>
}))
jest.mock('../LoginRegistrationWrapper/LoginRegistrationWrapper', () => ({
  // eslint-disable-next-line react/prop-types
  LoginRegistrationWrapper: ({ children }) => <div>{children}</div>
}))
jest.mock('../Modal/Modal', () => ({
  // eslint-disable-next-line react/prop-types
  Modal: ({ children }) => <div>{children}</div>
}))
jest.mock('react-redux', () => ({
  connect: (x, y) => Component => Component
}))
// eslint-disable-next-line
import Header from './Header'

const propsBase = {
  tenant,
  theme,
  user,
  registering: false,
  loggingIn: false,
  invert: false,
  loginAttempt: false,
  messageDispatch: {
    getUserConversations: identity
  },
  messages: [],
  showRegistration: false,
  unread: 0,
  req,
  scrollable: false,
  appDispatch: identity,
  noMessages: false,
  component: <div>FooComponent</div>
}

test('shallow render', () => {
  expect(shallow(<Header {...propsBase} />)).toMatchSnapshot()
})

test('props.noMessages is true', () => {
  const props = {
    ...propsBase,
    noMessages: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('props.unread > 0', () => {
  const props = {
    ...propsBase,
    unread: 1
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})
