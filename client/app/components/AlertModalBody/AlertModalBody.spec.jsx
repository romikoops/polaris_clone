import * as React from 'react'
import { mount, shallow } from 'enzyme'
import AlertModalBody from './AlertModalBody'

const propsBase = {
  logo: 'LOGO_URL_ADDRESS',
  maxWidth: '1000',
  message: 'foo',
  toggleAlertModal: () => {}
}

test('shallow render', () => {
  expect(shallow(<AlertModalBody {...propsBase} />)).toMatchSnapshot()
})

test('maxWidth if falsy', () => {
  const props = {
    ...propsBase,
    maxWidth: null
  }
  expect(shallow(<AlertModalBody {...props} />)).toMatchSnapshot()
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
