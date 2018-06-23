import * as React from 'react'
import { shallow } from 'enzyme'
import { req, identity, tenant, theme, user } from '../../mocks'

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

test('noMessages is true', () => {
  const props = {
    ...propsBase,
    noMessages: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('unread > 0', () => {
  const props = {
    ...propsBase,
    unread: 1
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('user.role_id === 2', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 2
    }
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('showRegistration is true', () => {
  const props = {
    ...propsBase,
    showRegistration: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})
