import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, shipment, user, tenant, client, theme } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import { Conversation } from './Conversation'

const regularUser = {
  ...user,
  role_id: 2
}

const propsBase = {
  sendMessage: identity,
  conversation: { messages: ['FOO_MESSAGE', 'BAR_MESSAGE'] },
  theme,
  shipment,
  user: regularUser,
  tenant,
  clients: [client]
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
