import * as React from 'react'
import { mount } from 'enzyme'
import { Alert } from './Alert'

/**
 * NOTE: No snapshot due to need of complex mock
 */

const propsBase = {
  message: {
    type: 'notice',
    text: 'FOO_MESSAGE_TEXT'
  }
}

test('click calls onClose function', () => {
  const props = {
    ...propsBase,
    onClose: jest.fn()
  }
  const wrapper = mount(<Alert {...props} />)
  wrapper.find('i.fa').first().simulate('click')

  expect(props.onClose).toHaveBeenCalled()
})
