import * as React from 'react'
import { shallow } from 'enzyme'
import { FlashMessages } from './FlashMessages'

const propsBase = {
  messages: ['FOO', 'BAR']
}

test('shallow render', () => {
  expect(shallow(<FlashMessages {...propsBase} />)).toMatchSnapshot()
})
