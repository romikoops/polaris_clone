import { shallow } from 'enzyme'
import React from 'react'
import AdminMargins from './Margins'
import {
  tenant
} from '../../../mocks'

test('should render the edit button', () => {
  const wrapper = shallow(<AdminMargins tenant={tenant} />)
  expect(wrapper.state('editable')).toEqual(true)
  expect(wrapper).toMatchSnapshot()
})

test('should not render the edit button', () => {
  const wrapper = shallow(<AdminMargins tenant={tenant} />)
  const instance = wrapper.instance()
  expect(wrapper.state('editable')).toEqual(true)
  instance.toggleEditable()
  expect(wrapper.state('editable')).toEqual(false)
  expect(wrapper.find('.fa-pencil').length).toEqual(1)
  expect(wrapper).toMatchSnapshot()
})

test('clicking the button triggers the method', () => {
  const wrapper = shallow(<AdminMargins tenant={tenant} />)
  const instance = wrapper.instance()
  instance.toggleEditable()
  expect(wrapper.state('editable')).toEqual(false)
  wrapper.find('#editButton').simulate('click')
  expect(wrapper.state('editable')).toEqual(true)
  expect(wrapper.find('editButton').length).toEqual(0)
})
