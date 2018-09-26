import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, user, tenant, client } from '../../mocks'

jest.mock('../../constants', () => {
  const format = () => 19

  const moment = () => ({
    format
  })

  return { moment }
})
// eslint-disable-next-line
import Message from './Message'

const propsBase = {
  theme,
  user,
  tenant,
  client,
  message: {
    sender_id: 2,
    user_id: 1,
    title: '',
    message: ''
  }
}

test('shallow rendering', () => {
  expect(shallow(<Message {...propsBase} />)).toMatchSnapshot()
})
