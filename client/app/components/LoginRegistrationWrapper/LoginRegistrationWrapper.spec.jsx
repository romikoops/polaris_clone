import * as React from 'react'
import { mount } from 'enzyme'
import { identity } from '../../mocks'

jest.mock('../../containers/LoginPage/LoginPage', () => {
  // eslint-disable-next-line react/prop-types
  const LoginPage = ({ children }) => <div>{children}</div>

  return { LoginPage }
})

jest.mock('../../containers/RegistrationPage/RegistrationPage', () => {
  // eslint-disable-next-line react/prop-types
  const RegistrationPage = ({ children }) => <div>{children}</div>

  return { RegistrationPage }
})

// eslint-disable-next-line
import { LoginRegistrationWrapper } from './LoginRegistrationWrapper'

const propsBase = {
  initialCompName: 'LoginPage',
  LoginPageProps: {},
  RegistrationPageProps: {},
  updateDimentions: identity
}

let wrapper

const createWrapper = propsInput => mount(<LoginRegistrationWrapper {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('props.initialCompName', () => {
  const props = {
    ...propsBase,
    initialCompName: 'RegistrationPage'
  }
  const withRegistration = createWrapper(props)

  expect(wrapper.find('LoginPage')).toHaveLength(1)
  expect(withRegistration.find('RegistrationPage')).toHaveLength(1)
})

test('click changes state and calls props.updateDimensions', () => {
  const props = {
    ...propsBase,
    updateDimentions: jest.fn()
  }
  const dom = createWrapper(props)
  const clickableDiv = dom.find('.emulate_link').first()

  expect(dom.state().compName).toBe(undefined)
  expect(props.updateDimentions).not.toHaveBeenCalled()

  clickableDiv.simulate('click')

  expect(dom.state().compName).toBe('RegistrationPage')
  expect(props.updateDimentions).toHaveBeenCalled()

  clickableDiv.simulate('click')

  expect(dom.state().compName).toBe('LoginPage')
})
