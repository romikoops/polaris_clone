import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { user, theme } from '../../mocks/index'

import ResetPasswordForm from '.'

const propsBase = {
  user, theme, location: {}
}

test('shallow rendering', () => {
  expect(shallow(<ResetPasswordForm {...propsBase} />)).toMatchSnapshot()
})

test('state.settingPassword is true', () => {
  const wrapper = shallow(<ResetPasswordForm {...propsBase} />)
  wrapper.setState({ settingPassword: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.focus.password_confirmation is truthy', () => {
  const wrapper = shallow(<ResetPasswordForm {...propsBase} />)
  wrapper.setState({
    focus: {
      password_confirmation: true,
      password: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  const wrapper = shallow(<ResetPasswordForm {...props} />)
  wrapper.setState({
    focus: {
      password_confirmation: true,
      password: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})
