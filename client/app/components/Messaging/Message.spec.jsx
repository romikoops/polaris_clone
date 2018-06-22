import * as React from 'react'
import { mount } from 'enzyme'
import { theme, user, tenant, client } from '../../mocks'

// eslint-disable-next-line
import { Message } from './Message'

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

let wrapper

const createWrapper = propsInput => mount(<Message {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('props.message.title', () => {
  const title = wrapper.find('h3').first().text()

  expect(title).toBe(propsBase.message.title)
})

test('props.message.message', () => {
  const title = wrapper.find('div > div').last().text()

  expect(title).toBe(propsBase.message.message)
})

test('message.sender_id === message.user_id', () => {
  const defaultDiv = wrapper.find('div > div').first()

  const props = {
    ...propsBase,
    message: {
      ...propsBase.message,
      sender_id: 1
    }
  }
  const whenUserIsSender = createWrapper(props)
  const div = whenUserIsSender.find('div > div').first()

  expect(defaultDiv.props('className')).toEqual({ className: 'flex-5' })
  expect(div.props('className')).toEqual({ className: 'flex-25' })
})
