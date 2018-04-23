import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity } from '../../mocks'

jest.mock('../../containers/LoginPage/LoginPage', () => ({
  // eslint-disable-next-line react/prop-types
  LoginPage: ({ children }) => <div>{children}</div>
}))
jest.mock('../../containers/RegistrationPage/RegistrationPage', () => ({
  // eslint-disable-next-line react/prop-types
  RegistrationPage: ({ children }) => <div>{children}</div>
}))

// eslint-disable-next-line
import { LoginRegistrationWrapper } from './LoginRegistrationWrapper'

const propsBase = {
  initialCompName: 'LoginPage',
  LoginPageProps: {},
  RegistrationPageProps: {},
  updateDimentions: identity
}

const createWrapper = propsInput => mount(<LoginRegistrationWrapper {...propsInput} />)

test('shallow render', () => {
  expect(shallow(<LoginRegistrationWrapper {...propsBase} />)).toMatchSnapshot()
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
