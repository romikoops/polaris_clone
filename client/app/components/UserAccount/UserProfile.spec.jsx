import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, user, tenant
} from '../../mocks/index'

import UserProfile from './UserProfile'

const propsBase = {
  theme,
  user,
  tenant,
  setNav: identity,
  appDispatch: {
    setCurrency: identity
  },
  addresses: [],
  authDispatch: {
    updateUser: identity
  },
  userDispatch: {
    makePrimary: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserProfile {...propsBase} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test.skip('state.editBool is true', () => {
  const wrapper = shallow(<UserProfile {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})
