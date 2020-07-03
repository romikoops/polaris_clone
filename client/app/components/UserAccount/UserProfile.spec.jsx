import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow, mount } from 'enzyme'
import {
  theme, identity, user, tenant, scope
} from '../../mocks/index'

import UserProfile from './UserProfile'

const setCurrencyMock = jest.fn()
const propsBase = {
  theme,
  user,
  tenant,
  scope,
  authentication: {
    passwordEmailSent: false
  },
  setNav: identity,
  appDispatch: {
    setCurrency: setCurrencyMock
  },
  addresses: [],
  authDispatch: {
    updateUser: identity
  },
  userDispatch: {
    makePrimary: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserProfile {...propsBase} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test('reset passowrd is hidden', () => {
  const props = {
    ...propsBase,
    scope: {
      user_restrictions: {
        profile: {
          password: true
        }
      }
    }
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test('setting currency', () => {
  const wrapper = mount(<UserProfile {...propsBase} />)
  const instance = wrapper.instance()
  instance.handleCurrencyUpdate({ value: 'AUD' })
  expect(setCurrencyMock).toHaveBeenCalledWith('AUD')
})
