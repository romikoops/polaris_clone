import '../../mocks/libraries/react-redux'
import '../../mocks/libraries/react-router-dom'
import * as React from 'react'
import { render } from 'enzyme'
import {
  identity,
  theme,
  match,
  user
} from '../../mocks'
import AdminShipmentAction from './AdminShipmentAction'

const propsBase = {
  theme,
  loading: false,
  user,
  showModal: true,
  loggedIn: false,
  adminDispatch: {
    goTo: identity,
    confirmShipment: identity,
    getShipment: identity
  },
  authenticationDispatch: {
    showLogin: identity,
    closeLogin: identity
  },
  match
}

test('happy path', () => {
  expect(render(<AdminShipmentAction {...propsBase} />)).toMatchSnapshot()
})

test('loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(render(<AdminShipmentAction {...props} />)).toMatchSnapshot()
})
