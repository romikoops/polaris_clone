import * as React from 'react'
import { shallow } from 'enzyme'
import UserEmails from './UserEmails'

const propsBase = {
  setNav: jest.fn()
}

test('shallow render', () => {
  expect(shallow(<UserEmails {...propsBase} />)).toMatchSnapshot()
})
