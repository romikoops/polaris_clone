import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity } from '../../mocks'

import LoginRegistrationWrapper from './LoginRegistrationWrapper'

const propsBase = {
  initialCompName: 'LoginPage',
  LoginPageProps: {},
  RegistrationPageProps: {},
  updateDimensions: identity
}

test('shallow render', () => {
  expect(shallow(<LoginRegistrationWrapper {...propsBase} />)).toMatchSnapshot()
})
