import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, user, addresses
} from '../../mocks'

import UserLocations from './UserLocations'

const propsBase = {
  addresses,
  cols: 2,
  setNav: identity,
  theme,
  user,
  userDispatch: {
    destroyAddress: identity,
    makePrimary: identity,
    newUserAddress: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserLocations {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<UserLocations {...props} />)).toMatchSnapshot()
})
