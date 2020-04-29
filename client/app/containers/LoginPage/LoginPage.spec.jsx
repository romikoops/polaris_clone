import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  user, tenant
} from '../../mocks/index'

import LoginPage from './LoginPage'

const propsBase = {
  logginIn: false,
  loginAttempt: false,
  user,
  noRedirect: false,
  req: null,
  scope: tenant.scope,
  authMethods: []
}

test('shallow render', () => {
  expect(shallow(<LoginPage {...propsBase} />)).toMatchSnapshot()
})

test('shallow render with saml login', () => {
  const props = {
    ...propsBase,
    authMethods: ['saml']
  }
  expect(shallow(<LoginPage {...props} />)).toMatchSnapshot()
})

test('stoggleShowLogin sets showLoginForm to true', () => {
  const props = {
    ...propsBase,
    authMethods: ['saml']
  }
  const wrapper = shallow(<LoginPage {...props} />)
  const instance = wrapper.instance()
  expect(instance.state.showLoginForm).toBe(false)
  instance.toggleShowLoginForm()
  expect(instance.state.showLoginForm).toBe(true)
})
test('clicking showLogin button sets showLoginForm to true', () => {
  const props = {
    ...propsBase,
    authMethods: ['saml']
  }
  const wrapper = shallow(<LoginPage {...props} />)
  const instance = wrapper.instance()
  expect(instance.state.showLoginForm).toBe(false)
  wrapper.find('.showLogin').simulate('click')
  expect(instance.state.showLoginForm).toBe(true)
})
test('clicking forgotPassword button sets forgotPassword to true', () => {
  const wrapper = shallow(<LoginPage {...propsBase} />)
  const instance = wrapper.instance()
  expect(instance.state.forgotPassword).toBe(undefined)
  expect(instance.state.showLoginForm).toBe(true)
  wrapper.find('.forgotPassword').simulate('click')
  expect(instance.state.forgotPassword).toBe(true)
})
