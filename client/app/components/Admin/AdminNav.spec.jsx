import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, change
} from '../../mocks'
import AdminNav from './AdminNav'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  navLink: identity,
  user
}

test('shallow render', () => {
  expect(shallow(<AdminNav {...propsBase} />)).toMatchSnapshot()
})

test('user.role && user.role.name === super_admin', () => {
  const props = change(
    propsBase,
    'user.role',
    { name: 'super_admin' }
  )

  expect(shallow(<AdminNav {...props} />)).toMatchSnapshot()
})
