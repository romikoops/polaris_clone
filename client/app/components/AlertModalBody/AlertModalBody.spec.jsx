import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { AlertModalBody } from './AlertModalBody'

const propsBase = {
  message: 'foo',
  logo: 'LOGO_URL_ADDRESS',
  toggleAlertModal: () => {},
  maxWidth: '1000'
}

test('logo address is used', () => {
  const wrapper = mount(<AlertModalBody {...propsBase} />)
  const imageSource = wrapper.find('img').first().prop('src')

  expect(imageSource).toBe(propsBase.logo)
})

test('text content includes props.message', () => {
  const wrapper = mount(<AlertModalBody {...propsBase} />)
  const textContent = wrapper.find('AlertModalBody').first().text()

  expect(textContent).toBe(`${propsBase.message}Powered byItsMyCargo`)
})

test('click on icon calls props.toggleAlertModal', () => {
  const props = {
    ...propsBase,
    toggleAlertModal: jest.fn()
  }

  const wrapper = mount(<AlertModalBody {...props} />)

  expect(props.toggleAlertModal).not.toHaveBeenCalled()
  wrapper.find('i').first().simulate('click')
  expect(props.toggleAlertModal).toHaveBeenCalled()
})

test('shallow', () => {
  const wrapper = shallow(<AlertModalBody {...propsBase} />)

  expect(wrapper).toMatchSnapshot()
})
