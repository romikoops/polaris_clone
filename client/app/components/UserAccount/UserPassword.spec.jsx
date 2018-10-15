import * as React from 'react'
import { shallow } from 'enzyme'
import UserPassword from './UserPassword'

const propsBase = {
  setNav: jest.fn()
}

test('shallow render', () => {
  expect(shallow(<UserPassword {...propsBase} />)).toMatchSnapshot()
})
