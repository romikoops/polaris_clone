import * as React from 'react'
import { shallow } from 'enzyme'
import { user, theme, location } from '../../mocks'

import ResetPasswordForm from './'

const propsBase = {
  user, theme, location
}

test('shallow rendering', () => {
  expect(shallow(<ResetPasswordForm {...propsBase} />)).toMatchSnapshot()
})
