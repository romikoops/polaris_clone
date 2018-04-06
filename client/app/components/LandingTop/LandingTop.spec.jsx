import * as React from 'react'
import { mount } from 'enzyme'
import {
  theme,
  user,
  identity,
  tenant
} from '../../mocks'

jest.mock('../Header/Header', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <header>{children}</header>)

jest.mock('../RoundButton/RoundButton', () => {
  // eslint-disable-next-line react/prop-types
  const RoundButton = ({ children }) => <button>{children}</button>

  return { RoundButton }
})

// eslint-disable-next-line
import { LandingTop } from './LandingTop'

const edittedTenant = {
  data: {
    ...tenant,
    name: 'FOO_NAME'
  }
}

const propsBase = {
  bookNow: identity,
  goTo: identity,
  tenant: edittedTenant,
  theme,
  toAdmin: identity,
  user
}

let wrapper

const createWrapper = propsInput => mount(<LandingTop {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('when user.role_id is 2', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 2
    }
  }
  const dom = createWrapper(props)

  const firstButton = dom.find('RoundButton').first()
  expect(firstButton.prop('text')).toBe('Find Rates')

  const secondButton = dom.find('RoundButton').last()
  expect(secondButton.prop('text')).toBe('My Account')
})

test('when user.role_id is 1', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 1
    }
  }
  const dom = createWrapper(props)

  const firstButton = dom.find('RoundButton').first()
  expect(firstButton.prop('text')).toBe('Admin Dashboard')
})

test('includes tenant\'s name', () => {
  const welcome = wrapper.find('.sign_up h2').first().text()

  expect(welcome.includes(edittedTenant.data.name)).toBeTruthy()
})
