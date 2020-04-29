import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../mocks/index'

import ButtonSection from './ButtonSection'

const propsBase = {
  bookNow: identity,
  tenant,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<ButtonSection {...propsBase} />)).toMatchSnapshot()
})

test('shallow render with no user', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<ButtonSection {...props} />)).toMatchSnapshot()
})
test('shallow render with user and no role', () => {
  const props = {
    ...propsBase,
    user: {
      role: null
    }
  }
  expect(shallow(<ButtonSection {...props} />)).toMatchSnapshot()
})
