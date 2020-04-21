import * as React from 'react'
import { shallow } from 'enzyme'
import {
  tenant,
  theme,
  user,
  identity
} from '../../mocks/index'

import App from './App'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => (Component) => Component
}))

const propsBase = {
  theme,
  tenant,
  user,
  appDispatch: {
    getTenantId: () => 1,
    setTenants: identity
  },
  authDispatch: {
    setUser: identity
  },
  shipmentDispatch: {
    checkAhoyShipment: identity
  }
}

test('shallow render', () => {
  expect(shallow(<App {...propsBase} />)).toMatchSnapshot()
})

test('isUserExpired escapes when user is null', () => {
  const propsWithoutUser = {
    ...propsBase,
    user: null
  }
  const wrapper = shallow(<App.WrappedComponent {...propsWithoutUser} />).instance()
  expect(wrapper.isUserExpired()).toEqual(undefined)
})
