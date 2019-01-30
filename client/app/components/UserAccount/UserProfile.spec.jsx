import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, user, tenant
} from '../../mocks'

import UserProfile from './UserProfile'

const propsBase = {
  theme,
  user,
  tenant,
  setNav: identity,
  appDispatch: {
    setCurrency: identity
  },
  aliases: [],
  addresses: [],
  authDispatch: {
    updateUser: identity
  },
  userDispatch: {
    makePrimary: identity,
    newAlias: identity,
    deleteAlias: identity
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

test('aliases is truthy', () => {
  const props = {
    ...propsBase,
    aliases: [{ foo: 0 }, { bar: 1 }]
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test('state.editBool is true', () => {
  const wrapper = shallow(<UserProfile {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})
