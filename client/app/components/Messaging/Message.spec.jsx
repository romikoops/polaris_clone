import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, tenant, client, change
} from '../../mocks/index'

import Message from './Message'

const propsBase = {
  theme,
  user,
  tenant,
  client,
  message: {
    updated_at: '2018-12-01T18:14:33z',
    sender_id: 2,
    user_id: 1,
    title: 'TITLE',
    message: 'MESSAGE'
  }
}

test('shallow rendering', () => {
  expect(shallow(<Message {...propsBase} />)).toMatchSnapshot()
})

test('message.sender_id === message.user_id', () => {
  const props = change(
    propsBase,
    'message.sender_id',
    1
  )
  expect(shallow(<Message {...props} />)).toMatchSnapshot()
})
