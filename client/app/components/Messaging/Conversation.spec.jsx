import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, shipment, user, tenant, client, theme } from '../../mocks'

jest.mock('./index.js', () => ({
  // eslint-disable-next-line react/prop-types
  Message: ({ children }) => <div id="message">{children}</div>,
  // eslint-disable-next-line react/prop-types
  MessageShipmentData: ({ children }) => <div id="message.shipment.data">{children}</div>
}))
jest.mock('../../containers/RegistrationPage/RegistrationPage', () => ({
  // eslint-disable-next-line react/prop-types
  RegistrationPage: ({ children }) => <div>{children}</div>
}))
jest.mock('react-scroll', () => ({
  // eslint-disable-next-line react/prop-types
  Element: ({ children }) => <div id="scroll">{children}</div>,
  scroller: { scrollTo: x => x }
}))

jest.mock('node-uuid', () => ({
  // eslint-disable-next-line react/prop-types
  v4: () => 'RANDOM_KEY'
}))
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
