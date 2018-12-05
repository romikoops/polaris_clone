import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'
import AdminPricingsClientIndex from './AdminPricingsClientIndex'

const propsBase = {
  theme,
  clients: [],
  adminTools: {
    getClientPricings: identity,
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminPricingsClientIndex {...propsBase} />)).toMatchSnapshot()
})

test('clients is falsy', () => {
  const props = {
    ...propsBase,
    clients: null
  }
  expect(shallow(<AdminPricingsClientIndex {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminPricingsClientIndex {...props} />)).toMatchSnapshot()
})

test('state.redirect is true', () => {
  const wrapper = shallow(<AdminPricingsClientIndex {...propsBase} />)
  wrapper.setState({ redirect: true })

  expect(wrapper).toMatchSnapshot()
})
