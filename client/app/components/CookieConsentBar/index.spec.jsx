import * as React from 'react'
import { shallow } from 'enzyme'

import {
  theme,
  identity,
  tenant,
  user
} from '../../mocks/index'

import { TPureCookieConsentBar as CookieConsentBar } from '.'

const propsBase = {
  theme,
  tenant,
  user,
  loggedIn: false,
  authDispatch: {
    updateUser: identity,
    register: identity
  }
}

test('shallow render', () => {
  expect(shallow(<CookieConsentBar {...propsBase} />)).toMatchSnapshot()
})

test('state.showModal is true', () => {
  const wrapper = shallow(<CookieConsentBar {...propsBase} />)
  wrapper.setState({ showModal: true })

  expect(wrapper).toMatchSnapshot()
})
