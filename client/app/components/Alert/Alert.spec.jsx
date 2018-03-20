import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { Alert } from './Alert'

const message = 'bar_message'

const propsBase = {
  onClose: () => {},
  message: {
    type: 'notice',
    text: message
  }
}

test('renders message within react-sticky library', () => {
  const wrapper = mount(<Alert {...propsBase} />)

  const iconClass = wrapper.find('i.fa').first().prop('className')
  expect(iconClass).toBe('fa fa-times close')

  const alertClass = wrapper.find('.alert').first().prop('className')
  expect(alertClass).toBe('alert info fade in')

  expect(wrapper.find('div')).toHaveLength(5)
  expect(wrapper.text()).toBe(message)
})

test('correctly accepts props', () => {
  const props = {
    ...propsBase,
    timeout: 100,
    message: {
      ...propsBase.message,
      type: 'error'
    }
  }
  const wrapper = mount(<Alert {...props} />)

  const alertClass = wrapper.find('.alert').first().prop('className')
  expect(alertClass).toBe('alert danger fade in')

  expect(wrapper.find('Alert').first().prop('timeout')).toBe(props.timeout)
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

test('shallow', () => {
  const wrapper = shallow(<Alert {...propsBase} />)

  expect(wrapper).toMatchSnapshot()
})
