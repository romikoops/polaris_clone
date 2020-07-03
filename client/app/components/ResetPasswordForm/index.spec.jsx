import { mount, shallow } from 'enzyme'
import Formsy from 'formsy-react'
import * as React from 'react'
import ResetPasswordForm from '.'
import { theme, user } from '../../mocks/index'
import '../../mocks/libraries/react-redux'

const propsBase = {
  user,
  theme,
  location: {
    search: 'nice=param'
  }
}
jest.mock('../Header/Header')

jest.mock('../../constants/api.constants', () => ({
  getTenantApiUrl: () => 'TenantApiUrl'
}))

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

describe('#handleSubmit', () => {
  let wrapper
  const form = () => wrapper.find(Formsy)
  const passwordField = () => wrapper.find('input[name="password"]')
  const passwordConfirmationField = () => wrapper.find('input[name="password_confirmation"]')

  beforeEach(() => {
    wrapper = mount(<ResetPasswordForm {...propsBase} />)
  })

  describe('#handleSubmit', () => {
    beforeEach(() => {
      form().invoke('onValidSubmit')()
    })

    it('calls the api', () => {
      expect(window.fetch).toHaveBeenCalledWith(
        'TenantApiUrl/password_resets/undefined',
        { body: undefined, headers: { 'Content-Type': 'application/json' }, method: 'PUT' }
      )
    })
  })

  describe('#onInvalidSubmit', () => {
    beforeEach(() => {
      form().invoke('onInvalidSubmit')()
    })

    it('invalidates the state', () => {
      expect(wrapper.state('submitAttempted')).toBeTruthy()
    })
  })

  describe('#handleFocus', () => {
    it('onFocus sets the focus', () => {
      passwordField().invoke('onFocus')({ type: 'focus', target: { name: 'password' } })
      expect(wrapper.state().focus.password).toBeTruthy()

      passwordConfirmationField().invoke('onFocus')({ type: 'focus', target: { name: 'password_confirmation' } })
      expect(wrapper.state().focus.password_confirmation).toBeTruthy()
    })

    it('onBlur set the removes the focus', () => {
      passwordField().invoke('onBlur')({ type: 'onBlur', target: { name: 'password' } })
      expect(wrapper.state().focus.password).toBeFalsy()

      passwordConfirmationField().invoke('onBlur')({ type: 'blur', target: { name: 'password_confirmation' } })
      expect(wrapper.state().focus.password_confirmation).toBeFalsy()
    })
  })
})
