import * as React from 'react'
import { mount, shallow, identity } from 'enzyme'
import { Alert } from './Alert'

const propsBase = {
  onClose: identity,
  message: {
    type: 'notice',
    text: 'FOO_MESSAGE_TEXT'
  }
}

test('shallow render', () => {
  expect(shallow(<Alert {...propsBase} />)).toMatchSnapshot()
})

test('click calls onClose function', () => {
  const props = {
    ...propsBase,
    onClose: jest.fn()
  }

  const wrapper = mount(<Alert {...props} />)

  expect(props.onClose).not.toHaveBeenCalled()
  wrapper.find('i.fa').first().simulate('click')
  expect(props.onClose).toHaveBeenCalled()
})
