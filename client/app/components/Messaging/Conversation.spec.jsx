import * as React from 'react'
import { shallow } from 'enzyme'
import {
  client,
  identity,
  shipment,
  tenant,
  theme,
  change,
  user
} from '../../mocks'

import Conversation from './Conversation'

const propsBase = {
  clients: [client],
  conversation: { messages: ['FOO_MESSAGE', 'BAR_MESSAGE'] },
  sendMessage: identity,
  shipment,
  tenant,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<Conversation {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<Conversation {...props} />)).toMatchSnapshot()
})

test('isAdmin is true', () => {
  const props = change(
    propsBase,
    'user.role.name',
    'admin'
  )
  expect(shallow(<Conversation {...props} />)).toMatchSnapshot()
})

test('state.showDetails is true', () => {
  const wrapper = shallow(<Conversation {...propsBase} />)
  wrapper.setState({ showDetails: true })

  expect(wrapper).toMatchSnapshot()
})

test('with admin user', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 1
    }
  }
  expect(shallow(<Conversation {...props} />)).toMatchSnapshot()
})
