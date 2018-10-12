import * as React from 'react'
import { shallow } from 'enzyme'
import UserBilling from './UserBilling'

const propsBase = {
  setNav: jest.fn()
}

test('shallow render', () => {
  expect(shallow(<UserBilling {...propsBase} />)).toMatchSnapshot()
})
