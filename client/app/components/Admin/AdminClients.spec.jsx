import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, client } from '../../mocks'

import AdminClients from './AdminClients'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: Component => Component,
  Route: x => x,
  Switch: x => x
}))

const propsBase = {
  theme,
  hubs: [],
  match: { url: 'URL' },
  hubHash: {},
  clients: [client],
  client,
  adminDispatch: {
    getClient: identity
  },
  dispatch: identity,
  setCurrentUrl: identity,
  history: {}
}

test('shallow render', () => {
  expect(shallow(<AdminClients {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminClients {...props} />)).toMatchSnapshot()
})

test('state.newClientBool is true', () => {
  const wrapper = shallow(<AdminClients {...propsBase} />)
  wrapper.setState({ newClientBool: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.newClient is true', () => {
  const newClient = {
    firstName: 'FIRST_NAME',
    lastName: 'LAST_NAME',
    phone: 'PHONE',
    companyName: 'COMPANY_NAME',
    number: 'NUMBER',
    zipCode: 'ZIP_CODE',
    city: 'CITY',
    country: 'COUNTRY',
    password: 'PASSWORD',
    password_confirmation: 'PASSWORD',
    street: 'STREET'
  }
  const wrapper = shallow(<AdminClients {...propsBase} />)
  wrapper.setState({ newClientBool: true, newClient })

  expect(wrapper).toMatchSnapshot()
})
